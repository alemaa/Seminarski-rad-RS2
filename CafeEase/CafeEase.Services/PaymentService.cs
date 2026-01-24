using AutoMapper;
using CafeEase.Model.Messages;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services.Exceptions;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client;
using System;
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
            entity.Status = "Completed";

            var order = await _context.Orders.FindAsync(insert.OrderId);
            if (order == null)
            {
                throw new UserException("Order not found");
            }

            order.Status = "Paid";

            var loyalty = _context.LoyaltyPoints.FirstOrDefault(x => x.UserId == order.UserId);
            if (loyalty != null)
            {
                loyalty.Points += (int)(order.TotalAmount / 10);
            }

            try
            {

                var factory = new ConnectionFactory
                {
                    HostName = "localhost"
                };

                await using var connection = await factory.CreateConnectionAsync();
                await using var channel = await connection.CreateChannelAsync();

                await channel.QueueDeclareAsync(
                    queue: "payment_completed",
                    durable: false,
                    exclusive: false,
                    autoDelete: false);

                var body = Encoding.UTF8.GetBytes(
                    JsonSerializer.Serialize(new PaymentCompleted
                    {
                        OrderId = insert.OrderId,
                        UserId = order.UserId,
                        Amount = order.TotalAmount
                    })
                );

                await channel.BasicPublishAsync(
                    exchange: "",
                    routingKey: "payment_completed",
                    mandatory: false,
                    body: body);
            }

            catch (Exception ex)
            {
                _logger.LogError(ex, "Rabbit publish failed, continuing without message.");
            }
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
