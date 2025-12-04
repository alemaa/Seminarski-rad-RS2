using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using CafeEase.Services.Database;

namespace CafeEase.Services
{
    public class UserService
        : BaseCRUDService<Model.User, Database.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>,
          IUserService
    {
        public UserService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override async Task BeforeInsert(User entity, UserInsertRequest insert)
        {
            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
        }

        public static string GenerateSalt()
        {
            using var provider = new RNGCryptoServiceProvider();
            var bytes = new byte[16];
            provider.GetBytes(bytes);
            return Convert.ToBase64String(bytes);
        }

        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            using HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] hash = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(hash);
        }

        public override IQueryable<Database.User> AddInclude(
            IQueryable<Database.User> query,
            UserSearchObject search = null)
        {
            if (search?.IncludeRole == true)
            {
                query = query.Include(x => x.Role);
            }
            return base.AddInclude(query, search);
        }

        public async Task<Model.User> Login(string email, string password)
        {
            var entity = await _context.Users
                .Include(x => x.Role)
                .FirstOrDefaultAsync(x => x.Email == email);

            if (entity == null)
                return null;

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
                return null;

            return _mapper.Map<Model.User>(entity);
        }
    }

}
