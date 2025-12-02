namespace CafeEase.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? Email { get; set; }
        public string? NameFTS { get; set; }
        public bool IncludeRole { get; set; }
    }
}