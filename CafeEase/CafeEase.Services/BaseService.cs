using AutoMapper;
using CafeEase.Model;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class BaseService<T, TDb, TSearch> : IService<T, TSearch>where T : class where TDb : class where TSearch : BaseSearchObject
    {
        protected CafeEaseDbContext _context;
        public IMapper _mapper { get; set; }

        public BaseService(CafeEaseDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<PagedResult<T>> Get(TSearch? search = null)
        {
            var query = _context.Set<TDb>().AsQueryable();

            PagedResult<T> result = new PagedResult<T>();

            query = AddFilter(query, search);
            query = AddInclude(query, search);

            result.Count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true)
            {
                query = query
                    .Take(search.PageSize.Value)
                    .Skip(search.Page.Value * search.PageSize.Value);
            }

            var list = await query.ToListAsync();
            result.Result = _mapper.Map<List<T>>(list);

            return result;
        }

        public virtual IQueryable<TDb> AddInclude(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }

        public virtual IQueryable<TDb> AddFilter(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }

        public async Task<T> GetById(int id)
        {
            var entity = await _context.Set<TDb>().FindAsync(id);
            return _mapper.Map<T>(entity);
        }
    }
}
