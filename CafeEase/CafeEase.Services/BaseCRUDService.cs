using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class BaseCRUDService<T, TDb, TSearch, TInsert, TUpdate> : BaseService<T, TDb, TSearch>where T : class where TDb : class where TSearch : BaseSearchObject
    {
        public BaseCRUDService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public virtual async Task BeforeInsert(TDb entity, TInsert insert)
        {
        }

        public virtual async Task BeforeUpdate(TDb entity, TUpdate update)
        {
        }

        public virtual async Task<T> Insert(TInsert insert)
        {
            var set = _context.Set<TDb>();

            TDb entity = _mapper.Map<TDb>(insert);

            set.Add(entity);
            await BeforeInsert(entity, insert);

            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }

        public virtual async Task<T> Update(int id, TUpdate update)
        {
            var set = _context.Set<TDb>();
            var entity = await set.FindAsync(id);

            if (entity == null)
                return null;

            _mapper.Map(update, entity);
            await BeforeUpdate(entity, update);

            await _context.SaveChangesAsync();
            return _mapper.Map<T>(entity);
        }

        public virtual async Task<T> Delete(int id)
        {
            var set = _context.Set<TDb>();
            var entity = await set.FindAsync(id);

            if (entity == null)
                return null;

            set.Remove(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<T>(entity);
        }
    }
}
