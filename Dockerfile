# Stage 1: Build the application
# Purpose: Uses the official .NET SDK image, which includes tools for building and compiling .NET applications.
# Why Needed: The SDK provides everything necessary to restore, build, and publish the application.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy csproj and restore dependencies
# Purpose: Copies the .csproj file to the container and restores dependencies listed in it.
# Why Needed: Restoring dependencies before copying all files allows Docker to cache this step, saving time in future builds 
# if the dependencies haven't changed.
COPY DotNetCoreApp/*.csproj ./DotNetCoreApp/
RUN dotnet restore DotNetCoreApp/DotNetCoreApp.csproj

# Copy the remaining files and build the project
# Purpose:
#    Copies the source files into the container.
#    Sets the working directory to where the application resides.
#    Builds and publishes the application to the out directory.
# Why Needed: Produces a self-contained, optimized version of the application ready for deployment.
COPY DotNetCoreApp/. ./DotNetCoreApp/
WORKDIR /app/DotNetCoreApp
RUN dotnet publish -c Release -o out

# Stage 2: Create the runtime image
# Purpose: Uses the official ASP.NET runtime image, which is optimized for running ASP.NET Core applications.
# Why Needed: The runtime image excludes unnecessary build tools, resulting in a smaller and faster production image.
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Purpose: Copies the published application files from the build stage into the runtime container.
# Why Needed: Ensures only the necessary files for running the application are included in the final image.
COPY --from=build /app/DotNetCoreApp/out ./

# Expose the application port
# Purpose: Opens port 5000 for external access to the application.
# Why Needed: Makes the application accessible when running the container.
EXPOSE 5000

# Define the entry point for the application
# Purpose: Specifies the command to run when the container starts.
# Why Needed: Ensures the application (DotNetCoreApp.dll) starts correctly when the container is launched.
ENTRYPOINT ["dotnet", "DotNetCoreApp.dll"]
