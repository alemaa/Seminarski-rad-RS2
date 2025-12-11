using AutoMapper;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class ProductService : BaseCRUDService<Model.Product, Database.Product, ProductSearchObject, ProductInsertRequest, ProductUpdateRequest>,IProductService
    {
        public ProductService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.Product> AddFilter(IQueryable<Database.Product> query, ProductSearchObject? search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.NameFTS))
            {
                query = query.Where(p => p.Name.Contains(search.NameFTS));
            }

            if (search?.CategoryId.HasValue == true)
            {
                query = query.Where(p => p.CategoryId == search.CategoryId);
            }

            return base.AddFilter(query, search);
        }

        public async Task<List<string>> AllowedActions(int id)
        {
            var result = new List<string>();

            var product = await _context.Products.FindAsync(id);
            if (product == null)
                return result;
            result.Add("Edit");

            var usedInOrders = await _context.OrderItems
                .AnyAsync(oi => oi.ProductId == id);

            if (!usedInOrders)
            {
                result.Add("Delete");
            }

            return result;
        }
        public List<Model.Product> Recommend(int id)
        {
            var product = _context.Products.Find(id);

            if (product == null)
                return new List<Model.Product>();

            var query = _context.Products
                .Where(p => p.CategoryId == product.CategoryId && p.Id != id)
                .OrderByDescending(p => p.Name)
                .Take(3) .ToList();


            return _mapper.Map<List<Model.Product>>(query);
        }
    }
}
