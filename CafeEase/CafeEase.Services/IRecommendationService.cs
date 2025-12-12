using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace CafeEase.Services;
public interface IRecommendationService
{ 
    Task TrainModel();
    Task DeleteAll();
    Task<List<Model.Product>> GetRecommendedProducts(int productId);
}
