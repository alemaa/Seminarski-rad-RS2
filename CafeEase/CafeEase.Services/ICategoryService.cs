using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;

namespace CafeEase.Services
{
    public interface ICategoryService
        : ICRUDService<Category, CategorySearchObject, CategoryUpsertRequest, CategoryUpsertRequest>
    {
    }
}
