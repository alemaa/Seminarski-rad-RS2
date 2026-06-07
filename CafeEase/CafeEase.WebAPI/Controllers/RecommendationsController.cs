using CafeEase.Model;
using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using CafeEase.WebAPI.Controllers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace CafeEase.WebAPI.Controllers;

[ApiController]
[Route("[controller]")]
[Authorize]
public class RecommendationsController : ControllerBase
{
    private readonly IRecommendationService _service;

    public RecommendationsController(
        IRecommendationService service)
    {
        _service = service;
    }

    [Authorize(Roles = "Admin")]
    [HttpPost("train")]
    public async Task<IActionResult> Train()
    {
        await _service.TrainModel();
        return Ok("Recommendation model trained.");
    }

    [HttpGet("{productId}/recommended")]
    public async Task<IActionResult> GetRecommended(int productId)
    {
        var result = await _service.GetRecommendedProducts(productId);
        return Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpDelete("clear")]
    public async Task<IActionResult> Clear()
    {
        await _service.DeleteAll();
        return Ok("All recommendations deleted.");
    }
}
