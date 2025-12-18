using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;

namespace CafeEase.Services
{
    public interface IInventoryService: ICRUDService<Inventory, InventorySearchObject, InventoryInsertRequest, InventoryUpdateRequest>
    {
    }
}
