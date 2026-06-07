using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
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

        [AllowAnonymous]
        [HttpGet]
        public override Task<Model.PagedResult<Model.City>> Get([FromQuery] BaseSearchObject? search = null)
        {
            return base.Get(search);
        }

        [AllowAnonymous]
        [HttpGet("{id}")]
        public override Task<Model.City> GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override Task<Model.City> Insert([FromBody] CityUpsertRequest insert)
        {
            return base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override Task<Model.City> Update(int id, [FromBody] CityUpsertRequest update)
        {
            return base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override Task<Model.City> Delete(int id)
        {
            return base.Delete(id);
        }
    }
}
