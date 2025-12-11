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
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            return query;
        }
    }
}
