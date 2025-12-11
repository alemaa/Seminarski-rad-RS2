using CafeEase.Model.SearchObjects;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public interface ICRUDService<T, TSearch, TInsert, TUpdate> : IService<T, TSearch> where TSearch : class
    {
        Task<T> Insert(TInsert insert);
        Task<T> Update(int id, TUpdate update);
        Task<T> Delete(int id);
    }
}
