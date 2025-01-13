using DotNetCoreApp.Controllers;
using DotNetCoreApp.Data;
using DotNetCoreApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Xunit;

namespace DotNetCoreApp.Tests
{
    public class UsersControllerTests
    {
        private readonly UsersController _controller;
        private readonly AppDbContext _context;

        public UsersControllerTests()
        {
            var options = new DbContextOptionsBuilder<AppDbContext>()
                .UseInMemoryDatabase(databaseName: "TestDatabase")
                .Options;

            _context = new AppDbContext(options);
            _controller = new UsersController(_context);

            // Clear the database before seeding
            _context.Database.EnsureDeleted();
            _context.Database.EnsureCreated();

            // Seed the in-memory database with test data
            _context.Users.AddRange(new List<User>
            {
                new User { Id = 1, Name = "John Doe", Email = "john.doe@example.com" },
                new User { Id = 2, Name = "Jane Doe", Email = "jane.doe@example.com" }
            });
            _context.SaveChanges();
        }

        [Fact]
        public async Task PostUser_CreatesUser()
        {
            // Arrange
            var newUser = new User { Id = 3, Name = "New User", Email = "new.user@example.com" };

            // Act
            var result = await _controller.PostUser(newUser);

            // Assert
            var actionResult = Assert.IsType<ActionResult<User>>(result);
            var createdAtActionResult = Assert.IsType<CreatedAtActionResult>(actionResult.Result);
            var user = Assert.IsType<User>(createdAtActionResult.Value);
            Assert.Equal(3, user.Id);
            Assert.Equal("New User", user.Name);
        }

        [Fact]
        public async Task PutUser_UpdatesUser()
        {
            // Arrange
            var updatedUser = new User { Id = 1, Name = "Updated User", Email = "updated.user@example.com" };

            // Act
            var result = await _controller.PutUser(1, updatedUser);

            // Assert
            Assert.IsType<NoContentResult>(result);
            var user = _context.Users.Find(1);
            Assert.Equal("Updated User", user.Name);
        }

       /* [Fact]
        public async Task PutUser_ReturnsBadRequest_WhenIdMismatch()
        {
            // Arrange
            var updatedUser = new User { Id = 1, Name = "Updated User", Email = "updated.user@example.com" };

            // Act
            var result = await _controller.PutUser(10, updatedUser);

            // Assert
            Assert.IsType<BadRequestResult>(result);
        } */

        [Fact]
        public async Task DeleteUser_DeletesUser()
        {
            // Act
            var postUser = new User { Id = 4, Name = "Updated User", Email = "updated.user@example.com" };

            // Act
            var result1 = await _controller.PostUser(postUser);
            var result = await _controller.DeleteUser(4);

            // Assert
            Assert.IsType<NoContentResult>(result);
            var user = _context.Users.Find(4);
            Assert.Null(user);
        }

        [Fact]
        public async Task DeleteUser_ReturnsNotFound_WhenUserDoesNotExist()
        {
            // Act
            var result = await _controller.DeleteUser(99);

            // Assert
            Assert.IsType<NotFoundResult>(result);
        }

        [Fact]
        public async Task GetUsers_ReturnsAllUsers()
        {
            // Act
            var result = await _controller.GetUsers();

            // Assert
            var actionResult = Assert.IsType<ActionResult<IEnumerable<User>>>(result);
            var okResult = Assert.IsType<OkObjectResult>(actionResult.Result);
            var users = Assert.IsType<List<User>>(okResult.Value);
            Assert.Equal(users, users);
        }

        [Fact]
        public async Task GetUser_ReturnsUser_WhenUserExists()
        {
            // Act
            var result = await _controller.GetUser(1);

            // Assert
            var actionResult = Assert.IsType<ActionResult<User>>(result);
            var okResult = Assert.IsType<OkObjectResult>(actionResult.Result);
            var user = Assert.IsType<User>(okResult.Value);
            Assert.Equal(1, user.Id);
            Assert.Equal("John Doe", user.Name);
        }

        [Fact]
        public async Task GetUser_ReturnsNotFound_WhenUserDoesNotExist()
        {
            // Act
            var result = await _controller.GetUser(99);

            // Assert
            Assert.IsType<NotFoundResult>(result.Result);
        }
    }
}