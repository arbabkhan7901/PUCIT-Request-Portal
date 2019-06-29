using Newtonsoft.Json;
using PUCIT.AIMRL.Common;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.Enum;
using PUCIT.AIMRL.PRM.MainApp.Models;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Text;
using System.Web;
using System.Web.Configuration;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp.Controllers
{
    public class LoginController : Controller
    {

        public ActionResult Index(String id)
        {
            ViewBag.AT = id;
            ViewBag.Title = PUCIT.AIMRL.PRM.UI.Common.GlobalDataManager.PageTitlePrefix + "Login";
            return View("login");
        }

        public ActionResult Index2()
        {
            ViewBag.Title = PUCIT.AIMRL.PRM.UI.Common.GlobalDataManager.PageTitlePrefix + "Login";
            return View("login");
        }
        public ActionResult ResetPassword1(string rt)
        {
            if (SessionManager.IsUserLoggedIn)
            {
                return RedirectToAction("Index", "Home");
            }
            else
            {
                try
                {
                    UserInfoRepository repo = new UserInfoRepository();
                    if (repo.IsValidResetToken(rt))
                    {
                        ViewBag.data = rt;
                        return View();
                    }
                    else
                    {
                        TempData["Msg"] = "Invalid password reset token!";
                        return RedirectToAction("Index");
                    }
                }
                catch (Exception ex)
                {
                    return RedirectToAction("Index");
                }
            }

        }

        public ActionResult ForgotPassword()
        {
            return PartialView("ForgotPassword");
        }
        public ActionResult LoginPanel()
        {
            return PartialView("LoginPanel");
        }
        public ActionResult AdminLogin()
        {
            return View("AdminLogin");
        }
        public ActionResult test()
        {
            return View("test");
        }

        public ActionResult SignOut()
        {

            if (SessionManager.IsUserLoggedIn && SessionManager.LogsInAsOtherUser)
            {
                //int userid = SessionManager.ActualUserUserID;
                //Boolean IsLoggedInAsOtherUser = SessionManager.LogsInAsOtherUser;
                //PUCIT.AIMRL.PRM.Entities.DBEntities.User user = new PRMDataContext().Users.Where(x => x.UserId == userid).FirstOrDefault();

                UserInfoRepository repo = new UserInfoRepository();
                repo.ValidateUser(SessionManager.ActualUserLoginID, "", LoginType.LoginBack);

                SessionManager.ActualUserUserID = 0;
                SessionManager.LogsInAsOtherUser = false;
                SessionManager.ActualUserLoginID = "";
                SessionManager.CanDecideOnBehalfOfOther = false;

                return RedirectToAction("Index", "Home");
            }
            else
            {
               // SessionManager.AbandonSession();

                return RedirectToAction("Index", "Login", new { id=0 });
            }
        }
        public ActionResult GoogleApi()
        {

            var gAccessToken = PUCIT.AIMRL.GoogleApi.GoogleApiAuthenticator.GetAccessToken(Request.Url.Query,
                GlobalDataManager.G_CLIENT_ID,
                GlobalDataManager.G_CLIENT_SECRET,
                GlobalDataManager.G_RedirectUrl);

            if (gAccessToken != null && !String.IsNullOrEmpty(gAccessToken.access_token))
            {
                var gUserProfile = PUCIT.AIMRL.GoogleApi.GoogleApiAuthenticator.GetUserProfileData(gAccessToken.access_token);
                //call validate User function
                UserInfoRepository repo = new UserInfoRepository();
                ResponseResult validationResponse = repo.ValidateUser(gUserProfile.email, "", LoginType.GoogleLogin);
                if (validationResponse.success == true)
                {
                    TempData["AT"] = gAccessToken.access_token;
                    return Redirect("~");
                }
                else
                {
                    if (gUserProfile.email.EndsWith("pucit.edu.pk"))
                    {
                        var id = repo.SaveGmailLoginRequest(gUserProfile.email, gUserProfile.name, gUserProfile.id, gUserProfile.picture);
                        if(id > 0){
                            TempData["Msg"] = "Your user doesn't exist in system but your login request is noted for approval.";
                        }
                        else
                        {
                            TempData["Msg"] = validationResponse.error;
                        }
                    }
                    else
                    {
                        TempData["Msg"] = validationResponse.error;
                    }
                    
                    return Redirect(Resources.PAGES_DEFAULT_LOGIN_PAGE);
                }//end of else
            }
            else
            {
                TempData["Msg"] = "Unable to get user's detail from Google";
                return Redirect(Resources.PAGES_DEFAULT_LOGIN_PAGE);
            }
            
        }//end of GoogleApi function

        
    }

    
}
