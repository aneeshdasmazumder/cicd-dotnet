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
                var user = new User { Id = 1, Name = "Test User" };
                context.Users.Add(user);
                context.SaveChanges();
            }

            using (var context = new AppDbContext(options))
            {
                Assert.Equal(1, context.Users.Count());
                Assert.Equal("Test User", context.Users.Single().Name);
            }
        }

        [Fact]
        public void CanRetrieveUserFromDatabase()
        {
            var options = GetDbContextOptions();

            using (var context = new AppDbContext(options))
            {
                var user = new User { Id = 1, Name = "Test User" };
                context.Users.Add(user);
                context.SaveChanges();
            }

            using (var context = new AppDbContext(options))
            {
                var user = context.Users.Single();
                Assert.Equal(1, user.Id);
                Assert.Equal("Test User", user.Name);
            }
        }
    }
}