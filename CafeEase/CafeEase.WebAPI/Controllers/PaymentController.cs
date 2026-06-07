using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController : BaseCRUDController<Model.Payment, PaymentSearchObject,PaymentInsertRequest,PaymentUpdateRequest>
    {
        public PaymentsController(ILogger<BaseController<Model.Payment, PaymentSearchObject>> logger, IPaymentService service)
            : base(logger, service)
        {
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("{id}/confirm-cash")]
        public async Task<IActionResult> ConfirmCashPayment(int id)
        {
            await ((IPaymentService)_service).ConfirmCashPaymentAsync(id);
            return Ok();
        }
    }
}
