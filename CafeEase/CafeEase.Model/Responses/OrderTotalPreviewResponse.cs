namespace CafeEase.Model.Responses
{
    public class OrderTotalPreviewResponse
    {
        public decimal Subtotal { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal TotalAmount { get; set; }
    }
}
