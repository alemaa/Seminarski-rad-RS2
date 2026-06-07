using CafeEase.Model.Requests;
using CafeEase.Services;
using CafeEase.Services.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
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
            var currentUser = await GetCurrentUser();
            if (currentUser == null)
                return Unauthorized();

            var order = await _context.Orders.AsNoTracking().FirstOrDefaultAsync(o => o.Id == req.OrderId);
            if (order == null) return NotFound("Order not found");

            if (!CanAccessOrder(currentUser, order))
                return Forbid();

            var existingPayment = await _context.Payments
                .AsNoTracking()
                .Where(p => p.OrderId == order.Id && (p.Status == "Pending" || p.Status == "Completed"))
                .OrderByDescending(p => p.Id)
                .FirstOrDefaultAsync();

            if (existingPayment != null)
            {
                if (existingPayment.Status == "Completed")
                    return BadRequest("This order has already been paid.");

                return BadRequest("Payment is already in progress for this order.");
            }

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
            var currentUser = await GetCurrentUser();
            if (currentUser == null)
                return Unauthorized();

            var payment = await _context.Payments
                .Include(p => p.Order)
                .FirstOrDefaultAsync(p => p.Id == req.PaymentId);

            if (payment == null)
                return NotFound("Payment not found");

            if (!CanAccessOrder(currentUser, payment.Order))
                return Forbid();

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

        private async Task<User?> GetCurrentUser()
        {
            var username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? User.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrWhiteSpace(username))
                return null;

            return await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
        }

        private static bool CanAccessOrder(User currentUser, Order order)
        {
            return currentUser.RoleId == 1 || order.UserId == currentUser.Id;
        }
    }
}
