using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PromotionsController : BaseCRUDController<Promotion,PromotionSearchObject,PromotionInsertRequest,PromotionUpdateRequest>
    {
        public PromotionsController(
            ILogger<BaseController<Promotion, PromotionSearchObject>> logger,
            IPromotionService service)
            : base(logger, service)
        {
        }
    }

}
