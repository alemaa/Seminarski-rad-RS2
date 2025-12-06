namespace CafeEase.Model.SearchObjects
{
    public class ProductSearchObject : BaseSearchObject
    {
        public string? NameFTS { get; set; }
        public int? CategoryId { get; set; }
        public decimal? PriceFrom { get; set; }
        public decimal? PriceTo { get; set; }
    }
}