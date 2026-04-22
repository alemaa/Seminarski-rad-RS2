using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Model.Responses;

namespace CafeEase.Services
{
    public interface ICafeService : ICRUDService<Cafe, CafeSearchObject, CafeUpsertRequest, CafeUpsertRequest>
    {
        Task<List<Cafe>> GetNearby(double latitude, double longitude);
        Task<GeocodeResponse?> GeocodeAddress(string address, string city);
    }
}