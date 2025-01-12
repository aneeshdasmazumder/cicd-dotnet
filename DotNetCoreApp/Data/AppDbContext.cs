using Microsoft.EntityFrameworkCore;
using DotNetCoreApp.Models;

namespace DotNetCoreApp.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
        public DbSet<User> Users { get; set; }
    }
}
