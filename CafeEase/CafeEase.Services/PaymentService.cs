using AutoMapper;
using CafeEase.Model.Messages;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services.Exceptions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class PaymentService : BaseCRUDService<Model.Payment, Database.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>,IPaymentService
    {
        private readonly ILogger<PaymentService> _logger;

        public PaymentService(CafeEaseDbContext context, IMapper mapper, ILogger<PaymentService> logger) : base(context, mapper)
        {
            _logger = logger;
        }

        public override async Task BeforeInsert(Database.Payment entity,PaymentInsertRequest insert)
        {
            entity.Status = "Pending";
        }

        public async Task FinalizePaidOrderAsync(int orderId)
        {
            var order = await _context.Orders.Include(o => o.OrderItems)
                .FirstOrDefaultAsync(o => o.Id == orderId);

            if (order == null) throw new UserException("Order not found");
            if (order.Status == "Paid") return;

            order.Status = "Paid";
       
            if (order == null)
            {
                throw new UserException("Order not found");
            }

            order.Status = "Paid";

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
                    LastUpdated = DateTime.Now
                };
                _context.LoyaltyPoints.Add(loyalty);
            }
            else
            {
                loyalty.Points += earnedPoints;
                loyalty.LastUpdated = DateTime.Now;
            }

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
                    durable: false,
                    exclusive: false,
                    autoDelete: false);

                var body = Encoding.UTF8.GetBytes(
                    JsonSerializer.Serialize(new PaymentCompleted
                    {
                        OrderId = orderId,
                        UserId = order.UserId,
                        Amount = order.TotalAmount
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

            await _context.SaveChangesAsync();
        }

        public override async Task<Model.Payment> Insert(PaymentInsertRequest insert)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();

            var result = await base.Insert(insert);

            await transaction.CommitAsync();
            return result;
        }

        public override IQueryable<Database.Payment> AddFilter(IQueryable<Database.Payment> query, PaymentSearchObject? search = null)
        {
            if (search?.OrderId.HasValue == true)
                query = query.Where(x => x.OrderId == search.OrderId);

            if (!string.IsNullOrWhiteSpace(search?.Status))
                query = query.Where(x => x.Status == search.Status);

            return base.AddFilter(query, search);
        }
    }
}
