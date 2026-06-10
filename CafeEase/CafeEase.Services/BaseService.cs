using AutoMapper;
using CafeEase.Model;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CafeEase.Model.Exceptions;

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

            const int maxPageSize = 100;

            var page = search?.Page ?? 0;
            var pageSize = search?.PageSize ?? maxPageSize;

            page = Math.Max(page, 0);
            pageSize = Math.Clamp(pageSize, 1, maxPageSize);

            query = query
                .OrderBy(x => EF.Property<int>(x, "Id"))
                .Skip(page * pageSize)
                .Take(pageSize);

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

            if (entity == null)
                throw new NotFoundException("Record not found.");

            return _mapper.Map<T>(entity);
        }
    }
}
