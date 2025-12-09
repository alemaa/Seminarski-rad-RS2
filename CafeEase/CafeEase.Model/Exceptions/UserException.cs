using System;

namespace CafeEase.Services.Exceptions
{
    public class UserException : Exception
    {
        public UserException(string message)
            : base(message)
        {
        }
    }
}
