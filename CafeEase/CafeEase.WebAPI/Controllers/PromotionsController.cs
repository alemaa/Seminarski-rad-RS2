using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PromotionsController : BaseCRUDController<Promotion,PromotionSearchObject,PromotionInsertRequest,PromotionUpdateRequest>
    {
        public PromotionsController(ILogger<BaseController<Promotion, PromotionSearchObject>> logger, IPromotionService service)
            : base(logger, service)
        {
        }

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Model.Promotion> Insert([FromBody] PromotionInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Model.Promotion> Update(int id, [FromBody] PromotionUpdateRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Model.Promotion> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
}
