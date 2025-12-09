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
    public class ReviewService
     : BaseCRUDService<Model.Review, Database.Review, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(Database.Review entity, ReviewInsertRequest insert)
        {
            entity.DateCreated = DateTime.Now;
        }

        public override IQueryable<Database.Review> AddFilter(
            IQueryable<Database.Review> query,
            ReviewSearchObject? search = null)
        {
            if (search?.ProductId.HasValue == true)
            {
                query = query.Where(x => x.ProductId == search.ProductId);
            }

            if (search?.UserId.HasValue == true)
            {
                query = query.Where(x => x.UserId == search.UserId);
            }

            return base.AddFilter(query, search);
        }
    }
}
