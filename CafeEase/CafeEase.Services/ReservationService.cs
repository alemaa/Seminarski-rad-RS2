using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, Database.Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>,IReservationService
    {
        public ReservationService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(
            Database.Reservation entity,
            ReservationInsertRequest insert)
        {
            entity.Status = "Pending";
        }

        public override IQueryable<Database.Reservation> AddFilter(
            IQueryable<Database.Reservation> query,
            ReservationSearchObject? search = null)
        {
            if (search?.UserId.HasValue == true)
            {
                query = query.Where(x => x.UserId == search.UserId);
            }

            if (search?.TableId.HasValue == true)
            {
                query = query.Where(x => x.TableId == search.TableId);
            }

            if (!string.IsNullOrWhiteSpace(search?.Status))
            {
                query = query.Where(x => x.Status == search.Status);
            }

            return base.AddFilter(query, search);
        }
    }
}
