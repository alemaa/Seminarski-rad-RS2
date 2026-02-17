using System.Collections.Generic;
using System.Threading.Tasks;
using CafeEase.Model.Requests;

namespace CafeEase.Services
{
    public interface IStripePaymentService
    {
        Task<StripeCreateIntentResponse> CreatePaymentIntentAsync(decimal amount, string currency, Dictionary<string, string>? metadata = null);
        Task<bool> ConfirmPaymentAsync(string paymentIntentId);
    }
}
