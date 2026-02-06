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
using CafeEase.Services.Exceptions;

namespace CafeEase.Services
{
    public class UserService : BaseCRUDService<Model.User, Database.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        public UserService(CafeEaseDbContext context, IMapper mapper)
            : base(context, mapper)
        {
        }
        public override async Task BeforeInsert(User entity, UserInsertRequest insert)
        {
   
            var cityExists = await _context.Cities.AnyAsync(c => c.Id == insert.CityId);
            if (!cityExists)
                throw new UserException("Selected city does not exist");

            var usernameTaken = await _context.Users.AnyAsync(u => u.Username == insert.Username);
            if (usernameTaken)
                throw new UserException("Username is already taken");

            var emailTaken = await _context.Users.AnyAsync(u => u.Email == insert.Email);
            if (emailTaken)
                throw new UserException("Email is already taken");

            entity.PasswordSalt = GenerateSalt();
            entity.PasswordHash = GenerateHash(entity.PasswordSalt, insert.Password);
        }

        public override async Task BeforeUpdate(User entity, UserUpdateRequest update)
        {
           
            var cityExists = await _context.Cities.AnyAsync(c => c.Id == update.CityId);
            if (!cityExists)
                throw new Exception("Selected city does not exist.");
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

        public override IQueryable<Database.User> AddFilter(IQueryable<Database.User> query, UserSearchObject? search = null)
        {
            if (search == null)
                return query;

            if (search == null)
                return query;

            if (!string.IsNullOrWhiteSpace(search.NameFTS))
            {
                var term = search.NameFTS.ToLower();

                query = query.Where(x =>
                    (x.FirstName + " " + x.LastName).ToLower().Contains(term) ||
                    x.FirstName.ToLower().Contains(term) ||
                    x.LastName.ToLower().Contains(term) ||
                    x.Email.ToLower().Contains(term)
                );
            }

            return query;
        }

        public override IQueryable<Database.User> AddInclude(IQueryable<Database.User> query, UserSearchObject search = null)
        {
            if (search?.IncludeRole == true)
                query = query.Include(x => x.Role);

            query = query.Include(x => x.City);

            return base.AddInclude(query, search);
        }

        public async Task<Model.User> Login(string username, string password)
        {
            var entity = await _context.Users
                .Include(x => x.Role)
                .FirstOrDefaultAsync(x => x.Username == username);

            if (entity == null)
                return null;

            var hash = GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
                return null;

            return _mapper.Map<Model.User>(entity);
        }

        public async Task<Model.User> Delete(int id)
        {
            var entity = await _context.Users.FindAsync(id);

            if (entity == null)
                throw new UserException("User not found");

            if (entity.RoleId == 1)
                throw new UserException("Admin user cannot be deleted.");

            _context.Users.Remove(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.User>(entity);
        }
    }
}
