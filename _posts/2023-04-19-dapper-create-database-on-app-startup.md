---
layout: post
title: dapper create database on app startup
date: 2023-04-19 18:59 +0300

categories: [development, databases]
tags: [postgres, dotnet-7, auto-migration, databases, docker]

---
## Using Dapper to auto-migrate a postgres database and create the database


- code example : [HERE](https://github.com/CanaanGM/Microservices-in-dotnet/blob/main/src/Services/Discount/Discount.API/Extensions/HostExtensions.cs)

1. create an Extension folder with a HostExtensions static class.
2. inside it create a static generic method that takes the host (what configures the startup and lifetime of the app) which returns it after it's done.
    - we add a **retry** cause when running in a docker-compose, the databse being ready isn't a gurantee even with `depends-on` specified.

    ```c#
    public static class HostExtensions
    {
        public static IHost MigrateDatabase<TContext>(this IHost host, int? retry = 0)
        {
        }
    }
    ```
3. create a `scope` from `host.Services.CreateScope()` and get the required services 
    ```c#
    using (var scope = host.Services.CreateScope())
    {
        var services = scope.ServiceProvider;
        var configuration = services.GetRequiredService<IConfiguration>();
        var logger = services.GetRequiredService<ILogger<TContext>>();
    }
    ```
4. in there add a `try` and `catch` blocks, ***log*** depending on your desire and create a connection object using the `using` scope so it releases (closes) the connection when it's done.
    - the connection string for `postgres` **needs** to **NOT** have the **database name**, it'll look like this:
      ```txt
        "DatabaseSettings": {
            "ConnectionString": "Server=HOST;Port=PORT;User Id=USER;Password=PASS;",
            "DatabaseName":"db-name" <- needs to be lower case !
         }
      ```

    ```c#
    logger.LogInformation("Migrating postresql database.");

    using var connection = new NpgsqlConnection(configuration.GetValue<string>("DatabaseSettings:ConnectionString"));
    // open the connection
    connection.Open();
    // get the database name from `appsettings.json` or where'ver you have it
    string dbName = configuration["DatabaseSettings:DatabaseName"];

    ```

5. check if the database you're trying to create exists or not, the name of the database **has** to be *lower case* to match the one postgres will create.

    ```c#
    var checkDatabaseExistsSql = $"SELECT 1 FROM pg_database WHERE datname = '{dbName}'";
    var databaseExists = connection.ExecuteScalar<bool>(checkDatabaseExistsSql);

    if (!databaseExists)
    {
        var createDatabaseSql = $"CREATE DATABASE {dbName};";
        connection.Execute(createDatabaseSql);
    }
    ```
6. kill the existsing connection and create a new one that'll have the `database` you wanna use in it, open it and create a `command` object so you can do the operations you desire:
    ```c#
    connection.Close();

    // replace the old connection with a new one with the database
    using var updatedConnection = new NpgsqlConnection($"{configuration["DatabaseSettings:ConnectionString"]}Database={dbName};");
    
    updatedConnection.Open();

    using var command = new NpgsqlCommand
    {
        Connection = updatedConnection
    };
    ```
    ```c#
    command.CommandText = "DROP TABLE IF EXISTS TABLE-NAME";
    command.ExecuteNonQuery();

    command.CommandText = @"CREATE TABLE TABLE(Id SERIAL PRIMARY KEY, 
                                                Name VARCHAR(24) NOT NULL,
                                                Description TEXT,
                                                ...
                                                )";
    command.ExecuteNonQuery();

    command.CommandText = "INSERT INTO TABLE_NAME(Name, Description) VALUES('STUFF', 'IN HERE');";
    command.ExecuteNonQuery();

    .
    .
    .

    logger.LogInformation("Migrated postresql database.");
    ```

7. in the `catch` block
    > we except a `NpgsqlException` exception and retry 

    ```c# 
    catch (NpgsqlException ex)
    {
        logger.LogError(ex, "An error occurred while migrating the postresql database");

        if (retryForAvailability < 50)
        {
            retryForAvailability++;
            System.Threading.Thread.Sleep(2000);
            MigrateDatabase<TContext>(host, retryForAvailability);
        }
    }
    ```
8. finally we return the `Host`
    ```c# 
    return host;
    ```
9. in `Program` file, we call it providing the `Program class` as the Type
    ```c#
    app.MigrateDatabase<Program>();
    ```

    ---

## test it

- spin up a postgres container

    ```bash
docker container run -p 5432:5432 -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin1234 --name testgres postgres
    ```

- create a new api project or use an open one and follow thru the steps upove

---

## refs:

1. [Host](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/host/web-host?view=aspnetcore-7.0)