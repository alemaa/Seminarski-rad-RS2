using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using CafeEase.Model.Exceptions;
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
            entity.DateCreated = DateTime.UtcNow;


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

        public override async Task<Model.Review> Insert(ReviewInsertRequest request)
        {
            var entity = await base.Insert(request);

            var fullEntity = await _context.Reviews
                .Include(r => r.Product)
                .Include(r => r.User)
                .FirstAsync(r => r.Id == entity.Id);

            return _mapper.Map<Model.Review>(fullEntity);
        }

        public override IQueryable<Database.Review> AddInclude(IQueryable<Database.Review> query, ReviewSearchObject? search = null)
        {
            return query.Include(r => r.User).Include(r => r.Product);
        }

        public override async Task<Model.Review> GetById(int id)
        {
            var entity = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Product)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new NotFoundException("Review not found.");

            return _mapper.Map<Model.Review>(entity);
        }

        public override async Task<Model.Review> Update(int id, ReviewUpdateRequest update)
        {
            var entity = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Product)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new NotFoundException("Review not found.");

            var currentUser = await GetCurrentUserAsync();

            if (!IsAdmin() && entity.UserId != currentUser.Id)
                throw new ForbiddenException("You cannot modify this review.");

            _mapper.Map(update, entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Review>(entity);
        }

        public override async Task<Model.Review> Delete(int id)
        {
            var entity = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Product)
                .FirstOrDefaultAsync(r => r.Id == id);

            if (entity == null)
                throw new NotFoundException("Review not found.");

            var currentUser = await GetCurrentUserAsync();

            if (!IsAdmin() && entity.UserId != currentUser.Id)
                throw new ForbiddenException("You cannot delete this review.");

            _context.Reviews.Remove(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Review>(entity);
        }

        public override IQueryable<Database.Review> AddFilter(IQueryable<Database.Review> query, ReviewSearchObject? search = null)
        {
            if (search?.ProductId.HasValue == true)
            {
                query = query.Where(x => x.ProductId == search.ProductId);
            }

            if (IsAdmin())
            {
                if (search?.UserId.HasValue == true)
                    query = query.Where(r => r.UserId == search.UserId.Value);
            }
            else if (search?.UserId.HasValue == true)
            {
                var username = GetCurrentUsername();
                query = query.Where(r => r.User.Username == username);
            }

            if(search?.Rating.HasValue == true)
            {
                query = query.Where(x => x.Rating == search.Rating);
            }

            return base.AddFilter(query, search);
            
        }

        private string GetCurrentUsername()
        {
            return _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? throw new UserException("User not authenticated.");
        }

        private bool IsAdmin()
        {
            return _httpContextAccessor.HttpContext?.User.IsInRole("Admin") == true;
        }

        private async Task<Database.User> GetCurrentUserAsync()
        {
            var username = GetCurrentUsername();

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Username == username);

            if (user == null)
                throw new UserException("User not found.");

            return user;
        }
    }
}
