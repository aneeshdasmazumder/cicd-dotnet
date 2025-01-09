using Xunit;
using Microsoft.AspNetCore.Mvc;
using DotNetCoreApp.Controllers; // Update the namespace to match your controller's namespace

public class HelloControllerTests
{
    [Fact]
    public void Get_ReturnsExpectedMessage()
    {
        // Arrange
        var controller = new HelloController();

        // Act
        var result = controller.Get();

        // Assert
        Assert.Equal("Hello, DevOps World!", result); // Compare the returned string
    }
}
