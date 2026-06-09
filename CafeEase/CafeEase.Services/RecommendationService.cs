using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using CafeEase.Model.Responses;

namespace CafeEase.Services;
public class RecommendationService : IRecommendationService
{
    private readonly CafeEaseDbContext _context;
    private readonly IMapper _mapper;
    public RecommendationService(CafeEaseDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task TrainModel()
    {
        _context.Recommendations.RemoveRange(_context.Recommendations);
        await _context.SaveChangesAsync();

        var orders = _context.Orders.Include(o => o.OrderItems).ToList();
        var pairs = new Dictionary<(int, int), int>();

        foreach (var order in orders)
        {
            var items = order.OrderItems.Select(x => x.ProductId).Distinct().ToList();

            for (int i = 0; i < items.Count; i++)
            {
                for (int j = 0; j < items.Count; j++)
                {
                    if (i == j) continue;

                    var key = (items[i], items[j]);

                    if (!pairs.ContainsKey(key))
                        pairs[key] = 0;

                    pairs[key]++;
                }
            }
        }

        var grouped = pairs.GroupBy(x => x.Key.Item1).ToDictionary( g => g.Key, g => g.OrderByDescending(p => p.Value).Take(3).ToList());

        foreach (var kvp in grouped)
        {
            var productId = kvp.Key;

            foreach (var rec in kvp.Value)
            {
                _context.Recommendations.Add(new Database.Recommendation
                {
                    ProductId = productId,
                    RecommendedProductId = rec.Key.Item2,
                    Score = rec.Value
                });
            }
        }
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAll()
    {
        _context.Recommendations.RemoveRange(_context.Recommendations);
        await _context.SaveChangesAsync();
    }

    public async Task<List<RecommendedProductResponse>> GetRecommendedProducts(int productId)
    {
        var seedProduct = await _context.Products.AsNoTracking().FirstOrDefaultAsync(p => p.Id == productId);

        var seedName = seedProduct?.Name ?? "selected product";

        var recs = await _context.Recommendations.Where(r => r.ProductId == productId && r.RecommendedProductId != productId).OrderByDescending(r => r.Score)
            .Take(3).ToListAsync();

        if (recs.Any())
        {
            var productIds = recs.Select(r => r.RecommendedProductId).ToList();

            var products = await _context.Products.AsNoTracking().Where(p => productIds.Contains(p.Id)).ToListAsync();

            return recs
                .Select(r =>
                {
                    var product = products.FirstOrDefault(p => p.Id == r.RecommendedProductId);
                    if (product == null) return null;

                    return new RecommendedProductResponse
                    {
                        Product = _mapper.Map<Model.Product>(product),
                        Score = r.Score,
                        Reason = $"Recommended because it is often ordered together with {seedName}."
                    };
                })
                .Where(x => x != null).ToList()!;
        }

        var popular = await _context.OrderItems.Where(oi => oi.ProductId != productId).GroupBy(oi => oi.ProductId).Select(g => new
            {
                ProductId = g.Key,
                Score = g.Count()
            }).OrderByDescending(x => x.Score).Take(3).ToListAsync();

        var popularIds = popular.Select(x => x.ProductId).ToList();

        var fallbackProducts = await _context.Products.AsNoTracking().Where(p => popularIds.Contains(p.Id)).ToListAsync();

        return popular
            .Select(r =>
            {
                var product = fallbackProducts.FirstOrDefault(p => p.Id == r.ProductId);
                if (product == null) return null;

                return new RecommendedProductResponse
                {
                    Product = _mapper.Map<Model.Product>(product),
                    Score = r.Score,
                    Reason = "Recommended because it is one of the most ordered products."
                };
            })
            .Where(x => x != null).ToList()!;
    }
}
