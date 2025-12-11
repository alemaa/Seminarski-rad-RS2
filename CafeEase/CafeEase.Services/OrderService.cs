using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services;
using System;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.EntityFrameworkCore;
namespace CafeEase.Services {
    public class OrderService : BaseCRUDService< Model.Order, Database.Order,OrderSearchObject, OrderInsertRequest, OrderUpdateRequest>, IOrderService
    {
        public OrderService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(Database.Order entity,OrderInsertRequest insert)
        {
            decimal total = 0;

            if (insert.Items != null)
            {
                foreach (var item in insert.Items)
                {
                    var product = await _context.Products
                        .FirstOrDefaultAsync(x => x.Id == item.ProductId);

                    if (product == null)
                        throw new Exception("Product not found");

                    var lineAmount = product.Price * item.Quantity;
                    total += lineAmount;
                }

                entity.OrderItems = insert.Items.Select(item =>
                {
                    var product = _context.Products
                        .First(x => x.Id == item.ProductId);

                    return new Database.OrderItem
                    {
                        ProductId = item.ProductId,
                        Quantity = item.Quantity,
                        Price = product.Price 
                    };
                }).ToList();
            }

            entity.UserId = insert.UserId;
            entity.TableId = insert.TableId;
            entity.CityId = insert.CityId;

            entity.OrderDate = DateTime.Now;
            entity.TotalAmount = total;
            entity.Status = "New";
        }
        public override IQueryable<Database.Order> AddFilter(
            IQueryable<Database.Order> query,
            OrderSearchObject? search = null)
        {
            if (search?.UserId.HasValue == true)
                query = query.Where(x => x.UserId == search.UserId);

            if (search?.TableId.HasValue == true)
                query = query.Where(x => x.TableId == search.TableId);

            if (!string.IsNullOrWhiteSpace(search?.Status))
                query = query.Where(x => x.Status == search.Status);

            return base.AddFilter(query, search);
        }
    }
}
