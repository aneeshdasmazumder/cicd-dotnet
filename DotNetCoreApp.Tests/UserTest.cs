using DotNetCoreApp.Models;
using Xunit;

namespace DotNetCoreApp.Tests
{
    public class UserTest
    {
        [Fact]
        public void User_Id_ShouldBeSetAndRetrievedCorrectly()
        {
            // Arrange
            var user = new User();

            // Act
            user.Id = 1;

            // Assert
            Assert.Equal(1, user.Id);
        }

        [Fact]
        public void User_Name_ShouldBeSetAndRetrievedCorrectly()
        {
            // Arrange
            var user = new User();

            // Act
            user.Name = "John Doe";

            // Assert
            Assert.Equal("John Doe", user.Name);
        }

        [Fact]
        public void User_Email_ShouldBeSetAndRetrievedCorrectly()
        {
            // Arrange
            var user = new User();

            // Act
            user.Email = "john.doe@example.com";

            // Assert
            Assert.Equal("john.doe@example.com", user.Email);
        }
    }
}