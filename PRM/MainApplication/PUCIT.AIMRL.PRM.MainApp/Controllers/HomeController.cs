using MvcSiteMapProvider.Web.Mvc.Filters;
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
    public class HomeController : BaseController
    {
        // GET: /Home/
        public ActionResult Index()
        {
            return View("Dashboard");
        }

        public ActionResult Forms()
        {
            
            if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.PerCanWriteApplication == false)
            {
                TempData["Message"] = "Unauthorized access!";
                return RedirectToAction("Index");
            }


            var currUser = SessionManager.CurrentUser;

            ViewBag.Name = currUser.UserFullName;
            ViewBag.RollNo = currUser.Login;
            ViewBag.FatherName = currUser.StdFatherName;
            ViewBag.Section = currUser.Section;

            return View();
        }

        //public ActionResult FormApplications()
        //{
        //    if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.PerCanWriteApplication == false)
        //    {
        //        TempData["Message"] = "Unauthorized access!";
        //        return RedirectToAction("Index");
        //    }


        //    var currUser = SessionManager.CurrentUser;

        //    ViewBag.Name = currUser.UserFullName;
        //    ViewBag.RollNo = currUser.Login;
        //    ViewBag.FatherName = currUser.StdFatherName;
        //    ViewBag.Section = currUser.Section;

        //    return View();
        //}

        [SiteMapTitle("id")] // ???
        public ActionResult Inbox(string id)
        {
            Boolean isStudent = false;
            if (SessionManager.CurrentUser.Roles.Contains("Student") == true)
            {
                isStudent = true;
            }

            int d = 0;
            Int32.TryParse(id, out d);

            if (d > 0)
            {
                ViewBag.ViewId = Convert.ToInt32(id);
                ViewBag.isStudent = isStudent;
            }
            else
            {
                ViewBag.ViewId = 0;
                ViewBag.isStudent = isStudent;
            }

            return View("tryInbox");
        }
        [SiteMapTitle("id")]
        public ActionResult ApplicationView(string id)
        {
            
            int d = 0;
            Int32.TryParse(id, out d);
            ApplicationAccessData data = null;

            if (d > 0)
            {
                ApplicationViewRepository repo = new ApplicationViewRepository();
                data = repo.GetApplicationAccessData(d);

                //var flag = repo.IsRequestIDValid(d);

                if (data != null && data.IsValidAccess == false)
                {
                    TempData["Message"] = "Invalid Request ID";
                    return RedirectToAction("Index");
                }
            }
            else
            {
                TempData["Message"] = "Invalid Request ID";
                return RedirectToAction("Index");
            }
            ViewBag.ReqUniqueId = data.ReqUniqueId;
            ViewBag.id = d;
            return View("ApplicationView", data);
        }

        public ActionResult OurTeam()
        {

            return View();
        }

        public ActionResult ChangePassword()
        {

            return View();
        }

        public ActionResult Application(string id)
        {
            return View();
        }
        public ActionResult Dashboard()
        {
            return View();
        }
    }
}