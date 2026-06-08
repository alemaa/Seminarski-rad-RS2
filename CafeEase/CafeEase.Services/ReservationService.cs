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
using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using System.Linq.Expressions;

namespace CafeEase.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, Database.Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public ReservationService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task BeforeInsert(Database.Reservation entity, ReservationInsertRequest insert)
        {
            var userIdentifier = _httpContextAccessor.HttpContext?.User?
                .Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
   
            if (string.IsNullOrWhiteSpace(userIdentifier))
                throw new UserException("User not authenticated");

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == userIdentifier);

            if (user == null)
                throw new UserException("User not found");

            entity.UserId = user.Id;

            var table = await _context.Tables.FindAsync(insert.TableId);

            if (table == null)
            {
                throw new UserException("Selected table does not exist");
            }

            var requestedStart = insert.ReservationDateTime;
            var requestedDuration = insert.DurationMinutes;

            var reservationsForTable = await _context.Reservations
                .Where(r =>
                    r.TableId == insert.TableId &&
                    r.Status != ReservationStatuses.Cancelled)
                .ToListAsync();

            var hasOverlap = reservationsForTable.Any(r =>
                Overlaps(requestedStart, requestedDuration, r.ReservationDateTime, r.DurationMinutes));

            if (hasOverlap)
                throw new UserException("Selected table is already reserved for that time.");

            if(insert.ReservationDateTime.Date == DateTime.Today)
            {
                table.IsOccupied = true;
            }

            if (insert.NumberOfGuests > table.Capacity)
            {
                throw new UserException("Table capacity is " + table.Capacity + ". Cannnot reserve for " + insert.NumberOfGuests + " guests.");
            }

            entity.DurationMinutes = insert.DurationMinutes;
            entity.Status = ReservationStatuses.Pending;
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

            if (search?.Date.HasValue == true)
            {
                var date = search.Date.Value.Date;
                query = query.Where(x => x.ReservationDateTime.Date == date);
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

            var targetTableId = update.TableId ?? entity.TableId;
            var targetStart = update.ReservationDateTime ?? entity.ReservationDateTime;
            var targetDuration = update.DurationMinutes ?? entity.DurationMinutes;
            var targetGuests = update.NumberOfGuests ?? entity.NumberOfGuests;

            var table = entity.Table;
            if (table == null || table.Id != targetTableId)
                table = await _context.Tables.FindAsync(targetTableId);

            if (table == null)
                throw new UserException("Table not found");

            if (targetGuests > table.Capacity)
                throw new UserException($"Table capacity is {table.Capacity}. Cannot reserve for {targetGuests} guests.");

            var reservationsForTable = await _context.Reservations
                .Where(r =>
                    r.Id != id &&
                    r.TableId == targetTableId &&
                    r.Status != ReservationStatuses.Cancelled)
                .ToListAsync();

            var hasOverlap = reservationsForTable.Any(r =>
                Overlaps(
                    targetStart,
                    targetDuration,
                    r.ReservationDateTime,
                    r.DurationMinutes));

            if (hasOverlap)
                throw new UserException("Selected table is already reserved for that time.");

            var oldStatus = entity.Status;
            var oldTableId = entity.TableId;

            if (!string.IsNullOrWhiteSpace(update.Status))
            {
                var newStatus = update.Status;

                if (newStatus == ReservationStatuses.Cancelled)
                    throw new UserException("Use the cancellation endpoint to cancel a reservation.");

                if (!ReservationStatuses.All.Contains(newStatus))
                    throw new UserException("Invalid reservation status.");

                if (!ReservationStatuses.AllowedTransitions.TryGetValue(oldStatus, out var allowedNextStatuses) ||
                    !allowedNextStatuses.Contains(newStatus))
                {
                    throw new UserException($"Reservation status cannot change from {oldStatus} to {newStatus}.");
                }
            }

            _mapper.Map(update, entity);

            if (string.IsNullOrWhiteSpace(update.Status))
                entity.Status = oldStatus;

            if (update.TableId == null)
                entity.TableId = oldTableId;

            if (update.DurationMinutes == null)
                entity.DurationMinutes = targetDuration;

            if (oldStatus != ReservationStatuses.Cancelled && entity.Status == ReservationStatuses.Cancelled)
            {
                if (table != null && entity.ReservationDateTime.Date == DateTime.Today)
                {
                    var anyOtherToday = await _context.Reservations
                        .Where(r =>
                            r.Id != id &&
                            r.TableId == table.Id &&
                            r.Status != ReservationStatuses.Cancelled)
                        .ToListAsync();

                    table.IsOccupied = anyOtherToday.Any(r =>
                        Overlaps(
                            DateTime.Now,
                            1,
                            r.ReservationDateTime,
                            r.DurationMinutes));
                }
            }
            else if (oldStatus == ReservationStatuses.Cancelled &&
                     (entity.Status == ReservationStatuses.Pending || entity.Status == ReservationStatuses.Confirmed))
            {
                if (table != null &&
                    Overlaps(DateTime.Now, 1, entity.ReservationDateTime, entity.DurationMinutes))
                {
                    table.IsOccupied = true;
                }
            }

            await _context.SaveChangesAsync();
            return _mapper.Map<Model.Reservation>(entity);
        }

        public override async Task BeforeUpdate(Database.Reservation entity, ReservationUpdateRequest update)
        {
           
        }
        public override IQueryable<Database.Reservation> AddInclude(IQueryable<Database.Reservation> query,ReservationSearchObject? search = null)
        {
            return query.Include(r => r.User).Include(r => r.Table);
        }

        public override async Task<Model.Reservation> Delete(int id)
        {
            return await Cancel(id, new ReservationCancelRequest
            {
                CancellationReason = "Cancelled via delete endpoint"
            });
        }

        public async Task<Model.Reservation> Cancel(int id, ReservationCancelRequest request)
        {
            var entity = await _context.Reservations
                .Include(r => r.Table)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new UserException("Reservation not found");

            if (entity.Status == ReservationStatuses.Cancelled)
                return _mapper.Map<Model.Reservation>(entity);

            if (!ReservationStatuses.AllowedTransitions.TryGetValue(entity.Status, out var allowedNextStatuses) ||
                !allowedNextStatuses.Contains(ReservationStatuses.Cancelled))
            {
                throw new UserException($"Reservation status cannot change from {entity.Status} to {ReservationStatuses.Cancelled}.");
            }

            var username = _httpContextAccessor.HttpContext?.User?
                .FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? _httpContextAccessor.HttpContext?.User?
                    .FindFirst(ClaimTypes.Name)?.Value;

            var currentUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (currentUser == null)
                throw new UserException("User not found");

            entity.Status = ReservationStatuses.Cancelled;
            entity.CancelledAt = DateTime.Now;
            entity.CancelledByUserId = currentUser.Id;
            entity.CancellationReason = request.CancellationReason.Trim();

            if (entity.Table != null)
            {
                var otherReservations = await _context.Reservations.Where(r => r.Id != id && r.TableId == entity.TableId && r.Status != ReservationStatuses.Cancelled).ToListAsync();

                entity.Table.IsOccupied = otherReservations.Any(r => Overlaps(DateTime.Now, 1, r.ReservationDateTime, r.DurationMinutes));
            }

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Reservation>(entity);
        }

        private static bool Overlaps(DateTime startA, int durationA, DateTime startB, int durationB)
        {
            var endA = startA.AddMinutes(durationA);
            var endB = startB.AddMinutes(durationB);

            return startA < endB && startB < endA;
        }
    }
}
