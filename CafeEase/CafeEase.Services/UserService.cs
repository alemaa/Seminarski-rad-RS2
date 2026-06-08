using AutoMapper;
using CafeEase.Model.Requests;
using CafeEase.Model.SearchObjects;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System;
using System.Threading.Tasks;
using CafeEase.Services.Database;
using CafeEase.Services.Exceptions;
using Microsoft.AspNetCore.Identity;

namespace CafeEase.Services
{
    public class UserService : BaseCRUDService<Model.User, Database.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly PasswordHasher<Database.User> _passwordHasher = new();
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

            entity.PasswordSalt = string.Empty;
            entity.PasswordHash = _passwordHasher.HashPassword(entity, insert.Password);
        }

        public override async Task BeforeUpdate(User entity, UserUpdateRequest update)
        {
           
            var cityExists = await _context.Cities.AnyAsync(c => c.Id == update.CityId);
            if (!cityExists)
                throw new UserException("Selected city does not exist.");
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

            var result = _passwordHasher.VerifyHashedPassword(entity, entity.PasswordHash, password);

            if (result == PasswordVerificationResult.Failed)
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

        public async Task<Model.User> Register(RegisterRequest request)
        {
            var entity = _mapper.Map<Database.User>(request);

            entity.RoleId = 2;

            await BeforeRegister(entity, request);

            _context.Users.Add(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.User>(entity);
        }

        private async Task BeforeRegister(Database.User entity, RegisterRequest request)
        {
            var cityExists = await _context.Cities.AnyAsync(c => c.Id == request.CityId);
            if (!cityExists)
                throw new UserException("Selected city does not exist");

            var usernameTaken = await _context.Users.AnyAsync(u => u.Username == request.Username);
            if (usernameTaken)
                throw new UserException("Username is already taken");

            var emailTaken = await _context.Users.AnyAsync(u => u.Email == request.Email);
            if (emailTaken)
                throw new UserException("Email is already taken");

            entity.PasswordSalt = string.Empty;
            entity.PasswordHash = _passwordHasher.HashPassword(entity, request.Password);
        }
    }
}
