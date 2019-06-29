using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using PUCIT.AIMRL.PRM.MainApp.Security;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{

    [AuthorizedForWebAPI]
    public class BaseDataController : ApiController
    {        

    }
}