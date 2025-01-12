using Xunit;
using Moq;
using Microsoft.AspNetCore.Mvc;
using DotNetCoreApp.Controllers;
using DotNetCoreApp.Models;
using DotNetCoreApp.Services;

namespace DotNetCoreApp.Tests
{
    public class UserControllerTest
    {
        private readonly Mock<IUserService> _mockUserService;
        private readonly UserController _controller;

        public UserControllerTest()
        {
            _mockUserService = new Mock<IUserService>();
            _controller = new UserController(_mockUserService.Object);
        }

        [Fact]
        public void GetUser_ReturnsOkResult_WithUser()
        {
            // Arrange
            var userId = 1;
            var user = new User { Id = userId, Name = "John Doe" };
            _mockUserService.Setup(service => service.GetUserById(userId)).Returns(user);

            // Act
            var result = _controller.GetUser(userId);

            // Assert
            var okResult = Assert.IsType<OkObjectResult>(result);
            var returnValue = Assert.IsType<User>(okResult.Value);
            Assert.Equal(userId, returnValue.Id);
            Assert.Equal("John Doe", returnValue.Name);
        }

        [Fact]
        public void GetUser_ReturnsNotFoundResult_WhenUserNotFound()
        {
            // Arrange
            var userId = 1;
            _mockUserService.Setup(service => service.GetUserById(userId)).Returns((User)null);

            // Act
            var result = _controller.GetUser(userId);

            // Assert
            Assert.IsType<NotFoundResult>(result);
        }

        [Fact]
        public void CreateUser_ReturnsCreatedAtActionResult_WithUser()
        {
            // Arrange
            var user = new User { Id = 1, Name = "John Doe" };
            _mockUserService.Setup(service => service.CreateUser(user)).Returns(user);

            // Act
            var result = _controller.CreateUser(user);

            // Assert
            var createdAtActionResult = Assert.IsType<CreatedAtActionResult>(result);
            var returnValue = Assert.IsType<User>(createdAtActionResult.Value);
            Assert.Equal(user.Id, returnValue.Id);
            Assert.Equal(user.Name, returnValue.Name);
        }

        [Fact]
        public void CreateUser_ReturnsBadRequestResult_WhenModelStateIsInvalid()
        {
            // Arrange
            var user = new User { Id = 1, Name = "John Doe" };
            _controller.ModelState.AddModelError("Name", "Required");

            // Act
            var result = _controller.CreateUser(user);

            // Assert
            Assert.IsType<BadRequestObjectResult>(result);
        }
    }
}