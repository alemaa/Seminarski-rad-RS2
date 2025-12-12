using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using System.Linq;

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

        var orders = _context.Orders
            .Include(o => o.OrderItems)
            .ToList();

        var pairs = new Dictionary<(int, int), int>();

        foreach (var order in orders)
        {
            var items = order.OrderItems
                .Select(x => x.ProductId)
                .Distinct()
                .ToList();

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

        var grouped = pairs
            .GroupBy(x => x.Key.Item1)
            .ToDictionary(
                g => g.Key,
                g => g.OrderByDescending(p => p.Value).Take(3).ToList()
            );

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

    public async Task<List<Model.Product>> GetRecommendedProducts(int productId)
    {
        var recs = _context.Recommendations
            .Where(r => r.ProductId == productId)
            .OrderByDescending(r => r.Score)
            .Take(3)
            .ToList();

        var products = recs
            .Select(r => r.RecommendedProductId)
            .ToList();

        var dbProducts = _context.Products
            .Where(p => products.Contains(p.Id))
            .ToList();

        return _mapper.Map<List<Model.Product>>(dbProducts);
    }
}
