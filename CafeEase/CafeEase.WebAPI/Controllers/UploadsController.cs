using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CafeEase.Services.Exceptions;

namespace CafeEase.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class UploadsController : ControllerBase
    {
        private const long MaxFileSize = 5 * 1024 * 1024;

        private static readonly HashSet<string> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg",
            ".jpeg",
            ".png",
            ".webp"
        };

        private static readonly HashSet<string> AllowedContentTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "image/jpeg",
            "image/png",
            "image/webp"
        };

        [HttpPost("image")]
        public async Task<ActionResult<string>> UploadImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new UserException("No file uploaded.");

            if (file.Length > MaxFileSize)
               throw new UserException("File size must be 5 MB or less.");

            var extension = Path.GetExtension(file.FileName);
            if (string.IsNullOrWhiteSpace(extension) || !AllowedExtensions.Contains(extension))
                throw new UserException("Unsupported image extension.");

            if (string.IsNullOrWhiteSpace(file.ContentType) || !AllowedContentTypes.Contains(file.ContentType))
                throw new UserException("Unsupported image content type.");

            if (!await HasValidImageSignature(file, extension))
                throw new UserException("Invalid image file content.");

            var imagesFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images");

            if (!Directory.Exists(imagesFolder))
                Directory.CreateDirectory(imagesFolder);

            var fileName = $"{Guid.NewGuid()}{extension.ToLowerInvariant()}";
            var filePath = Path.Combine(imagesFolder, fileName);

            await using (var stream = new FileStream(filePath, FileMode.CreateNew))
            {
                await file.CopyToAsync(stream);
            }

            return Ok(fileName);
        }

        private static async Task<bool> HasValidImageSignature(IFormFile file, string extension)
        {
            var header = new byte[12];

            await using var stream = file.OpenReadStream();
            var bytesRead = await stream.ReadAsync(header, 0, header.Length);

            if (bytesRead < 4)
                return false;

            if (extension.Equals(".jpg", StringComparison.OrdinalIgnoreCase) ||
                extension.Equals(".jpeg", StringComparison.OrdinalIgnoreCase))
            {
                return header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF;
            }

            if (extension.Equals(".png", StringComparison.OrdinalIgnoreCase))
            {
                return bytesRead >= 8 &&
                       header[0] == 0x89 &&
                       header[1] == 0x50 &&
                       header[2] == 0x4E &&
                       header[3] == 0x47 &&
                       header[4] == 0x0D &&
                       header[5] == 0x0A &&
                       header[6] == 0x1A &&
                       header[7] == 0x0A;
            }

            if (extension.Equals(".webp", StringComparison.OrdinalIgnoreCase))
            {
                return bytesRead >= 12 &&
                       header[0] == 0x52 &&
                       header[1] == 0x49 &&
                       header[2] == 0x46 &&
                       header[3] == 0x46 &&
                       header[8] == 0x57 &&
                       header[9] == 0x45 &&
                       header[10] == 0x42 &&
                       header[11] == 0x50;
            }

            return false;
        }
    }
}
