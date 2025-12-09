using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class LoyaltyPointsController : BaseCRUDController<Model.LoyaltyPoints,LoyaltyPointsSearchObject, LoyaltyPointsInsertRequest,LoyaltyPointsUpdateRequest>
    {
        public LoyaltyPointsController(ILogger<BaseController<Model.LoyaltyPoints, LoyaltyPointsSearchObject>> logger, ILoyaltyPointsService service)
            : base(logger, service)
        {
        }
    }
}
