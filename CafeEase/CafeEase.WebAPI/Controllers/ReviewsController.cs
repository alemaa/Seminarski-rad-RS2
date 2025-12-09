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
    public class ReviewsController : BaseCRUDController<Review, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        public ReviewsController(
            ILogger<BaseController<Review, ReviewSearchObject>> logger,
            IReviewService service)
            : base(logger, service)
        {
        }
    }
}
