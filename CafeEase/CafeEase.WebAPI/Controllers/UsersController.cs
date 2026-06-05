using CafeEase.Model.Requests;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : BaseCRUDController<Model.User, Model.SearchObjects.UserSearchObject, Model.Requests.UserInsertRequest, Model.Requests.UserUpdateRequest>
    {
        public UsersController(ILogger<BaseController<Model.User, Model.SearchObjects.UserSearchObject>> logger, IUserService service) : base(logger, service)
        {
        }
        [AllowAnonymous]
        [HttpPost("register")]
        public Task<Model.User> Register([FromBody] RegisterRequest request)
        {
            return ((IUserService)_service).Register(request);
        }
    }
}