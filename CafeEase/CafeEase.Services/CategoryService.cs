using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using System.Linq;

namespace CafeEase.Services
{
    public class CategoryService : BaseCRUDService<Model.Category,Database.Category,CategorySearchObject,CategoryUpsertRequest, CategoryUpsertRequest>,ICategoryService
    {
        public CategoryService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Category> AddFilter(IQueryable<Category> query, CategorySearchObject search = null)
        {
            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                var term = search.Name.ToLower();

                query = query.Where(p => p.Name != null &&
                    (
                        p.Name.ToLower().StartsWith(term) ||
                        p.Name.ToLower().Contains(" " + term)
                    )
                );
            }
            return query;
        }
    }
}
