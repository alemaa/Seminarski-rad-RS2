using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class InventoryInsertRequest
    {
        [DefaultValue(1)]
        [Range(1, int.MaxValue, ErrorMessage = "Product is required.")]
        public int ProductId { get; set; } = 1;

        [DefaultValue(0)]
        [Range(0, int.MaxValue, ErrorMessage = "Quantity cannot be negative.")]
        public int Quantity { get; set; } = 0;
    }
}
