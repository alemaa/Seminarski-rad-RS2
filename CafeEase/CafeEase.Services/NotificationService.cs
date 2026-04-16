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

        public NotificationService(
            CafeEaseDbContext context,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor
        ) : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        private string GetCurrentUsername()
        {
            var user = _httpContextAccessor.HttpContext?.User;

            if (user == null || user.Identity?.IsAuthenticated != true)
                throw new Exception("User not authenticated");

            var username = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? user.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrWhiteSpace(username))
                throw new Exception("Username not found in claims");

            return username;
        }

        private Database.User GetCurrentDbUser()
        {
            var username = GetCurrentUsername();

            var dbUser = _context.Users
                .Include(u => u.Role)
                .FirstOrDefault(u => u.Username == username);

            if (dbUser == null)
                throw new Exception("User not found");

            return dbUser;
        }

        public override IQueryable<Database.Notification> AddFilter(
            IQueryable<Database.Notification> query,
            NotificationSearchObject? search = null)
        {
            var currentUser = GetCurrentDbUser();

            if (currentUser.RoleId == 2)
            {
                query = query.Where(n => n.UserId == currentUser.Id);
            }

            if (search?.IsRead.HasValue == true)
            {
                query = query.Where(n => n.IsRead == search.IsRead.Value);
            }

            query = query.OrderByDescending(n => n.CreatedAt);

            return query;
        }

        public async Task MarkAsRead(int id)
        {
            var currentUser = GetCurrentDbUser();

            IQueryable<Database.Notification> query = _context.Notifications;

            if (currentUser.RoleId == 2)
            {
                query = query.Where(n => n.UserId == currentUser.Id);
            }

            var notif = await query.FirstOrDefaultAsync(n => n.Id == id);
            if (notif == null) return;

            notif.IsRead = true;
            await _context.SaveChangesAsync();
        }

        public async Task MarkAllAsRead()
        {
            var currentUser = GetCurrentDbUser();

            IQueryable<Database.Notification> query = _context.Notifications
                .Where(n => !n.IsRead);

            if (currentUser.RoleId == 2)
            {
                query = query.Where(n => n.UserId == currentUser.Id);
            }

            var unread = await query.ToListAsync();

            foreach (var n in unread)
                n.IsRead = true;

            await _context.SaveChangesAsync();
        }
    }
}