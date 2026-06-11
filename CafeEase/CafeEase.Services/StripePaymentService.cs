using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CafeEase.Model.Requests;
using CafeEase.Model.Exceptions;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace CafeEase.Services
{
    public class StripePaymentService : IStripePaymentService
    {
        private readonly string _secretKey;
        private readonly string _publishableKey;
        private readonly CafeEaseDbContext _context;
        private readonly IPaymentService _paymentService;
        public StripePaymentService(IConfiguration configuration, CafeEaseDbContext context, IPaymentService paymentService)
        {
            _context = context;
            _paymentService = paymentService;

            _secretKey = configuration["Stripe:SecretKey"]
                ?? throw new ArgumentNullException("Stripe:SecretKey not configured");

            _publishableKey = configuration["Stripe:PublishableKey"]
                ?? throw new ArgumentNullException("Stripe:PublishableKey not configured");

            StripeConfiguration.ApiKey = _secretKey;
        }
        public async Task<StripeCreateIntentResponse> CreatePaymentIntentAsync(decimal amount, string currency, Dictionary<string, string>? metadata = null)
        {
            var options = new PaymentIntentCreateOptions
            {
                Amount = (long)Math.Round(amount * 100m),
                Currency = currency.ToLower(),
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions { Enabled = true },
                Metadata = metadata
            };

            var service = new PaymentIntentService();
            var intent = await service.CreateAsync(options);

            return new StripeCreateIntentResponse
            {
                ClientSecret = intent.ClientSecret,
                PaymentIntentId = intent.Id,
                PublishableKey = _publishableKey
            };
        }
        public async Task<bool> ConfirmPaymentAsync(string paymentIntentId)
        {
            var service = new PaymentIntentService();
            var intent = await service.GetAsync(paymentIntentId);
            return intent.Status == "succeeded";
        }

        public async Task<StripeCreateIntentResponse> CreateIntentForCurrentUserAsync(string username, StripeCreateIntentRequest request)
        {
            var currentUser = await GetCurrentUser(username);

            var order = await _context.Orders.AsNoTracking().FirstOrDefaultAsync(o => o.Id == request.OrderId);

            if (order == null)
                throw new NotFoundException("Order not found");

            if (!CanAccessOrder(currentUser, order))
                throw new ForbiddenException("You are not allowed to access this order.");

            var existingPayment = await _context.Payments
                .AsNoTracking().Where(p => p.OrderId == order.Id && (p.Status == "Pending" || p.Status == "Completed")).OrderByDescending(p => p.Id).FirstOrDefaultAsync();

            if (existingPayment != null)
            {
                if (existingPayment.Status == "Completed")
                    throw new UserException("This order has already been paid.");

                throw new UserException("Payment is already in progress for this order.");
            }

            var intent = await CreatePaymentIntentAsync(
                order.TotalAmount,
                "bam",
                new Dictionary<string, string>
                {
                    ["orderId"] = order.Id.ToString(),
                    ["userId"] = order.UserId.ToString()
                });

            var payment = new Payment
            {
                OrderId = order.Id,
                Method = "Stripe",
                Status = "Pending",
                ProviderIntentId = intent.PaymentIntentId
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            return new StripeCreateIntentResponse
            {
                ClientSecret = intent.ClientSecret,
                PaymentIntentId = intent.PaymentIntentId,
                PublishableKey = intent.PublishableKey,
                PaymentId = payment.Id
            };
        }

        public async Task ConfirmForCurrentUserAsync(string username, StripeConfirmRequest request)
        {
            var currentUser = await GetCurrentUser(username);

            var payment = await _context.Payments.Include(p => p.Order).FirstOrDefaultAsync(p => p.Id == request.PaymentId);

            if (payment == null)
                throw new NotFoundException("Payment not found");

            if (!CanAccessOrder(currentUser, payment.Order))
                throw new ForbiddenException("You are not allowed to access this payment.");

            if (payment.Status == "Completed")
                return;

            if (string.IsNullOrWhiteSpace(payment.ProviderIntentId))
                throw new UserException("Missing intent id");

            var ok = await ConfirmPaymentAsync(payment.ProviderIntentId);

            if (!ok)
                throw new UserException("Payment not successful");

            await _paymentService.FinalizePaidOrderAsync(payment.Id);
        }

        private async Task<User> GetCurrentUser(string username)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (user == null)
                throw new UserException("User not found");

            return user;
        }

        private static bool CanAccessOrder(User currentUser, Order order)
        {
            return currentUser.RoleId == 1 || order.UserId == currentUser.Id;
        }
    }
}
