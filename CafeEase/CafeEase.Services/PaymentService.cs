using AutoMapper;
using CafeEase.Model.Messages;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Model.Exceptions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace CafeEase.Services
{
    public class PaymentService : BaseCRUDService<Model.Payment, Database.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>,IPaymentService
    {
        private readonly ILogger<PaymentService> _logger;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PaymentService(CafeEaseDbContext context, IMapper mapper, ILogger<PaymentService> logger, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            _logger = logger;
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task BeforeInsert(Database.Payment entity,PaymentInsertRequest insert)
        {
            var order = await _context.Orders.Include(o => o.User).FirstOrDefaultAsync(o => o.Id == insert.OrderId);

            if (order == null)
                throw new NotFoundException("Order not found.");

            if (!IsAdmin() && order.User.Username != GetCurrentUsername())
                throw new ForbiddenException("You cannot create payment for this order.");

            var paymentExists = await _context.Payments.AnyAsync(p => p.OrderId == insert.OrderId && (p.Status == "Pending" || p.Status == "Completed"));

            if (paymentExists)
                throw new UserException("An active payment already exists for this order.");

            entity.Status = "Pending";
        }

        public async Task FinalizePaidOrderAsync(int paymentId)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();

            var payment = await _context.Payments
                .Include(p => p.Order)
                    .ThenInclude(o => o.OrderItems)
                .FirstOrDefaultAsync(p => p.Id == paymentId);

            if (payment == null)
                throw new UserException("Payment not found");

            if (payment.Status == "Completed")
            {
                await transaction.CommitAsync();
                return;
            }

            if (payment.Order == null)
                throw new UserException("Order not found");

            var order = payment.Order;

            if (order.Status == OrderStatuses.Paid)
            {
                payment.Status = "Completed";
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                return;
            }

            order.Status = OrderStatuses.Paid;
            payment.Status = "Completed";

            var requested = order.OrderItems
                .GroupBy(x => x.ProductId)
                .Select(g => new { ProductId = g.Key, Qty = g.Sum(x => x.Quantity) })
                .ToList();

            var productIds = requested.Select(x => x.ProductId).ToList();

            var inventories = await _context.Inventories
                .Where(i => productIds.Contains(i.ProductId))
                .ToListAsync();

            foreach (var r in requested)
            {
                var inv = inventories.FirstOrDefault(i => i.ProductId == r.ProductId);
                if (inv == null)
                    throw new UserException("The selected product is currently unavailable.");

                if (inv.Quantity < r.Qty)
                {
                    var product = await _context.Products.AsNoTracking()
                        .FirstOrDefaultAsync(p => p.Id == r.ProductId);

                    var name = product?.Name ?? $"ID {r.ProductId}";
                    throw new UserException($"Not enough stock available for {name}.");
                }
            }

            foreach (var r in requested)
            {
                var inv = inventories.First(i => i.ProductId == r.ProductId);
                inv.Quantity -= r.Qty;
            }

            var earnedPoints = (int)Math.Floor(order.TotalAmount);

            var loyalty = await _context.LoyaltyPoints
                .FirstOrDefaultAsync(x => x.UserId == order.UserId);

            if (loyalty == null)
            {
                loyalty = new Database.LoyaltyPoints
                {
                    UserId = order.UserId,
                    Points = earnedPoints,
                    LastUpdated = DateTime.UtcNow
                };
                _context.LoyaltyPoints.Add(loyalty);
            }
            else
            {
                loyalty.Points += earnedPoints;
                loyalty.LastUpdated = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            await PublishPaymentCompletedAsync(order.Id, order.UserId, order.TotalAmount);
        }

        private async Task PublishPaymentCompletedAsync(int orderId, int userId, decimal amount)
        {
            try
            {
                var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
                var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
                var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
                var rabbitVHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
                var queueName = Environment.GetEnvironmentVariable("RABBITMQ_QUEUE") ?? "payment_completed";

                var factory = new ConnectionFactory
                {
                    HostName = rabbitHost,
                    UserName = rabbitUser,
                    Password = rabbitPass,
                    VirtualHost = rabbitVHost,
                };

                await using var connection = await factory.CreateConnectionAsync();
                await using var channel = await connection.CreateChannelAsync();

                await channel.QueueDeclareAsync(
                    queue: queueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false);

                var body = Encoding.UTF8.GetBytes(
                    JsonSerializer.Serialize(new PaymentCompleted
                    {
                        OrderId = orderId,
                        UserId = userId,
                        Amount = amount
                    })
                );

                await channel.BasicPublishAsync(
                    exchange: "",
                    routingKey: queueName,
                    mandatory: false,
                    body: body);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Rabbit publish failed, continuing without message.");
            }
        }

        public override async Task<Model.Payment> Insert(PaymentInsertRequest insert)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();

            var result = await base.Insert(insert);

            await transaction.CommitAsync();
            return result;
        }

        public override async Task<Model.Payment> Update(int id, PaymentUpdateRequest update)
        {
            if (!IsAdmin())
               throw new ForbiddenException("Only administrators can update payments.");

            return await base.Update(id, update);
        }

        public override async Task<Model.Payment> Delete(int id)
        {
            if (!IsAdmin())
                throw new ForbiddenException("Only administrators can delete payments.");

            return await base.Delete(id);
        }

        public override IQueryable<Database.Payment> AddFilter(IQueryable<Database.Payment> query, PaymentSearchObject? search = null)
        {
            if (!IsAdmin())
            {
                var username = GetCurrentUsername();
                query = query.Where(p => p.Order.User.Username == username);
            }

            if (search?.OrderId.HasValue == true)
                query = query.Where(x => x.OrderId == search.OrderId.Value);

            if (!string.IsNullOrWhiteSpace(search?.Status))
                query = query.Where(x => x.Status == search.Status);

            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.Payment> AddInclude(IQueryable<Database.Payment> query, PaymentSearchObject? search = null)
        {
            return query.Include(p => p.Order).ThenInclude(o => o.User);
        }

        public override async Task<Model.Payment> GetById(int id)
        {
            var entity = await _context.Payments
                .Include(p => p.Order)
                .ThenInclude(o => o.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (entity == null)
                throw new NotFoundException("Payment not found.");

            if (!IsAdmin() &&
                entity.Order.User.Username != GetCurrentUsername())
            {
                throw new ForbiddenException(
                    "You cannot access this payment."
                );
            }

            return _mapper.Map<Model.Payment>(entity);
        }

        public async Task ConfirmCashPaymentAsync(int paymentId)
        {
            var payment = await _context.Payments
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == paymentId);

            if (payment == null)
                throw new UserException("Payment not found");

            if (payment.Method != "Cash")
                throw new UserException("Only cash payments can be confirmed here.");

            if (payment.Status == "Completed")
                return;

            await FinalizePaidOrderAsync(payment.Id);
        }

        private string GetCurrentUsername()
        {
            return _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? throw new UserException("User not authenticated.");
        }

        private bool IsAdmin()
        {
            return _httpContextAccessor.HttpContext?.User.IsInRole("Admin") == true;
        }
    }
}
