using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [Route("api/[controller]")]
    public class CategoriesController
     : BaseCRUDController<Model.Category, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
        public CategoriesController(
            ILogger<BaseController<Model.Category, CategorySearchObject>> logger,
            ICategoryService service)
            : base(logger, service)
        {
        }
    }

}