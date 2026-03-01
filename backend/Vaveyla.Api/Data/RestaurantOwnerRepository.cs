using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Vaveyla.Api.Models;

namespace Vaveyla.Api.Data;

public interface IRestaurantOwnerRepository
{
    Task<Restaurant> GetOrCreateRestaurantAsync(Guid ownerUserId, CancellationToken cancellationToken);
    Task<Restaurant?> GetRestaurantAsync(Guid ownerUserId, CancellationToken cancellationToken);
    Task UpdateRestaurantAsync(Restaurant restaurant, CancellationToken cancellationToken);
    Task<List<MenuItem>> GetMenuItemsAsync(Guid restaurantId, CancellationToken cancellationToken);
    Task<MenuItem?> GetMenuItemAsync(Guid restaurantId, Guid menuItemId, CancellationToken cancellationToken);
    Task<MenuItem> AddMenuItemAsync(MenuItem item, CancellationToken cancellationToken);
    Task UpdateMenuItemAsync(MenuItem item, CancellationToken cancellationToken);
    Task<bool> DeleteMenuItemAsync(Guid restaurantId, Guid menuItemId, CancellationToken cancellationToken);
    Task<List<RestaurantOrder>> GetOrdersAsync(Guid restaurantId, CancellationToken cancellationToken);
    Task<RestaurantOrder> AddOrderAsync(RestaurantOrder order, CancellationToken cancellationToken);
    Task<RestaurantOrder?> GetOrderAsync(Guid restaurantId, Guid orderId, CancellationToken cancellationToken);
    Task UpdateOrderAsync(RestaurantOrder order, CancellationToken cancellationToken);
    Task<List<RestaurantReview>> GetReviewsAsync(Guid restaurantId, CancellationToken cancellationToken);
    Task UpdateReviewReplyAsync(Guid restaurantId, Guid reviewId, string reply, CancellationToken cancellationToken);
}

public sealed class RestaurantOwnerRepository : IRestaurantOwnerRepository
{
    private readonly VaveylaDbContext _dbContext;
    private readonly string _connectionString;

    public RestaurantOwnerRepository(IConfiguration configuration, VaveylaDbContext dbContext)
    {
        _connectionString = configuration.GetConnectionString("Default")
            ?? throw new InvalidOperationException("Connection string 'Default' is missing.");
        _dbContext = dbContext;
    }

    public async Task<Restaurant> GetOrCreateRestaurantAsync(
        Guid ownerUserId,
        CancellationToken cancellationToken)
    {
        var existing = await GetRestaurantAsync(ownerUserId, cancellationToken);
        if (existing is not null)
        {
            return existing;
        }

        var restaurant = new Restaurant
        {
            RestaurantId = Guid.NewGuid(),
            OwnerUserId = ownerUserId,
            Name = "Yeni Restoran",
            Type = "Restoran",
            Address = "Adres bilgisi girilmedi",
            Phone = "+90",
            WorkingHours = "09:00 - 22:00",
            OrderNotifications = true,
            CreatedAtUtc = DateTime.UtcNow,
        };

        _dbContext.Restaurants.Add(restaurant);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return restaurant;
    }

    public async Task<Restaurant?> GetRestaurantAsync(
        Guid ownerUserId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT RestaurantId, OwnerUserId, Name, Type, Address, Phone, WorkingHours,
                   OrderNotifications, PhotoPath, CreatedAtUtc
            FROM dbo.Restaurants
            WHERE OwnerUserId = @OwnerUserId
            """;

        await using var connection = new SqlConnection(_connectionString);
        return await connection.QuerySingleOrDefaultAsync<Restaurant>(
            new CommandDefinition(sql, new { OwnerUserId = ownerUserId }, cancellationToken: cancellationToken));
    }

    public async Task UpdateRestaurantAsync(Restaurant restaurant, CancellationToken cancellationToken)
    {
        _dbContext.Restaurants.Update(restaurant);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<List<MenuItem>> GetMenuItemsAsync(Guid restaurantId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT MenuItemId, RestaurantId, Name, Price, ImagePath, IsAvailable, CreatedAtUtc
            FROM dbo.MenuItems
            WHERE RestaurantId = @RestaurantId
            ORDER BY CreatedAtUtc DESC
            """;

        await using var connection = new SqlConnection(_connectionString);
        var items = await connection.QueryAsync<MenuItem>(
            new CommandDefinition(sql, new { RestaurantId = restaurantId }, cancellationToken: cancellationToken));
        return items.ToList();
    }

    public async Task<MenuItem?> GetMenuItemAsync(
        Guid restaurantId,
        Guid menuItemId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT MenuItemId, RestaurantId, Name, Price, ImagePath, IsAvailable, CreatedAtUtc
            FROM dbo.MenuItems
            WHERE RestaurantId = @RestaurantId AND MenuItemId = @MenuItemId
            """;

        await using var connection = new SqlConnection(_connectionString);
        return await connection.QuerySingleOrDefaultAsync<MenuItem>(
            new CommandDefinition(sql, new { RestaurantId = restaurantId, MenuItemId = menuItemId },
                cancellationToken: cancellationToken));
    }

    public async Task<MenuItem> AddMenuItemAsync(MenuItem item, CancellationToken cancellationToken)
    {
        _dbContext.MenuItems.Add(item);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return item;
    }

    public async Task UpdateMenuItemAsync(MenuItem item, CancellationToken cancellationToken)
    {
        _dbContext.MenuItems.Update(item);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<bool> DeleteMenuItemAsync(
        Guid restaurantId,
        Guid menuItemId,
        CancellationToken cancellationToken)
    {
        var existing = await _dbContext.MenuItems
            .FirstOrDefaultAsync(x => x.RestaurantId == restaurantId && x.MenuItemId == menuItemId,
                cancellationToken);
        if (existing is null)
        {
            return false;
        }

        _dbContext.MenuItems.Remove(existing);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    public async Task<List<RestaurantOrder>> GetOrdersAsync(Guid restaurantId, CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT OrderId, RestaurantId, Items, ImagePath, PreparationMinutes, Total, Status, CreatedAtUtc
            FROM dbo.RestaurantOrders
            WHERE RestaurantId = @RestaurantId
            ORDER BY CreatedAtUtc DESC
            """;

        await using var connection = new SqlConnection(_connectionString);
        var orders = await connection.QueryAsync<RestaurantOrder>(
            new CommandDefinition(sql, new { RestaurantId = restaurantId }, cancellationToken: cancellationToken));
        return orders.ToList();
    }

    public async Task<RestaurantOrder> AddOrderAsync(
        RestaurantOrder order,
        CancellationToken cancellationToken)
    {
        _dbContext.RestaurantOrders.Add(order);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return order;
    }

    public async Task<RestaurantOrder?> GetOrderAsync(
        Guid restaurantId,
        Guid orderId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT OrderId, RestaurantId, Items, ImagePath, PreparationMinutes, Total, Status, CreatedAtUtc
            FROM dbo.RestaurantOrders
            WHERE RestaurantId = @RestaurantId AND OrderId = @OrderId
            """;

        await using var connection = new SqlConnection(_connectionString);
        return await connection.QuerySingleOrDefaultAsync<RestaurantOrder>(
            new CommandDefinition(sql, new { RestaurantId = restaurantId, OrderId = orderId },
                cancellationToken: cancellationToken));
    }

    public async Task UpdateOrderAsync(RestaurantOrder order, CancellationToken cancellationToken)
    {
        _dbContext.RestaurantOrders.Update(order);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<List<RestaurantReview>> GetReviewsAsync(
        Guid restaurantId,
        CancellationToken cancellationToken)
    {
        const string sql = """
            SELECT ReviewId, RestaurantId, CustomerName, Rating, Comment, OwnerReply, CreatedAtUtc
            FROM dbo.RestaurantReviews
            WHERE RestaurantId = @RestaurantId
            ORDER BY CreatedAtUtc DESC
            """;

        await using var connection = new SqlConnection(_connectionString);
        var reviews = await connection.QueryAsync<RestaurantReview>(
            new CommandDefinition(sql, new { RestaurantId = restaurantId }, cancellationToken: cancellationToken));
        return reviews.ToList();
    }

    public async Task UpdateReviewReplyAsync(
        Guid restaurantId,
        Guid reviewId,
        string reply,
        CancellationToken cancellationToken)
    {
        const string sql = """
            UPDATE dbo.RestaurantReviews
            SET OwnerReply = @OwnerReply
            WHERE RestaurantId = @RestaurantId AND ReviewId = @ReviewId
            """;

        await using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync(
            new CommandDefinition(
                sql,
                new { RestaurantId = restaurantId, ReviewId = reviewId, OwnerReply = reply },
                cancellationToken: cancellationToken));
    }
}
