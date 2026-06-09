using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using CafeEase.Model.SearchObjects;

namespace CafeEase.Services
{
    public interface INotificationService : IService<Model.Notification, NotificationSearchObject>
    {
        Task MarkAsRead(int id);
        Task MarkAllAsRead();
        Task CreateAsync(int userId, string title, string body, int? orderId = null);
        Task CreateForAdminsAsync(string title, string body, int? orderId = null);
    }
}
