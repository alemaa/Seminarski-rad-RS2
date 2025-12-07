using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class OrderItemsController : BaseCRUDController<Model.OrderItem,OrderItemSearchObject, OrderItemInsertRequest, OrderItemUpdateRequest>
    {
        public OrderItemsController( ILogger<BaseController<Model.OrderItem, OrderItemSearchObject>> logger,IOrderItemService service): base(logger, service)
        {
        }
    }
}
