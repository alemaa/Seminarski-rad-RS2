namespace CafeEase.Model.Responses
{
    public class RecommendedProductResponse
    {
        public Product Product { get; set; } = null!;
        public double Score { get; set; }
        public string Reason { get; set; } = string.Empty;
    }
}
