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
    }
}