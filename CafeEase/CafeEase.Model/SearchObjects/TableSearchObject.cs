using System;

namespace CafeEase.Model.SearchObjects
{
    public class TableSearchObject : BaseSearchObject
    {
        public bool? IsOccupied { get; set; }
        public int? Capacity { get; set; }
        public DateTime? Date { get; set; }
        public int? Number { get; set; }
    }
}
