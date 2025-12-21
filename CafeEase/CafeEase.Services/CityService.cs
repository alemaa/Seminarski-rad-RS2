using AutoMapper;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Xsl;
using CafeEase.Model.Requests;
using CafeEase.Services.Database;

namespace CafeEase.Services
{
    public class CityService : BaseCRUDService<Model.City, Database.City, BaseSearchObject, CityUpsertRequest, CityUpsertRequest>, ICityService
    {
        public CityService(CafeEaseDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<Model.City>> AddFilter(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
            {
                return new List<Model.City>();
            }

            var query = _context.Cities.AsQueryable();

            if (!string.IsNullOrEmpty(name))
            {
                query = query.Where(g => g.Name.Contains(name));
            }

            var entities = await query.ToListAsync();
            return _mapper.Map<List<Model.City>>(entities);
        }
    }
}