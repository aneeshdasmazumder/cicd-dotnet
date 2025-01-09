using Microsoft.AspNetCore.Mvc;

namespace DotNetCoreApp.Controllers;

[ApiController]
[Route("[controller]")]
public class HelloController : ControllerBase
{
    [HttpGet]
    public string Get()
    {
        return "Hello, DevOps World!";
    }
}
