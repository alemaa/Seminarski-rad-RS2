using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class NotificationService : BaseService<Model.Notification, Database.Notification, NotificationSearchObject>, INotificationService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public NotificationService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private async Task<int> GetCurrentUserId()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            if (user == null || !user.Identity?.IsAuthenticated == true)
                throw new Exception("User not authenticated");

            var username = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? user.FindFirst(ClaimTypes.Name)?.Value;

            var dbUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
            if (dbUser == null) throw new Exception("User not found");

            return dbUser.Id;
        }

        public override IQueryable<Database.Notification> AddFilter(IQueryable<Database.Notification> query, NotificationSearchObject? search = null)
        {
            query = query.Where(n => n.UserId == GetCurrentUserId().Result);

            if (search?.IsRead.HasValue == true)
                query = query.Where(n => n.IsRead == search.IsRead.Value);

            query = query.OrderByDescending(n => n.CreatedAt);

            return query;
        }

        public async Task MarkAsRead(int id)
        {
            var userId = await GetCurrentUserId();

            var notif = await _context.Notifications.FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);
            if (notif == null) throw new Exception("Notification not found");

            notif.IsRead = true;
            await _context.SaveChangesAsync();
        }

        public async Task MarkAllAsRead()
        {
            var userId = await GetCurrentUserId();

            var unread = await _context.Notifications
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            foreach (var n in unread) n.IsRead = true;

            await _context.SaveChangesAsync();
        }
    }
}