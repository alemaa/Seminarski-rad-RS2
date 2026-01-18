using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class UserInsertRequest
    {
        [Required]
        public string FirstName { get; set; }

        [Required]
        public string LastName { get; set; }

        [Required]
        [EmailAddress]
        public string Email { get; set; }

        [MinLength(4)]
        [Required]
        public string Password { get; set; }

        [Required]
        public string Username { get; set; }

        [Required]
        [Compare(nameof(Password), ErrorMessage = "Passwords do not match.")]
        public string PasswordConfirmation { get; set; }

        [Required]
        public int RoleId { get; set; }
    }
}