namespace CafeEase.Services.Database
{
    public class Inventory
    {
        public int Id { get; set; }

        public int ProductId { get; set; }
        public virtual Product Product { get; set; }

        public int Quantity { get; set; }
    }
}
