using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CafeEase.Services
{
    public interface ITableService
        : ICRUDService<Model.Table, Model.SearchObjects.TableSearchObject, Model.Requests.TableInsertRequest, Model.Requests.TableUpdateRequest>
    {
    }
}