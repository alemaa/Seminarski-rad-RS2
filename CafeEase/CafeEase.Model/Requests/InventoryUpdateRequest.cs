using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class InventoryUpdateRequest
    {
        [Range(0, int.MaxValue, ErrorMessage = "Quantity cannot be negative.")]
        public int Quantity { get; set; }
    }
}
