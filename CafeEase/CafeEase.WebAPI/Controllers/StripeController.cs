using CafeEase.Model.Requests;
using CafeEase.Services;
using CafeEase.Services.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StripeController : ControllerBase
    {
        private readonly CafeEaseDbContext _context;
        private readonly IStripePaymentService _stripe;
        private readonly IPaymentService _paymentService;
        public StripeController(CafeEaseDbContext context, IStripePaymentService stripe, IPaymentService paymentService)
        {
            _context = context;
            _stripe = stripe;
            _paymentService = paymentService;
        }

        [HttpPost("create-intent")]
        public async Task<ActionResult<object>> CreateIntent([FromBody] StripeCreateIntentRequest req)
        {
            var order = await _context.Orders.AsNoTracking().FirstOrDefaultAsync(o => o.Id == req.OrderId);
            if (order == null) return NotFound("Order not found");

            var amount = Convert.ToDecimal(order.TotalAmount);

            var intent = await _stripe.CreatePaymentIntentAsync(
                amount,
                "bam",
                new Dictionary<string, string>
                {
                    ["orderId"] = order.Id.ToString(),
                    ["userId"] = order.UserId.ToString()
                }
            );

            var payment = new Payment
            {
                OrderId = order.Id,
                Method = "Stripe",
                Status = "Pending",
                ProviderIntentId = intent.PaymentIntentId
            };

            _context.Payments.Add(payment);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                clientSecret = intent.ClientSecret,
                paymentId = payment.Id,
                publishableKey = intent.PublishableKey
            });
        }

        [HttpPost("confirm")]
        public async Task<IActionResult> Confirm([FromBody] StripeConfirmRequest req)
        {
            var payment = await _context.Payments
                .FirstOrDefaultAsync(p => p.Id == req.PaymentId);

            if (payment == null)
                return NotFound("Payment not found");

            if (payment.Status == "Completed")
                return Ok();

            if (string.IsNullOrWhiteSpace(payment.ProviderIntentId))
                return BadRequest("Missing intent id");

            var ok = await _stripe.ConfirmPaymentAsync(payment.ProviderIntentId);
            if (!ok)
                return BadRequest("Payment not successful");

            await _paymentService.FinalizePaidOrderAsync(payment.OrderId);

            payment.Status = "Completed";
            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}
