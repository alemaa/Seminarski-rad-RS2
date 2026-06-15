using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

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

        [Authorize(Roles = "Admin")]
        [HttpPost]
        public override async Task<Model.User> Insert([FromBody] UserInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}")]
        public override async Task<Model.User> Update(int id, [FromBody] UserUpdateRequest update)
        {
            return await base.Update(id, update);
        }

        [Authorize(Roles = "Admin")]
        [HttpDelete("{id}")]
        public override async Task<Model.User> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            var username = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? User.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrWhiteSpace(username))
                return Unauthorized();

            await ((IUserService)_service).ChangePassword(username, request);
            return Ok();
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("admin-check")]
        public IActionResult AdminCheck()
        {
            return Ok();
        }

        [Authorize(Roles = "Admin")]
        [HttpGet]
        public override Task<Model.PagedResult<Model.User>> Get([FromQuery] UserSearchObject? search = null)
        {
            return base.Get(search);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("{id}")]
        public override Task<Model.User> GetById(int id)
        {
            return base.GetById(id);
        }
    }
}