using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CitiesController : BaseCRUDController<Model.City, BaseSearchObject, CityUpsertRequest, CityUpsertRequest>
    {
        public CitiesController(ILogger<BaseController<Model.City, BaseSearchObject>> logger, ICityService service) : base(logger, service)
        {


        }
    }
}
