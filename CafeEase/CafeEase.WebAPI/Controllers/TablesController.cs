using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TablesController : BaseCRUDController<Model.Table, TableSearchObject, Model.Requests.TableInsertRequest, Model.Requests.TableUpdateRequest>
    {
        public TablesController(ILogger<BaseController<CafeEase.Model.Table, TableSearchObject>> logger, ITableService service) : base(logger, service)
        {
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Model.Table> Insert([FromBody] TableInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Model.Table> Update(int id, [FromBody] TableUpdateRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Model.Table> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
