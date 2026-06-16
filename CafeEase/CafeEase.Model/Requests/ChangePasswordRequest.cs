using System.ComponentModel.DataAnnotations;

namespace CafeEase.Model.Requests
{
    public class ChangePasswordRequest
    {
        [Required]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required]
        [MinLength(4)]
        public string NewPassword { get; set; } = string.Empty;

        [Required]
        [Compare(nameof(NewPassword), ErrorMessage = "Passwords do not match.")]
        public string NewPasswordConfirmation { get; set; } = string.Empty;
    }
}
