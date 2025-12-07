using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [Route("api/[controller]")]
    public class OrdersController : BaseCRUDController<Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>
    {
        public OrdersController(ILogger<BaseController<Order, OrderSearchObject>> logger, IOrderService service) : base(logger, service)
        {
        }
    }
}
