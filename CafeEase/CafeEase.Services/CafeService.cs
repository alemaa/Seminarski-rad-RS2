using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace CafeEase.Services
{
    public class CafeService : BaseCRUDService<Model.Cafe, Database.Cafe, CafeSearchObject, CafeUpsertRequest, CafeUpsertRequest>, ICafeService
    {
        public CafeService(CafeEaseDbContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override IQueryable<Database.Cafe> AddInclude(IQueryable<Database.Cafe> query, CafeSearchObject? search = null)
        {
            return query.Include(x => x.City);
        }

        public override IQueryable<Database.Cafe> AddFilter(IQueryable<Database.Cafe> query, CafeSearchObject? search = null)
        {
            if (search == null)
                return query;

            if (!string.IsNullOrWhiteSpace(search.Name))
            {
                query = query.Where(x => x.Name.Contains(search.Name));
            }

            if (search.CityId.HasValue)
            {
                query = query.Where(x => x.CityId == search.CityId.Value);
            }

            if (search.IsActive.HasValue)
            {
                query = query.Where(x => x.IsActive == search.IsActive.Value);
            }

            return query;
        }

        public async Task<List<Model.Cafe>> GetNearby(double latitude, double longitude)
        {
            var cafes = await _context.Cafes
                .Include(x => x.City)
                .Where(x => x.IsActive)
                .ToListAsync();

            var result = cafes
                .Select(c => new Model.Cafe
                {
                    Id = c.Id,
                    Name = c.Name,
                    Address = c.Address,
                    CityId = c.CityId,
                    CityName = c.City?.Name ?? string.Empty,
                    Latitude = c.Latitude,
                    Longitude = c.Longitude,
                    PhoneNumber = c.PhoneNumber,
                    WorkingHours = c.WorkingHours,
                    IsActive = c.IsActive,
                    DistanceKm = CalculateDistance(latitude, longitude, c.Latitude, c.Longitude)
                })
                .OrderBy(x => x.DistanceKm)
                .ToList();

            return result;
        }

        private static double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
        {
            const double earthRadiusKm = 6371;

            var dLat = DegreesToRadians(lat2 - lat1);
            var dLon = DegreesToRadians(lon2 - lon1);

            var a =
                Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(DegreesToRadians(lat1)) *
                Math.Cos(DegreesToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

            return earthRadiusKm * c;
        }

        private static double DegreesToRadians(double degrees)
        {
            return degrees * Math.PI / 180;
        }
    }
}
