
using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public class PromotionService : BaseCRUDService<Model.Promotion, Database.Promotion, PromotionSearchObject, PromotionInsertRequest,PromotionUpdateRequest>, IPromotionService
    {
        public PromotionService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }

        public override IQueryable<Database.Promotion> AddFilter(IQueryable<Database.Promotion> query,PromotionSearchObject? search = null)
        {
            query = query.Include(p => p.PromotionCategories).ThenInclude(pc => pc.Category).Where(p => p.PromotionCategories.All(pc => pc.Category != null));

            if (search?.ActiveOnly == true)
            {
                var now = DateTime.Now;
                query = query.Where(x =>
                    x.StartDate <= now &&
                    x.EndDate >= now);
            }
            if (!string.IsNullOrWhiteSpace(search?.Segment))
            {
                query = query.Where(p => p.TargetSegment == "ALL" || p.TargetSegment == search.Segment);
            }

            return base.AddFilter(query, search);
        }

        public override async Task BeforeInsert(Database.Promotion entity, PromotionInsertRequest insert)
        {
            entity.PromotionCategories = insert.CategoryIds
                .Select(cid => new PromotionCategory
                {
                    CategoryId = cid
                })
                .ToList();
        }

        public override async Task<Model.Promotion> Insert(PromotionInsertRequest request)
        {
            var entity = await base.Insert(request);

            var fullEntity = await _context.Promotions.Include(p => p.PromotionCategories).ThenInclude(pc => pc.Category)
                .FirstAsync(p => p.Id == entity.Id);

            return _mapper.Map<Model.Promotion>(fullEntity);
        }

        public override async Task BeforeUpdate(Database.Promotion entity, PromotionUpdateRequest update)
        {
            if (update.CategoryIds != null)
            {
                await _context.Entry(entity).Collection(p => p.PromotionCategories).LoadAsync();

                entity.PromotionCategories.Clear();

                foreach (var cid in update.CategoryIds)
                {
                    entity.PromotionCategories.Add(new PromotionCategory
                    {
                        PromotionId = entity.Id,
                        CategoryId = cid
                    });
                }
            }
            await _context.Entry(entity).Collection(p => p.PromotionCategories).LoadAsync();
        }

    }
}
