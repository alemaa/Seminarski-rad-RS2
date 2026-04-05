using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _service;

        public NotificationsController(INotificationService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<CafeEase.Model.PagedResult<CafeEase.Model.Notification>> Get([FromQuery] NotificationSearchObject? search = null)
            => await _service.Get(search);

        [HttpPost("{id}/mark-read")]
        public async Task<IActionResult> MarkRead(int id)
        {
            await _service.MarkAsRead(id);
            return Ok();
        }

        [HttpPost("mark-all-read")]
        public async Task<IActionResult> MarkAllRead()
        {
            await _service.MarkAllAsRead();
            return Ok();
        }
    }
}