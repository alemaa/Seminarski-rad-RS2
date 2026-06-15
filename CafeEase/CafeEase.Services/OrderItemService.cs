using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services;
using System.Linq;
using System;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using CafeEase.Model.Exceptions;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace CafeEase.Services
{
    public class OrderItemService : BaseCRUDService<Model.OrderItem, Database.OrderItem, OrderItemSearchObject, OrderItemInsertRequest, OrderItemUpdateRequest>, IOrderItemService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public OrderItemService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public override IQueryable<Database.OrderItem> AddFilter(
            IQueryable<Database.OrderItem> query,
            OrderItemSearchObject? search = null)
        {
            if (!IsAdmin())
            {
                var username = GetCurrentUsername();

                query = query.Where(x => x.Order.User.Username == username);
            }

            if (search?.OrderId.HasValue == true)
                query = query.Where(x => x.OrderId == search.OrderId.Value);

            if (search?.PaidOnly == true)
                query = query.Where(x => x.Order.Status == OrderStatuses.Paid);

            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.OrderItem> AddInclude(IQueryable<Database.OrderItem> query, OrderItemSearchObject? search = null)
        {
            return query
                .Include(x => x.Product)
                .Include(x => x.Order)
                .ThenInclude(o => o.User);
        }

        public override async Task BeforeInsert(
            Database.OrderItem entity,
            OrderItemInsertRequest insert)
        {
            var product = await _context.Products.FindAsync(insert.ProductId);

            if (product == null)
                throw new UserException("Product not found");

            entity.ProductId = insert.ProductId;
            entity.Quantity = insert.Quantity;
            entity.Price = product.Price;
        }

        public override async Task<Model.OrderItem> GetById(int id)
        {
            var entity = await _context.OrderItems
                .Include(x => x.Product)
                .Include(x => x.Order)
                .ThenInclude(o => o.User)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                throw new NotFoundException("Order item not found.");

            if (!IsAdmin() &&
                entity.Order.User.Username != GetCurrentUsername())
            {
                throw new ForbiddenException(
                    "You cannot access this order item."
                );
            }

            return _mapper.Map<Model.OrderItem>(entity);
        }

        public override Task<Model.OrderItem> Insert(OrderItemInsertRequest insert)
        {
            throw new ForbiddenException("Order items can only be created through an order.");
        }

        public override async Task<Model.OrderItem> Update(int id, OrderItemUpdateRequest update)
        {
            if (!IsAdmin())
                throw new ForbiddenException("Only administrators can update order items.");

            return await base.Update(id, update);
        }

        private string GetCurrentUsername()
        {
            return _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? throw new UserException("User not authenticated.");
        }

        public override async Task<Model.OrderItem> Delete(int id)
        {
            if (!IsAdmin())
                throw new ForbiddenException("Only administrators can delete order items.");

            return await base.Delete(id);
        }

        private bool IsAdmin()
        {
            return _httpContextAccessor.HttpContext?.User.IsInRole("Admin") == true;
        }
    }
}
