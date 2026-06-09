using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System;
using System.Security.Claims;
using System.Threading.Tasks;
using CafeEase.Services.Exceptions;

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
                throw new UserException("User not authenticated");

            var username = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? user.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrWhiteSpace(username))
                throw new UserException("Username not found in claims");

            return username;
        }

        private Database.User GetCurrentDbUser()
        {
            var username = GetCurrentUsername();

            var dbUser = _context.Users
                .Include(u => u.Role)
                .FirstOrDefault(u => u.Username == username);

            if (dbUser == null)
                throw new UserException("User not found");

            return dbUser;
        }

        public override IQueryable<Database.Notification> AddFilter(
            IQueryable<Database.Notification> query,
            NotificationSearchObject? search = null)
        {
            var currentUser = GetCurrentDbUser();

                query = query.Where(n => n.UserId == currentUser.Id);

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

            IQueryable<Database.Notification> query = _context.Notifications.Where(n => n.UserId == currentUser.Id);

            var notif = await query.FirstOrDefaultAsync(n => n.Id == id);
            if (notif == null) return;

            notif.IsRead = true;
            await _context.SaveChangesAsync();
        }

        public async Task MarkAllAsRead()
        {
            var currentUser = GetCurrentDbUser();

            IQueryable<Database.Notification> query = _context.Notifications
                .Where(n => !n.IsRead && n.UserId == currentUser.Id);

            var unread = await query.ToListAsync();

            foreach (var n in unread)
                n.IsRead = true;

            await _context.SaveChangesAsync();
        }

        public async Task CreateAsync(int userId, string title, string body, int? orderId = null)
        {
            _context.Notifications.Add(new Database.Notification
            {
                UserId = userId,
                OrderId = orderId,
                Title = title,
                Body = body,
                IsRead = false,
                CreatedAt = DateTime.Now
            });

            await _context.SaveChangesAsync();
        }

        public async Task CreateForAdminsAsync(string title, string body, int? orderId = null)
        {
            var adminIds = await _context.Users
                .Where(u => u.RoleId == 1)
                .Select(u => u.Id)
                .ToListAsync();

            foreach (var adminId in adminIds)
            {
                _context.Notifications.Add(new Database.Notification
                {
                    UserId = adminId,
                    OrderId = orderId,
                    Title = title,
                    Body = body,
                    IsRead = false,
                    CreatedAt = DateTime.Now
                });
            }

            await _context.SaveChangesAsync();
        }
    }
}