using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.MainApp.Models;
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp.Controllers
{
    public class AdminController : BaseController
    {
      
        public ActionResult Index()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perCanLoginAsOtherUser == false
                && PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageWorkFlows == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult LoginAs()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perCanLoginAsOtherUser==false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View("LoginAsAnotherUser");
            }
        }
        

        public ActionResult ApplicationWorkFlow()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageWorkFlows == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }

        public ActionResult back()
        {

                return View("Index","Home");
            
        }
        

    }
}
