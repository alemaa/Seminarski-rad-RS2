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
                var requestedStart = search.Date.Value;
                var requestedDuration = search.DurationMinutes ?? 120;

                var occupiedIds = _context.Reservations.Where(r => r.Status != ReservationStatuses.Cancelled).AsEnumerable().Where(r => Overlaps(
                        requestedStart,
                        requestedDuration,
                        r.ReservationDateTime,
                        r.DurationMinutes)).Select(r => r.TableId).Distinct().ToList();

                if (search?.IsOccupied.HasValue == true)
                {
                    if (search.IsOccupied.Value)
                    {
                        query = query.Where(t => occupiedIds.Contains(t.Id));
                    }
                    else
                    {
                        query = query.Where(t => !occupiedIds.Contains(t.Id));
                    }
                }
            }

            return base.AddFilter(query, search);
        }

        public override async Task<PagedResult<Model.Table>> Get(TableSearchObject? search = null)
        {
            var result = await base.Get(search);


            if (search?.Date.HasValue != true)
                return result;

            var requestedStart = search!.Date!.Value;
            var requestedDuration = search?.DurationMinutes ?? 120;

            var reservations = await _context.Reservations
                .Where(r => r.Status != ReservationStatuses.Cancelled)
                .ToListAsync();

            var occupiedIds = reservations.Where(r => Overlaps(requestedStart, requestedDuration, r.ReservationDateTime, r.DurationMinutes)).Select(r => r.TableId).Distinct().ToList();

            var occ = new HashSet<int>(occupiedIds);

            foreach (var t in result.Result)
            {
                t.IsOccupied = occ.Contains(t.Id);
            }

            return result;
        }

        private static bool Overlaps(DateTime startA, int durationA, DateTime startB, int durationB)
        {
            var endA = startA.AddMinutes(durationA);
            var endB = startB.AddMinutes(durationB);

            return startA < endB && startB < endA;
        }
    }
}
