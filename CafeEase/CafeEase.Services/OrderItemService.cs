using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services;
using System.Linq;
using System;
using System.Threading.Tasks;
namespace CafeEase.Services
{
    public class OrderItemService : BaseCRUDService<Model.OrderItem, Database.OrderItem, OrderItemSearchObject, OrderItemInsertRequest, OrderItemUpdateRequest>, IOrderItemService
    {
        public OrderItemService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.OrderItem> AddFilter(
            IQueryable<Database.OrderItem> query,
            OrderItemSearchObject? search = null)
        {
            if (search?.OrderId.HasValue == true)
                query = query.Where(x => x.OrderId == search.OrderId);

            return base.AddFilter(query, search);
        }

        public override async Task BeforeInsert(
            Database.OrderItem entity,
            OrderItemInsertRequest insert)
        {
            var product = await _context.Products.FindAsync(insert.ProductId);

            if (product == null)
                throw new Exception("Product not found");

            entity.Price = product.Price;
        }
    }
}