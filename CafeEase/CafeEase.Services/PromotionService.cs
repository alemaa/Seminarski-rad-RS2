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
    public class PromotionService : BaseCRUDService<Model.Promotion, Database.Promotion, PromotionSearchObject, PromotionInsertRequest,PromotionUpdateRequest>, IPromotionService
    {
        public PromotionService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.Promotion> AddFilter(IQueryable<Database.Promotion> query,PromotionSearchObject? search = null)
        {
            if (search?.ActiveOnly == true)
            {
                var now = DateTime.Now;
                query = query.Where(x =>
                    x.StartDate <= now &&
                    x.EndDate >= now);
            }

            return base.AddFilter(query, search);
        }
    }
}
