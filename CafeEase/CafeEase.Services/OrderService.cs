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
namespace CafeEase.Services
{
    public class OrderService : BaseCRUDService<Model.Order, Database.Order, OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>, IOrderService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public OrderService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task BeforeInsert(Database.Order entity, OrderInsertRequest insert)
        {
            decimal total = 0;

            if (insert.Items != null)
            {
                foreach (var item in insert.Items)
                {
                    var product = await _context.Products.FirstOrDefaultAsync(x => x.Id == item.ProductId);

                    if (product == null)
                        throw new Exception("Product not found");

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
                        Price = product.Price
                    };
                }).ToList();
            }

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
            entity.TotalAmount = total;
            entity.Status = "Pending";
        }
        public override async Task<Model.Order> Update(int id, OrderUpdateRequest update)
        {
            var entity = await _context.Orders.Include(o => o.OrderItems).FirstOrDefaultAsync(o => o.Id == id);

            if (entity == null)
                throw new UserException("Order not found");

            var allowedStatuses = new[] { "Pending", "Confirmed", "Cancelled", "Paid" };

            if (!allowedStatuses.Contains(update.Status))
                throw new UserException("Invalid order status");

            var oldStatus = entity.Status;

            entity.Status = update.Status;

            if (oldStatus != "Paid" && update.Status == "Paid")
            {
                foreach (var item in entity.OrderItems)
                {
                    var inventory = await _context.Inventories.FirstOrDefaultAsync(i => i.ProductId == item.ProductId);

                    if (inventory == null)
                        throw new UserException(
                            $"Inventory not found for product {item.ProductId}"
                        );

                    if (inventory.Quantity < item.Quantity)
                        throw new UserException(
                            $"Not enough stock for product {item.ProductId}"
                        );

                    inventory.Quantity -= item.Quantity;
                }
            }

            await _context.SaveChangesAsync();

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
    }
}
