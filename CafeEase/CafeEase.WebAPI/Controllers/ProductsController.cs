using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

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
