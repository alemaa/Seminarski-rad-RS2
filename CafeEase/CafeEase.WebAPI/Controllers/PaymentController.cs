using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentsController
      : BaseCRUDController<
          Model.Payment,
          PaymentSearchObject,
          PaymentInsertRequest,
          PaymentUpdateRequest>
    {
        public PaymentsController(
            ILogger<
                BaseController<Model.Payment, PaymentSearchObject>> logger,
            IPaymentService service)
            : base(logger, service)
        {
        }
    }

}
