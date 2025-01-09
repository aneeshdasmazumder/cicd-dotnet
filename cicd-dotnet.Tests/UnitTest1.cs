using MyDotNetApp.Controllers;
using Xunit;

public class HelloControllerTests
{
    [Fact]
    public void Get_ReturnsExpectedMessage()
    {
        var controller = new HelloController();
        var result = controller.Get();
        Assert.Equal("Hello, DevOps World!", result);
    }
}
