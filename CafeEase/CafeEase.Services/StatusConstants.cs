using System.Collections.Generic;

namespace CafeEase.Services
{
    public static class OrderStatuses
    {
        public const string Pending = "Pending";
        public const string Confirmed = "Confirmed";
        public const string Paid = "Paid";
        public const string Completed = "Completed";
        public const string Cancelled = "Cancelled";

        public static readonly HashSet<string> All = new()
        {
            Pending,
            Confirmed,
            Paid,
            Completed,
            Cancelled
        };

        public static readonly Dictionary<string, HashSet<string>> AllowedTransitions = new()
        {
            [Pending] = new() { Confirmed, Cancelled },
            [Confirmed] = new() { Paid, Cancelled },
            [Paid] = new() { Completed },
            [Completed] = new(),
            [Cancelled] = new()
        };
    }

    public static class ReservationStatuses
    {
        public const string Pending = "Pending";
        public const string Confirmed = "Confirmed";
        public const string Cancelled = "Cancelled";

        public static readonly HashSet<string> All = new()
        {
            Pending,
            Confirmed,
            Cancelled
        };

        public static readonly Dictionary<string, HashSet<string>> AllowedTransitions = new()
        {
            [Pending] = new() { Confirmed, Cancelled },
            [Confirmed] = new() { Cancelled },
            [Cancelled] = new()
        };
    }
}
