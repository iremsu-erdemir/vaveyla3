namespace Vaveyla.Api.Models;

public sealed class RestaurantReview
{
    public Guid ReviewId { get; set; }
    public Guid RestaurantId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public byte Rating { get; set; }
    public string Comment { get; set; } = string.Empty;
    public string? OwnerReply { get; set; }
    public DateTime CreatedAtUtc { get; set; }
}
