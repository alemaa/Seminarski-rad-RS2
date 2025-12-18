using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services.Exceptions;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, Database.Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        public ReservationService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(Database.Reservation entity, ReservationInsertRequest insert)
        {
            var table = await _context.Tables.FindAsync(insert.TableId);
            if (table == null)
            {
                throw new UserException("Selected table does not exist");
            }
            if(table.IsOccupied)
            {
                throw new UserException("Selected table is already occupied");
            }

            if(insert.NumberOfGuests > table.Capacity)
            {
                throw new UserException("Table capacity is " + table.Capacity +". Cannnot reserve for " + insert.NumberOfGuests + " guests.");
            }
            table.IsOccupied = true;
            entity.UserId = 1;
            entity.Status = "Pending";
        }

        public override IQueryable<Database.Reservation> AddFilter(IQueryable<Database.Reservation> query, ReservationSearchObject? search = null)
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

        public override async Task<Model.Reservation> Update(int id, ReservationUpdateRequest update)
        {
            var entity = await _context.Reservations
                .Include(r => r.Table)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new UserException("Reservation not found");

            var oldStatus = entity.Status;

            _mapper.Map(update, entity);

            if (oldStatus != "Cancelled" && entity.Status == "Cancelled")
            {
                if (entity.Table != null)
                {
                    entity.Table.IsOccupied = false;
                }
            }

            if (oldStatus == "Cancelled" &&
                (entity.Status == "Pending" || entity.Status == "Confirmed"))
            {
                if (entity.Table == null)
                    throw new UserException("Table not found");

                if (entity.Table.IsOccupied)
                    throw new UserException("Table is already occupied");

                entity.Table.IsOccupied = true;
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Reservation>(entity);
        }

        public override async Task BeforeUpdate(Database.Reservation entity, ReservationUpdateRequest update)
        {
           
        }
        public override IQueryable<Database.Reservation> AddInclude(IQueryable<Database.Reservation> query,ReservationSearchObject? search = null)
        {
            return query.Include(r => r.Table);
        }

        public override async Task<Model.Reservation> Delete(int id)
        {
            var entity = await _context.Reservations.FindAsync(id);
            if (entity == null)
                return null;

            var table = await _context.Tables.FindAsync(entity.TableId);
            if (table != null)
            {
                table.IsOccupied = false;
            }

            _context.Reservations.Remove(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Reservation>(entity);
        }
    }
}
