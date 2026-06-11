using AutoMapper;
using CafeEase.Model.Responses;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CafeEase.Services;

public class ReportService : IReportService
{
    private readonly CafeEaseDbContext _context;
    private readonly IMapper _mapper;

    public ReportService(CafeEaseDbContext context, IMapper mapper)
    {
        _context = context;
        _mapper = mapper;
    }

    public async Task<ReportDataResponse> GetData()
    {
        var orders = await _context.Orders
            .AsNoTracking()
            .Include(o => o.User)
            .Include(o => o.Table)
            .OrderBy(o => o.Id)
            .ToListAsync();

        var inventory = await _context.Inventories
            .AsNoTracking()
            .Include(i => i.Product)
            .OrderBy(i => i.Product.Name)
            .ToListAsync();

        var paidItems = await _context.OrderItems
            .AsNoTracking()
            .Include(i => i.Product)
            .Include(i => i.Order)
            .Where(i =>
                i.Order.Status == OrderStatuses.Paid ||
                i.Order.Status == OrderStatuses.Completed)
            .ToListAsync();

        return new ReportDataResponse
        {
            Orders = _mapper.Map<List<Model.Order>>(orders),
            Inventory = _mapper.Map<List<Model.Inventory>>(inventory),
            PaidOrderItems = _mapper.Map<List<Model.OrderItem>>(paidItems)
        };
    }
}
