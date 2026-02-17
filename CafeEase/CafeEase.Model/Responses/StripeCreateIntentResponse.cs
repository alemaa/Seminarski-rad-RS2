namespace CafeEase.Model.Requests
{
    public class StripeCreateIntentResponse
    {
        public string ClientSecret { get; set; } = string.Empty;
        public string PaymentIntentId { get; set; } = string.Empty;
        public string PublishableKey { get; set; } = string.Empty;
    }
}
