using Microsoft.AspNetCore.Mvc;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;

namespace CafeEase.WebAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [AllowAnonymous]
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
        [AllowAnonymous]
        public async Task<List<Cafe>> GetNearby([FromQuery] double latitude, [FromQuery] double longitude)
        {
            return await _cafeService.GetNearby(latitude, longitude);
        }
    }
}
