using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;
using CafeEase.Model.Messages;

using CafeEase.Services.Database;
using Microsoft.EntityFrameworkCore;

using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

Console.WriteLine("CafeEase Subscriber started...");

var rabbitHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitUser = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest";
var rabbitPass = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";
var rabbitVHost = Environment.GetEnvironmentVariable("RABBITMQ_VIRTUALHOST") ?? "/";
var queueName = Environment.GetEnvironmentVariable("RABBITMQ_QUEUE") ?? "payment_completed";

var connString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection");
if (string.IsNullOrWhiteSpace(connString))
{
    Console.WriteLine("❌ Missing ConnectionStrings__DefaultConnection for Subscriber.");
    Environment.Exit(1);
}

var smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST");
var smtpPortStr = Environment.GetEnvironmentVariable("SMTP_PORT");
var smtpUser = Environment.GetEnvironmentVariable("SMTP_USERNAME");
var smtpPass = Environment.GetEnvironmentVariable("SMTP_PASSWORD");
var smtpFrom = Environment.GetEnvironmentVariable("SMTP_FROM") ?? "no-reply@cafeease.local";
var smtpEnabled = (Environment.GetEnvironmentVariable("SMTP_ENABLED") ?? "false").ToLower() == "true";
var smtpPort = int.TryParse(smtpPortStr, out var p) ? p : 587;

Console.WriteLine($"RabbitMQ: host={rabbitHost}, user={rabbitUser}, vhost={rabbitVHost}, queue={queueName}");
Console.WriteLine($"DB: {(string.IsNullOrWhiteSpace(connString) ? "❌ missing" : "✅ configured")}");
Console.WriteLine($"SMTP: {(smtpEnabled ? "ENABLED" : "DISABLED")}");

var dbOptions = new DbContextOptionsBuilder<CafeEaseDbContext>()
    .UseSqlServer(connString)
    .Options;

var factory = new ConnectionFactory
{
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
    durable: true,   
    exclusive: false,
    autoDelete: false,
    arguments: null);

await channel.BasicQosAsync(0, 1, false);

var consumer = new AsyncEventingBasicConsumer(channel);

consumer.ReceivedAsync += async (_, ea) =>
{
    Console.WriteLine("MESSAGE RECEIVED");

    try
    {
        var json = Encoding.UTF8.GetString(ea.Body.ToArray());
        var message = JsonSerializer.Deserialize<PaymentCompleted>(json);

        if (message == null)
        {
            Console.WriteLine("⚠️ Received invalid PaymentCompleted message (null).");
            await channel.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: false);
            return;
        }

        Console.WriteLine($"📩 PaymentCompleted: Order={message.OrderId}, Amount={message.Amount}, User={message.UserId}");

        await using (var db = new CafeEaseDbContext(dbOptions))
        {
            var user = await db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == message.UserId);
            if (user == null)
                throw new Exception($"User not found (UserId={message.UserId})");

            var notif = new Notification
            {
                UserId = user.Id,
                OrderId = message.OrderId,
                Title = "Payment successful",
                Body = $"Your payment for order #{message.OrderId} has been recorded. Amount: {message.Amount:0.00}.",
                IsRead = false,
                CreatedAt = DateTime.Now
            };

            db.Notifications.Add(notif);
            await db.SaveChangesAsync();

            if (smtpEnabled)
            {
                await SendEmailAsync(
                    toEmail: user.Email,
                    subject: "CafeEase - Payment confirmation",
                    bodyText: $"Hello {user.FirstName},\n\nPayment for order #{message.OrderId} has been successfully recorded.\nAmount: {message.Amount:0.00}\n\nThank you!\nCafeEase",
                    smtpHost: smtpHost!,
                    smtpPort: smtpPort,
                    smtpUser: smtpUser,
                    smtpPass: smtpPass,
                    smtpFrom: smtpFrom
                );
            }
        }

        await channel.BasicAckAsync(ea.DeliveryTag, multiple: false);
        Console.WriteLine("✅ Processed + ACK");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Processing failed: {ex.Message}");

        await channel.BasicNackAsync(ea.DeliveryTag, multiple: false, requeue: true);
    }
};
Console.WriteLine("Before BasicConsumeAsync");

await channel.BasicConsumeAsync(
    queue: queueName,
    autoAck: false,
    consumer: consumer);

Console.WriteLine("After BasicConsumeAsync");

Console.WriteLine("Listening for messages...");
await Task.Delay(Timeout.Infinite);

static async Task SendEmailAsync(
    string toEmail,
    string subject,
    string bodyText,
    string smtpHost,
    int smtpPort,
    string? smtpUser,
    string? smtpPass,
    string smtpFrom)
{
    var msg = new MimeMessage();
    msg.From.Add(MailboxAddress.Parse(smtpFrom));
    msg.To.Add(MailboxAddress.Parse(toEmail));
    msg.Subject = subject;
    msg.Body = new TextPart("plain") { Text = bodyText };

    using var client = new SmtpClient();

    await client.ConnectAsync(smtpHost, smtpPort, SecureSocketOptions.StartTlsWhenAvailable);

    if (!string.IsNullOrWhiteSpace(smtpUser) && !string.IsNullOrWhiteSpace(smtpPass))
        await client.AuthenticateAsync(smtpUser, smtpPass);

    await client.SendAsync(msg);
    await client.DisconnectAsync(true);

    Console.WriteLine($"📧 Email sent to {toEmail}");
}