using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using CafeEase.WebAPI.Controllers;
using Microsoft.AspNetCore.Authorization;
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

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Model.Inventory> Insert([FromBody] InventoryInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Model.Inventory> Update(int id, [FromBody] InventoryUpdateRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Model.Inventory> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
