using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public interface IReservationService: ICRUDService<Model.Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
    }
}
