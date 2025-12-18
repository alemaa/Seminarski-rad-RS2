using AutoMapper;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using System.Linq;

namespace CafeEase.Services
{
    public class InventoryService : BaseCRUDService<Model.Inventory,Database.Inventory,InventorySearchObject,InventoryInsertRequest,InventoryUpdateRequest>,IInventoryService
    {
        public InventoryService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.Inventory> AddFilter(
            IQueryable<Database.Inventory> query,
            InventorySearchObject? search = null)
        {
            if (search?.ProductId.HasValue == true)
            {
                query = query.Where(x => x.ProductId == search.ProductId);
            }

            return base.AddFilter(query, search);
        }
    }
}
