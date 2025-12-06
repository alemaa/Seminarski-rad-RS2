using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public interface IProductService
        : ICRUDService<Product, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        List<Product> Recommend(int userId);
        Task<List<string>> AllowedActions(int id);
    }
}
