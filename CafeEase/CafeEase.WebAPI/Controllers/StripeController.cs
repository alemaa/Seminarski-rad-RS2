using CafeEase.Model.Requests;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class StripeController : ControllerBase
    {
        private readonly IStripePaymentService _stripe;

        public StripeController(IStripePaymentService stripe)
        {
            _stripe = stripe;
        }

        [HttpPost("create-intent")]
        public async Task<ActionResult<StripeCreateIntentResponse>> CreateIntent([FromBody] StripeCreateIntentRequest req)
        {
            var username = GetCurrentUsername();
            var result = await _stripe.CreateIntentForCurrentUserAsync(username, req);
            return Ok(result);
        }

        [HttpPost("confirm")]
        public async Task<IActionResult> Confirm([FromBody] StripeConfirmRequest req)
        {
            var username = GetCurrentUsername();
            await _stripe.ConfirmForCurrentUserAsync(username, req);
            return Ok();
        }

        private string GetCurrentUsername()
        {
            var username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? User.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrWhiteSpace(username))
                throw new UnauthorizedAccessException();

            return username;
        }
    }
}
