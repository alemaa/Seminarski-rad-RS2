using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using CafeEase.WebAPI.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class InventoryController : BaseCRUDController<Inventory, InventorySearchObject, InventoryInsertRequest, InventoryUpdateRequest>
    {
        public InventoryController(ILogger<BaseController<Model.Inventory, InventorySearchObject>>logger, IInventoryService service)
            : base(logger, service)
        {
        }
    }
}
