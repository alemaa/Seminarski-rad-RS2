using CafeEase.Model.Requests;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UsersController : BaseCRUDController<Model.User, Model.SearchObjects.UserSearchObject, Model.Requests.UserInsertRequest, Model.Requests.UserUpdateRequest>
    {
        public UsersController(ILogger<BaseController<Model.User, Model.SearchObjects.UserSearchObject>> logger, IUserService service) : base(logger, service)
        {
        }
        [AllowAnonymous]
        public override Task<Model.User> Insert([FromBody] UserInsertRequest insert)
        {
            return base.Insert(insert);
        }
    }
}