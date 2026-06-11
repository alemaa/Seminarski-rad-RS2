using CafeEase.Model.Responses;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Admin")]
public class ReportsController : ControllerBase
{
    private readonly IReportService _service;

    public ReportsController(IReportService service)
    {
        _service = service;
    }

    [HttpGet("data")]
    public async Task<ActionResult<ReportDataResponse>> GetData()
    {
        return Ok(await _service.GetData());
    }
}
