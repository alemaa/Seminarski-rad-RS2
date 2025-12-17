using CafeEase.Model.SearchObjects;
using CafeEase.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CafeEase.WebAPI.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TablesController : BaseCRUDController<Model.Table, TableSearchObject, Model.Requests.TableInsertRequest, Model.Requests.TableUpdateRequest>
    {
        public TablesController(ILogger<BaseController<CafeEase.Model.Table, TableSearchObject>> logger, ITableService service) : base(logger, service)
        {
        }
    }
}
