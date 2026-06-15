using Microsoft.AspNetCore.Mvc;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using CafeEase.Model.Responses;
using CafeEase.Model.Exceptions;

namespace CafeEase.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CafesController : BaseCRUDController<Cafe, CafeSearchObject, CafeUpsertRequest, CafeUpsertRequest>
    {
        private readonly ICafeService _cafeService;

        public CafesController(
            ILogger<BaseController<Cafe, CafeSearchObject>> logger,
            ICafeService service
        ) : base(logger, service)
        {
            _cafeService = service;
        }

        [HttpGet("nearby")]
        public async Task<List<Cafe>> GetNearby([FromQuery] double latitude, [FromQuery] double longitude)
        {
            return await _cafeService.GetNearby(latitude, longitude);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("geocode")]
        public async Task<ActionResult<GeocodeResponse>> Geocode([FromQuery] string address, [FromQuery] string city)
        {
            if (string.IsNullOrWhiteSpace(address) || string.IsNullOrWhiteSpace(city))
                throw new UserException("Address and city are required.");

            var result = await _cafeService.GeocodeAddress(address, city);

            if (result == null)
                throw new NotFoundException("Coordinates not found.");

            return Ok(result);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Cafe> Insert([FromBody] CafeUpsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Cafe> Update(int id, [FromBody] CafeUpsertRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Cafe> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
