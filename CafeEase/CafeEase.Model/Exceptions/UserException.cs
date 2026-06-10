using System;

namespace CafeEase.Model.Exceptions
{
    public class UserException : Exception
    {
        public UserException(string message)
            : base(message)
        {
        }
    }
}
