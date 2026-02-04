using CafeEase.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace CafeEase.WebAPI.Authentication
{
    public class BasicAuthenticationHandler
        : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private readonly IUserService _userService;

        public BasicAuthenticationHandler(
            IUserService userService,
            IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger,
            UrlEncoder encoder,
            ISystemClock clock)
            : base(options, logger, encoder, clock)
        {
            _userService = userService;
        }
        protected override async Task HandleChallengeAsync(AuthenticationProperties properties)
        {
            if (Context.Items.ContainsKey("DesktopDenied"))
            {
                Response.StatusCode = StatusCodes.Status403Forbidden;
                Response.ContentType = "application/json";
                await Response.WriteAsync("{\"errors\":{\"userError\":[\"Desktop access denied.\"]}}");
                return;
            }

            await base.HandleChallengeAsync(properties);
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.ContainsKey("Authorization"))
            {
                return AuthenticateResult.Fail("Missing Authorization header");
            }

            try
            {
                var authHeader = AuthenticationHeaderValue.Parse(
                    Request.Headers["Authorization"]);

                var credentialBytes =
                    Convert.FromBase64String(authHeader.Parameter!);

                var credentials =
                    Encoding.UTF8.GetString(credentialBytes).Split(':');

                var username = credentials[0];
                var password = credentials[1];

                var user = await _userService.Login(username, password);

                if (user == null)
                {
                    return AuthenticateResult.Fail("Invalid email or password");
                }

                var client = Request.Headers["X-Client"].ToString();

                if (client == "Desktop" && user.RoleId == 2)
                {
                    Context.Items["DesktopDenied"] = true;
                    return AuthenticateResult.Fail("Desktop access denied.");
                }


                var claims = new List<Claim>
                {
                   new Claim(ClaimTypes.Name,user.FirstName),
                    new Claim(ClaimTypes.NameIdentifier,user.Username)
                };

                var identity = new ClaimsIdentity(claims, Scheme.Name);
                var principal = new ClaimsPrincipal(identity);
                var ticket = new AuthenticationTicket(principal, Scheme.Name);

                return AuthenticateResult.Success(ticket);
            }
            catch
            {
                return AuthenticateResult.Fail("Invalid Authorization header");
            }
        }
    }
}
