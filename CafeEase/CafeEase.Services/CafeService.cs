using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Model.Responses;
using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;
using System.Net.Http;

namespace CafeEase.Services
{
    public class CafeService : BaseCRUDService<Model.Cafe, Database.Cafe, CafeSearchObject, CafeUpsertRequest, CafeUpsertRequest>, ICafeService
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public CafeService(
            CafeEaseDbContext context,
            IMapper mapper,
            IHttpClientFactory httpClientFactory
        ) : base(context, mapper)
        {
            _httpClientFactory = httpClientFactory;
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

        public async Task<GeocodeResponse?> GeocodeAddress(string address, string city)
        {
            var fullAddress = $"{address}, {city}, Bosnia and Herzegovina";
            var encodedAddress = Uri.EscapeDataString(fullAddress);

            var url = $"https://nominatim.openstreetmap.org/search?q={encodedAddress}&format=json&limit=1";

            var client = _httpClientFactory.CreateClient();
            client.DefaultRequestHeaders.UserAgent.Clear();
            client.DefaultRequestHeaders.UserAgent.Add(
                new ProductInfoHeaderValue("CafeEaseApp", "1.0")
            );

            var response = await client.GetAsync(url);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();

            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };

            var results = JsonSerializer.Deserialize<List<NominatimResult>>(json, options);

            var first = results?.FirstOrDefault();
            if (first == null)
                return null;

            if (!double.TryParse(first.lat, NumberStyles.Any, CultureInfo.InvariantCulture, out var latitude))
                return null;

            if (!double.TryParse(first.lon, NumberStyles.Any, CultureInfo.InvariantCulture, out var longitude))
                return null;

            return new GeocodeResponse
            {
                Latitude = latitude,
                Longitude = longitude
            };
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

        private class NominatimResult
        {
            public string? lat { get; set; }
            public string? lon { get; set; }
        }
    }
}