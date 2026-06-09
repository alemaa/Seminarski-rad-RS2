using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using System.Collections.Generic;
using System.Threading.Tasks;
using CafeEase.Model.Responses;

namespace CafeEase.Services;
public interface IRecommendationService
{ 
    Task TrainModel();
    Task DeleteAll();
    Task<List<RecommendedProductResponse>> GetRecommendedProducts(int productId);
}
