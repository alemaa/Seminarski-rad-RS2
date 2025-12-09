using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class PaymentService
        : BaseCRUDService<
            Model.Payment,
            Database.Payment,
            PaymentSearchObject,
            PaymentInsertRequest,
            PaymentUpdateRequest>,
          IPaymentService
    {
        public PaymentService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(
            Database.Payment entity,
            PaymentInsertRequest insert)
        {
            entity.Status = "Completed";

            var order = await _context.Orders.FindAsync(insert.OrderId);
            if (order != null)
            {
                order.Status = "Paid";
            }

            var loyalty = _context.LoyaltyPoints.FirstOrDefault(x => x.UserId == order.UserId);
            if (loyalty != null)
            {
                loyalty.Points += (int)(order.TotalAmount / 10);
            }
        }

        public override IQueryable<Database.Payment> AddFilter(
            IQueryable<Database.Payment> query,
            PaymentSearchObject? search = null)
        {
            if (search?.OrderId.HasValue == true)
                query = query.Where(x => x.OrderId == search.OrderId);

            if (!string.IsNullOrWhiteSpace(search?.Status))
                query = query.Where(x => x.Status == search.Status);

            return base.AddFilter(query, search);
        }
    }

}
