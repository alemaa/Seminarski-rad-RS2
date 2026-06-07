using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;
using CafeEase.Model.Responses;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrdersController : BaseCRUDController<Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        public OrdersController(ILogger<BaseController<Order, OrderSearchObject>> logger, IOrderService service) : base(logger, service)
        {
        }

        [HttpPost("preview-total")]
        public async Task<ActionResult<OrderTotalPreviewResponse>> PreviewTotal([FromBody] OrderInsertRequest request)
        {
            var result = await ((IOrderService)_service).PreviewTotal(request);
            return Ok(result);
        }
    }
}
