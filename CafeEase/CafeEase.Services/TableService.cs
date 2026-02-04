using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Model.Requests;
using CafeEase.Services.Database;
using System.Linq;
using System;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;
using CafeEase.Model;

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

            if (search?.Number.HasValue == true)
                query = query.Where(t => t.Number == search.Number);

            if (search?.Date.HasValue == true)
            {
                var day = (search?.Date ?? DateTime.Now).Date;

                var occupiedIds = _context.Reservations.Where(r => r.ReservationDateTime.Date == day
                && r.Status != "Cancelled").Select(r => r.TableId).Distinct();

                if (search?.IsOccupied.HasValue == true)
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

        public override async Task<PagedResult<Model.Table>> Get(TableSearchObject? search = null)
        {
            var result = await base.Get(search);

            var day = (search?.Date ?? DateTime.Now).Date;

            var occupiedIds = await _context.Reservations
                .Where(r => r.ReservationDateTime.Date == day && r.Status != "Cancelled")
                .Select(r => r.TableId)
                .Distinct()
                .ToListAsync();

            var occ = new HashSet<int>(occupiedIds);

            foreach (var t in result.Result)
            {
                t.IsOccupied = occ.Contains(t.Id);
            }

            return result;
        }
    }
}
