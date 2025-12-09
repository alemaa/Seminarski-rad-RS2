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
    public class LoyaltyPointsService : BaseCRUDService<Model.LoyaltyPoints, Database.LoyaltyPoints, LoyaltyPointsSearchObject,LoyaltyPointsInsertRequest,LoyaltyPointsUpdateRequest>,ILoyaltyPointsService
    {
        public LoyaltyPointsService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override IQueryable<Database.LoyaltyPoints> AddFilter(
            IQueryable<Database.LoyaltyPoints> query,
            LoyaltyPointsSearchObject? search = null)
        {
            if (search?.UserId.HasValue == true)
                query = query.Where(x => x.UserId == search.UserId);

            return base.AddFilter(query, search);
        }
    }
}
