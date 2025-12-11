using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using CafeEase.Model.Messages;

Console.WriteLine("CafeEase Subscriber started...");

var factory = new ConnectionFactory { 
    HostName = "localhost"
};

var connection = await factory.CreateConnectionAsync();
var channel = await connection.CreateChannelAsync();

await channel.QueueDeclareAsync(
    queue: "payment_completed",
    durable: false,
    exclusive: false,
    autoDelete: false);

var consumer = new AsyncEventingBasicConsumer(channel);

consumer.ReceivedAsync += async (model, ea) =>
{
    var json = Encoding.UTF8.GetString(ea.Body.ToArray());
    var message = JsonSerializer.Deserialize<PaymentCompleted>(json);

    Console.WriteLine($"PaymentCompleted: Order={message.OrderId}, Amount={message.Amount}, User={message.UserId}");

    await Task.CompletedTask;
};

await channel.BasicConsumeAsync(
    queue: "payment_completed",
    autoAck: true,
    consumer: consumer);

Console.WriteLine("Listening for messages...");
Console.ReadLine();
