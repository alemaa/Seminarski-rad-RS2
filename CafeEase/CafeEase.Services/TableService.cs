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
            if (search?.Capacity.HasValue == true)
            {
                query = query.Where(x => x.Capacity >= search.Capacity);
            }

            if (search?.Date.HasValue == true)
            {
                var day = search.Date.Value.Date;

                var occupiedIds = _context.Reservations.Where(r => r.ReservationDateTime.Date == day
                && r.Status != "Cancelled").Select(r => r.TableId).Distinct();

                if (search.IsOccupied.HasValue)
                {
                    if (search.IsOccupied.Value) {
                        query = query.Where(t => occupiedIds.Contains(t.Id));
                    }

                    else {
                        query = query.Where(t => !occupiedIds.Contains(t.Id));
                    }
                }
            }

            return base.AddFilter(query, search);
        }
    }
}
