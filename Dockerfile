# Use the official .NET SDK image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80

# Stage 1: Build the application
# Use an official .NET SDK image for building and compiling the application.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy only the .csproj file(s) and restore dependencies.
# This step is optimized for caching; Docker will reuse the cache if the project file hasn't changed.
COPY ["DotNetCoreApp/DotNetCoreApp.csproj", "DotNetCoreApp/"]
RUN dotnet restore "DotNetCoreApp/DotNetCoreApp.csproj"

# Copy the remaining source files into the container.
# This step is separated to optimize caching when source files change.
COPY . .
WORKDIR "/src/DotNetCoreApp"

# Build and publish the application.
# Produces an optimized, self-contained application for production.
RUN dotnet build "DotNetCoreApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DotNetCoreApp.csproj" -c Release -o /app/publish

# Stage 2: Create the runtime image
# Use the official ASP.NET runtime image, optimized for running ASP.NET Core apps.
FROM base AS final
WORKDIR /app

# Copy the published application from the build stage.
COPY --from=publish /app/publish .

# Set the user to a non-root user (optional for enhanced security).
# USER appuser

# Expose the application port.
EXPOSE 80

# Define the entry point for the application.
ENTRYPOINT ["dotnet", "DotNetCoreApp.dll"]
