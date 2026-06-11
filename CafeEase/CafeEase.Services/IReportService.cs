using CafeEase.Model.Responses;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public interface IReportService
    {
        Task<ReportDataResponse> GetData();
    }
}
