using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriesController : BaseCRUDController<Model.Category, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        public CategoriesController(ILogger<BaseController<Model.Category, CategorySearchObject>> logger, ICategoryService service)
            : base(logger, service)
        {
        }


        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Model.Category> Insert([FromBody] CategoryUpsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Model.Category> Update(int id, [FromBody] CategoryUpsertRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Model.Category> Delete(int id)
        {
            return await base.Delete(id);
        }
    }

}