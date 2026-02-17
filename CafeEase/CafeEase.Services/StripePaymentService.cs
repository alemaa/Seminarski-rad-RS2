using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using CafeEase.Model.Requests;

namespace CafeEase.Services
{
    public class StripePaymentService : IStripePaymentService
    {
        private readonly string _secretKey;
        private readonly string _publishableKey;
        public StripePaymentService(IConfiguration configuration)
        {
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
    }
}
