using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class ReservationCancelRequest
    {
        [Required]
        [MinLength(3)]
        public string CancellationReason { get; set; } = string.Empty;
    }
}
