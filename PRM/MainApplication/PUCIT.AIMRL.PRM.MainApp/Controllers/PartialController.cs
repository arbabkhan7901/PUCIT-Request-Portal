using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp.Controllers
{
    public class PartialController : BaseController
    {
        public ActionResult YesNoModal()
        {
            return PartialView();
        }

    }
}
