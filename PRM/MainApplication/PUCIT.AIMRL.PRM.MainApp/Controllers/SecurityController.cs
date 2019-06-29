using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp.Controllers
{
    public class SecurityController : BaseController
    {
        //
        // GET: /Admin/
        public ActionResult Index()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityUsers == false
                && PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityRoles == false
                && PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityPermissions == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult AddUserbulk()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityUsers == false)  {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult Users()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityUsers== false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult Roles()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityRoles == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                ViewBag.Id = 1;
                return View();
            }
        }
        public ActionResult Permissions()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityPermissions == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                ViewBag.Id = 2;
                return View();
            }
        }
        public ActionResult GoogleUsers()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perManageSecurityUsers == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult AddNewItems()
        {
            return View();
        }

    }
}
