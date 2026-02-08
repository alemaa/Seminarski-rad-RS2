using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using CafeEase.Model.Messages;
using System.Threading;
Console.WriteLine("CafeEase Subscriber started...");

var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
var rabbitVHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
var queueName = Environment.GetEnvironmentVariable("RABBITMQ_QUEUE") ?? "payment_completed";

Console.WriteLine($"RabbitMQ: user={rabbitUser}, vhost={rabbitVHost}, queue={queueName}");

if (string.IsNullOrWhiteSpace(rabbitHost))
{
    Console.WriteLine("❌ RabbitMQ host missing. Set RABBITMQ_HOST.");
    return;
}

var factory = new ConnectionFactory {
    HostName = rabbitHost,
    UserName = rabbitUser,
    Password = rabbitPass,
    VirtualHost = rabbitVHost,
};

IConnection? connection = null;

for (int i = 1; i <= 30; i++)
{
    try
    {
        connection = await factory.CreateConnectionAsync();
        Console.WriteLine("✅ Connected to RabbitMQ.");
        break;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"⏳ RabbitMQ not ready ({i}/30): {ex.Message}");
        await Task.Delay(3000);
    }
}

if (connection == null)
{
    Console.WriteLine("❌ Could not connect to RabbitMQ after retries.");
    Environment.Exit(1);
}

var channel = await connection.CreateChannelAsync();

await channel.QueueDeclareAsync(
    queue: queueName,
    durable: false,
    exclusive: false,
    autoDelete: false);

var consumer = new AsyncEventingBasicConsumer(channel);

consumer.ReceivedAsync += async (model, ea) =>
{
    var json = Encoding.UTF8.GetString(ea.Body.ToArray());
    var message = JsonSerializer.Deserialize<PaymentCompleted>(json);

    if (message == null)
    {
        Console.WriteLine("Received invalid PaymentCompleted message (null).");
        return;
    }

    Console.WriteLine($"PaymentCompleted: Order={message.OrderId}, Amount={message.Amount}, User={message.UserId}");

    await Task.CompletedTask;
};

await channel.BasicConsumeAsync(
    queue: queueName,
    autoAck: true,
    consumer: consumer);

Console.WriteLine("Listening for messages...");
await Task.Delay(Timeout.Infinite);
