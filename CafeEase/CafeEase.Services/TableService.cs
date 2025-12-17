using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Model.Requests;
using CafeEase.Services.Database;
using System.Linq;

namespace CafeEase.Services
{
    public class TableService : BaseCRUDService<Model.Table, Database.Table, TableSearchObject, TableInsertRequest, TableUpdateRequest>, ITableService
    {
        public TableService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.Table> AddFilter(
            IQueryable<Database.Table> query,
            TableSearchObject? search = null)
        {
            if (search?.IsOccupied.HasValue == true)
            {
                query = query.Where(x => x.IsOccupied == search.IsOccupied);
            }

            if (search?.Capacity.HasValue == true)
            {
                query = query.Where(x => x.Capacity >= search.Capacity);
            }

            return base.AddFilter(query, search);
        }
    }
}
