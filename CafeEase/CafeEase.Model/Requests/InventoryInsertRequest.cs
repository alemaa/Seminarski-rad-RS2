using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class InventoryInsertRequest
    {
        public int ProductId { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Quantity cannot be negative.")]
        public int Quantity { get; set; }
    }
}
