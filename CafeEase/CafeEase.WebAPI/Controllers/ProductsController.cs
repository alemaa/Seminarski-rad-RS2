using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Authorization;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductsController : BaseCRUDController<Product, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        public ProductsController(ILogger<BaseController<Product, ProductSearchObject>> logger, IProductService service)
            : base(logger, service)
        {
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Product> Insert([FromBody] ProductInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Product> Update(int id, [FromBody] ProductUpdateRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Product> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpGet("{id}/allowedActions")]
        public virtual async Task<List<string>> AllowedActions(int id)
        {
            return await (_service as IProductService)!.AllowedActions(id);
        }

        [HttpGet("{id}/recommend")]
        public virtual List<Product> Recommend(int id)
        {
            return (_service as IProductService)!.Recommend(id);
        }
    }
}
