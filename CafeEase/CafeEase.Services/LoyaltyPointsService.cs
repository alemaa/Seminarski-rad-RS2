using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using System.Linq;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using CafeEase.Model.Exceptions;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class LoyaltyPointsService : BaseCRUDService<Model.LoyaltyPoints, Database.LoyaltyPoints, LoyaltyPointsSearchObject,LoyaltyPointsInsertRequest,LoyaltyPointsUpdateRequest>,ILoyaltyPointsService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public LoyaltyPointsService(CafeEaseDbContext context, IMapper mapper, IHttpContextAccessor httpContextAccessor)
            : base(context, mapper)
        {
            _httpContextAccessor = httpContextAccessor;
        }
        public override IQueryable<Database.LoyaltyPoints> AddFilter(
            IQueryable<Database.LoyaltyPoints> query,
            LoyaltyPointsSearchObject? search = null)
        {
            if (!IsAdmin())
            {
                var username = GetCurrentUsername();
                query = query.Where(x => x.User.Username == username);
            }
            else if (search?.UserId.HasValue == true)
            {
                query = query.Where(x => x.UserId == search.UserId.Value);
            }

            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.LoyaltyPoints> AddInclude(IQueryable<Database.LoyaltyPoints> query, LoyaltyPointsSearchObject? search = null)
        {
            return query.Include(x => x.User);
        }

        public override async Task<Model.LoyaltyPoints> GetById(int id)
        {
            var entity = await _context.LoyaltyPoints
                .Include(x => x.User)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                throw new NotFoundException("Loyalty points not found.");

            if (!IsAdmin() && entity.User.Username != GetCurrentUsername())
                throw new ForbiddenException("You cannot access these loyalty points.");

            return _mapper.Map<Model.LoyaltyPoints>(entity);
        }

        public override async Task<Model.LoyaltyPoints> Insert(LoyaltyPointsInsertRequest insert)
        {
            if (!IsAdmin())
                throw new ForbiddenException("Only administrators can create loyalty points.");

            return await base.Insert(insert);
        }

        public override async Task<Model.LoyaltyPoints> Update(int id, LoyaltyPointsUpdateRequest update)
        {
            if (!IsAdmin())
                throw new ForbiddenException("Only administrators can update loyalty points.");

            return await base.Update(id, update);
        }

        public override async Task<Model.LoyaltyPoints> Delete(int id)
        {
            if (!IsAdmin())
                throw new ForbiddenException("Only administrators can delete loyalty points.");

            return await base.Delete(id);
        }

        private string GetCurrentUsername()
        {
            return _httpContextAccessor.HttpContext?.User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? throw new UserException("User not authenticated.");
        }

        private bool IsAdmin()
        {
            return _httpContextAccessor.HttpContext?.User.IsInRole("Admin") == true;
        }
    }
}
