using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services;
using System;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using CafeEase.Services.Exceptions;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;
using System.Collections.Generic;
using CafeEase.Model.Responses;

namespace CafeEase.Services
{
    public class OrderService : BaseCRUDService<Model.Order, Database.Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>, IOrderService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly INotificationService _notificationService;
        public OrderService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor, INotificationService notificationService)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
            _notificationService = notificationService;
        }

        public override async Task BeforeInsert(Database.Order entity, OrderInsertRequest insert)
        {
            decimal total = 0;

            if (insert.Items == null || !insert.Items.Any())
                throw new UserException("Order must contain at least one item.");

            if (insert.Items.Any(i => i.Quantity < 1))
                throw new UserException("Order item quantity must be at least 1.");

            var tableExists = await _context.Tables.AnyAsync(t => t.Id == insert.TableId);

            if (!tableExists)
                throw new UserException("Selected table does not exist.");

            foreach (var item in insert.Items)
            {
                var product = await _context.Products.FirstOrDefaultAsync(x => x.Id == item.ProductId);

                if (product == null)
                    throw new UserException("Product not found.");

                var lineAmount = product.Price * item.Quantity;
                total += lineAmount;
            }

            entity.OrderItems = insert.Items.Select(item =>
            {
                var product = _context.Products.First(x => x.Id == item.ProductId);

                return new Database.OrderItem
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    Price = product.Price,
                    Size = item.Size,
                    MilkType = item.MilkType,
                    SugarLevel = item.SugarLevel,
                    Note = item.Note,
                };
            }).ToList();

            var user = _httpContextAccessor.HttpContext?.User;

            if (user == null || !user.Identity.IsAuthenticated)
                throw new UserException("User not authenticated");

            var username = user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? user.FindFirst(ClaimTypes.Name)?.Value;

            var dbUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (dbUser == null)
                throw new UserException("User not found");

            entity.UserId = dbUser.Id;

            entity.TableId = insert.TableId;

            entity.OrderDate = DateTime.Now;
            entity.TotalAmount = await ApplyPromotionDiscount(total, entity.OrderItems.ToList(), dbUser.Id);
            entity.Status = OrderStatuses.Pending;
        }
        public override async Task<Model.Order> Update(int id, OrderUpdateRequest update)
        {
            var entity = await _context.Orders.Include(o => o.OrderItems).FirstOrDefaultAsync(o => o.Id == id);

            if (entity == null)
                throw new UserException("Order not found");

            if (string.IsNullOrWhiteSpace(update.Status))
                throw new UserException("Order status is required.");

            var newStatus = update.Status;

            if (!OrderStatuses.All.Contains(newStatus))
                throw new UserException("Invalid order status.");

            if (!OrderStatuses.AllowedTransitions.TryGetValue(entity.Status, out var allowedNextStatuses) ||
                !allowedNextStatuses.Contains(newStatus))
            {
                throw new UserException($"Order status cannot change from {entity.Status} to {newStatus}.");
            }

            entity.Status = newStatus;

            await _context.SaveChangesAsync();

            var orderOwner = await _context.Users.FirstOrDefaultAsync(u => u.Id == entity.UserId);

            var body = orderOwner?.RoleId == 1
                ? $"Order #{entity.Id} status changed to {entity.Status}."
                : $"Your order #{entity.Id} status changed to {entity.Status}.";

            await _notificationService.CreateAsync(
                entity.UserId,
                "Order status updated",
                body,
                entity.Id);

            return _mapper.Map<Model.Order>(entity);
        }

        public override IQueryable<Database.Order> AddInclude(IQueryable<Database.Order> query, OrderSearchObject? search = null)
        {
            return query
                .Include(o => o.User)
                .Include(o => o.Table);
        }
        public override IQueryable<Database.Order> AddFilter(IQueryable<Database.Order> query, OrderSearchObject? search = null)
        {
            if (search == null)
                return base.AddFilter(query, search);

            if (search.OrderId.HasValue)
                query = query.Where(o => o.Id == search.OrderId);

            if (search.UserId.HasValue)
                query = query.Where(o => o.UserId == search.UserId);

            if (!string.IsNullOrWhiteSpace(search.UserName))
            {
                var userName = search.UserName.ToLower();

                query = query.Where(o =>
                    o.User.FirstName.ToLower().Contains(userName) ||
                    o.User.LastName.ToLower().Contains(userName));
            }

            if (search.TableId.HasValue)
                query = query.Where(o => o.TableId == search.TableId);

            if (!string.IsNullOrWhiteSpace(search.Status))
                query = query.Where(o => o.Status == search.Status);

            if (search.Date.HasValue)
            {
                var date = search.Date.Value.Date;
                query = query.Where(o => o.OrderDate.Date == date);
            }

            return base.AddFilter(query, search);
        }

        private static string GetUserSegment(int points)
        {
            if (points >= 50) return "VIP";
            if (points >= 20) return "NEW";
            return "ALL";
        }

        private async Task<decimal> ApplyPromotionDiscount(decimal subtotal, List<Database.OrderItem> items, int userId)
        {
            var points = await _context.LoyaltyPoints
                .Where(x => x.UserId == userId)
                .Select(x => (int?)x.Points)
                .FirstOrDefaultAsync() ?? 0;

            var segment = GetUserSegment(points);
            var now = DateTime.Now;

            var promotions = await _context.Promotions
                .Include(p => p.PromotionCategories)
                .Where(p =>
                    p.StartDate <= now &&
                    p.EndDate >= now &&
                    (p.TargetSegment == "ALL" || p.TargetSegment == segment))
                .ToListAsync();

            if (!promotions.Any())
                return subtotal;

            decimal discountedTotal = 0;

            foreach (var item in items)
            {
                var product = await _context.Products.AsNoTracking()
                    .FirstAsync(p => p.Id == item.ProductId);

                var lineTotal = item.Price * item.Quantity;

                var bestDiscount = promotions
                    .Where(p => p.PromotionCategories.Any(pc => pc.CategoryId == product.CategoryId))
                    .Select(p => (decimal)p.DiscountPercent)
                    .DefaultIfEmpty(0)
                    .Max();

                discountedTotal += lineTotal - (lineTotal * bestDiscount / 100m);
            }

            return Math.Round(discountedTotal, 2);
        }

        public override async Task<Model.Order> Insert(OrderInsertRequest insert)
        {
            var result = await base.Insert(insert);

            var orderOwner = await _context.Users.FirstOrDefaultAsync(u => u.Id == result.UserId);

            var body = orderOwner?.RoleId == 1
                ? $"Order #{result.Id} has been created and is waiting for confirmation."
                : $"Your order #{result.Id} has been created and is waiting for confirmation.";

            if (orderOwner?.RoleId != 1)
            {
                await _notificationService.CreateAsync(
                    result.UserId,
                    "Order created",
                    body,
                    result.Id);
            }

            await _notificationService.CreateForAdminsAsync(
                "New order created",
                $"Order #{result.Id} was created and is waiting for confirmation.",
                result.Id);

            return result;
        }

        public async Task<OrderTotalPreviewResponse> PreviewTotal(OrderInsertRequest request)
        {
            var user = _httpContextAccessor.HttpContext?.User;

            if (user == null || user.Identity?.IsAuthenticated != true)
                throw new UserException("User not authenticated");

            var username = user.FindFirst(ClaimTypes.NameIdentifier)?.Value
                           ?? user.FindFirst(ClaimTypes.Name)?.Value;

            var dbUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (dbUser == null)
                throw new UserException("User not found");

            if (request.Items == null || !request.Items.Any())
                throw new UserException("Order must contain at least one item.");

            if (request.Items.Any(i => i.Quantity < 1))
                throw new UserException("Order item quantity must be at least 1.");

            var tableExists = await _context.Tables.AnyAsync(t => t.Id == request.TableId);

            if (!tableExists)
                throw new UserException("Selected table does not exist.");

            decimal subtotal = 0;
            var orderItems = new List<Database.OrderItem>();

            foreach (var item in request.Items)
            {
                var product = await _context.Products.FirstOrDefaultAsync(x => x.Id == item.ProductId);

                if (product == null)
                    throw new UserException("Product not found");

                subtotal += product.Price * item.Quantity;

                orderItems.Add(new Database.OrderItem
                {
                    ProductId = item.ProductId,
                    Quantity = item.Quantity,
                    Price = product.Price,
                    Size = item.Size,
                    MilkType = item.MilkType,
                    SugarLevel = item.SugarLevel,
                    Note = item.Note
                });
            }

            var total = await ApplyPromotionDiscount(subtotal, orderItems, dbUser.Id);

            return new OrderTotalPreviewResponse
            {
                Subtotal = subtotal,
                DiscountAmount = subtotal - total,
                TotalAmount = total
            };
        }
    }
}
