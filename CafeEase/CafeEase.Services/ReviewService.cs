using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Services.Exceptions;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class ReviewService : BaseCRUDService<Model.Review, Database.Review, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ReviewService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public override async Task BeforeInsert(Database.Review entity, ReviewInsertRequest insert)
        {
            entity.DateCreated = DateTime.Now;

            var user = _httpContextAccessor.HttpContext?.User;

            if (user == null || !user.Identity.IsAuthenticated)
                throw new UserException("User not authenticated");

            var username = user.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? user.FindFirst(ClaimTypes.Name)?.Value;

            if (string.IsNullOrWhiteSpace(username))
                throw new UserException("User not found");

            var dbUser = await _context.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (dbUser == null)
                throw new UserException("User not found");

            entity.UserId = dbUser.Id;
        }

        public override IQueryable<Database.Review> AddInclude(IQueryable<Database.Review> query, ReviewSearchObject? search = null)
        {
            return query.Include(r => r.User).Include(r => r.Product);
        }

        public override IQueryable<Database.Review> AddFilter(IQueryable<Database.Review> query, ReviewSearchObject? search = null)
        {
            if (search?.ProductId.HasValue == true)
            {
                query = query.Where(x => x.ProductId == search.ProductId);
            }

            if (search?.UserId.HasValue == true)
            {
                query = query.Where(x => x.UserId == search.UserId);
            }

            if(search?.Rating.HasValue == true)
            {
                query = query.Where(x => x.Rating == search.Rating);
            }

            return base.AddFilter(query, search);
            
        }
    }
}
