using CafeEase.Model.SearchObjects;
using CafeEase.Model.Requests;

namespace CafeEase.Services
{
    public interface ICityService : ICRUDService<Model.City, BaseSearchObject, CityUpsertRequest, CityUpsertRequest>
    {
    }
}