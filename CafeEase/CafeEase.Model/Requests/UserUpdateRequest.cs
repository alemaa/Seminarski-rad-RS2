namespace CafeEase.Model.Requests
{
    public class UserUpdateRequest
    {
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string Email { get; set; }

        public string Username { get; set; }
        public int RoleId { get; set; }
    }
}
