using Microsoft.EntityFrameworkCore;
using DotNetCoreApp.Data;
using DotNetCoreApp.Models;
using System.Linq;
using Xunit;

namespace DotNetCoreApp.Tests
{
    public class AppDbContextTest
    {
        private DbContextOptions<AppDbContext> GetDbContextOptions()
        {
            return new DbContextOptionsBuilder<AppDbContext>()
                .UseInMemoryDatabase(databaseName: "TestDatabase")
                .Options;
        }

        [Fact]
        public void CanAddUserToDatabase()
        {
            var options = GetDbContextOptions();

            using (var context = new AppDbContext(options))
            {
                context.Database.EnsureDeleted();
                context.Database.EnsureCreated();

                var user = new User { Id = 5, Name = "Test User", Email = "test.user@example.com" };
                context.Users.Add(user);
                context.SaveChanges();
            }

            using (var context = new AppDbContext(options))
            {
                var user = context.Users.Single(u => u.Id == 5);
                Assert.Equal("Test User", user.Name);
                Assert.Equal("test.user@example.com", user.Email);
            }
        }

        [Fact]
        public void CanRetrieveUserFromDatabase()
        {
            var options = GetDbContextOptions();

            using (var context = new AppDbContext(options))
            {
                context.Database.EnsureDeleted();
                context.Database.EnsureCreated();

                var user = new User { Id = 16, Name = "Test User", Email = "test.user@example.com" };
                context.Users.Add(user);
                context.SaveChanges();
            }

            using (var context = new AppDbContext(options))
            {
                var user = context.Users.Single(u => u.Id == 16);
                Assert.Equal("Test User", user.Name);
                Assert.Equal("test.user@example.com", user.Email);
            }
        }
    }
}