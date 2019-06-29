
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp.Controllers
{
    public class ReportsController : BaseController
    {
        public ActionResult Index()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewApplicationCountStatuswise == false
                && PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewLoginHistoryReport == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }

        public ActionResult ApplicationStatusesWRTUsers()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewApplicationCountStatuswise == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
          
        }


        public ActionResult UserLoginHistory()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewLoginHistoryReport== false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult ContactUsReport()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewLoginHistoryReport == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult ForgotPasswordLog()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewLoginHistoryReport == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                return View();
            }
        }
        public ActionResult ShowActivityLog()
        {
            //if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perCanSeeActivityLog == false)
            //{
            //    return RedirectToAction("Index", "Home");
            //}
            return View("ShowActivityLog");
        }
        public ActionResult ItemsReport()
        {
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perViewItemsReport == false)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {

                var currUser = SessionManager.CurrentUser;

                ViewBag.Name = currUser.UserFullName;
                ViewBag.Title = currUser.Title;
                ViewBag.Date = DateTime.Now.ToShortDateString();
                return View();
            }
        }
    }
}
