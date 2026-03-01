using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace Vaveyla.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PlacesController : ControllerBase
{
    private static readonly string GoogleApiKey = "AIzaSyDw-141Zuzz-kSUYReoANpEpUIASTIVf44";
    private static readonly HttpClient HttpClient = new HttpClient();

    [HttpGet("autocomplete")]
    public async Task<IActionResult> GetPlaceAutocomplete(
        [FromQuery] string input,
        [FromQuery] string sessiontoken,
        [FromQuery] string components = "country:tr",
        [FromQuery] string language = "tr",
        [FromQuery] string types = "address")
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return BadRequest("Input parameter is required.");
        }

        try
        {
            var queryParams = new Dictionary<string, string>
            {
                ["input"] = input,
                ["key"] = GoogleApiKey,
                ["sessiontoken"] = sessiontoken ?? Guid.NewGuid().ToString(),
                ["components"] = components,
                ["language"] = language,
                ["types"] = types
            };

            var queryString = string.Join("&", queryParams.Select(kvp => 
                $"{Uri.EscapeDataString(kvp.Key)}={Uri.EscapeDataString(kvp.Value)}"));

            var url = $"https://maps.googleapis.com/maps/api/place/autocomplete/json?{queryString}";

            var response = await HttpClient.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                return Content(content, "application/json");
            }

            return StatusCode((int)response.StatusCode, content);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }

    [HttpGet("details")]
    public async Task<IActionResult> GetPlaceDetails(
        [FromQuery] string placeId,
        [FromQuery] string sessiontoken,
        [FromQuery] string language = "tr",
        [FromQuery] string fields = "address_components,formatted_address,geometry")
    {
        if (string.IsNullOrWhiteSpace(placeId))
        {
            return BadRequest("PlaceId parameter is required.");
        }

        try
        {
            var queryParams = new Dictionary<string, string>
            {
                ["place_id"] = placeId,
                ["key"] = GoogleApiKey,
                ["sessiontoken"] = sessiontoken ?? Guid.NewGuid().ToString(),
                ["language"] = language,
                ["fields"] = fields
            };

            var queryString = string.Join("&", queryParams.Select(kvp => 
                $"{Uri.EscapeDataString(kvp.Key)}={Uri.EscapeDataString(kvp.Value)}"));

            var url = $"https://maps.googleapis.com/maps/api/place/details/json?{queryString}";

            var response = await HttpClient.GetAsync(url);
            var content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                return Content(content, "application/json");
            }

            return StatusCode((int)response.StatusCode, content);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = ex.Message });
        }
    }

    [HttpGet("test")]
    public IActionResult TestEndpoint()
    {
        return Ok(new { 
            message = "Places API Proxy is working!", 
            timestamp = DateTime.UtcNow,
            hasApiKey = !string.IsNullOrEmpty(GoogleApiKey)
        });
    }
}