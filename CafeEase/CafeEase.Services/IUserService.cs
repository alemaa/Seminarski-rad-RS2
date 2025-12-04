using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public interface IUserService
        : ICRUDService<Model.User, Model.SearchObjects.UserSearchObject, Model.Requests.UserInsertRequest, Model.Requests.UserUpdateRequest>
    {
        public Task<Model.User> Login(string username, string password);
    }
}