using CafeEase.Model;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReservationsController : BaseCRUDController<Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        public ReservationsController(ILogger<BaseController<Reservation, ReservationSearchObject>> logger, IReservationService service)
            : base(logger, service)
        {
        }
    }
}
