using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Runtime.Serialization;
using System.Reflection;
using System.Data;
using System.Runtime.Serialization.Formatters.Binary;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using System.Configuration;
using PUCIT.AIMRL.Common.Logger;
using PUCIT.AIMRL.PRM.UI.Common;
using PUCIT.AIMRL.PRM.DAL;



namespace PUCIT.AIMRL.PRM.MainApp.Util
{


    public static class Utility
    {

        public static String GetRequestedPageName()
        {
            String pageName = "";

            String[] completeURL = System.Web.HttpContext.Current.Request.ServerVariables["URL"].ToString().Split('/');
            pageName = completeURL[completeURL.Length - 1].ToString();

            return pageName;
        }
        public static String GetUserIPAddress()
        {
            var ipAddress = HttpContext.Current.Request.Headers["X-Forwarded-For"];
            if (String.IsNullOrEmpty(ipAddress))
                ipAddress = HttpContext.Current.Request.UserHostAddress.ToString();

            return ipAddress;
        }

        /// <summary>
        /// Writes a log entry for an exception to file, database and email as specified in configuration
        /// </summary>
        /// <param name="pEx">Exception object</param>
        public static void HandleException(Exception pEx)
        {
            PUCIT.AIMRL.Common.Logger.LogHandler.WriteLog(GetUserNameForLogging(), pEx.Message, Common.Logger.LogType.ErrorMsg, pEx);
        }

        public static void LogData(String pLogEntry)
        {
            PUCIT.AIMRL.Common.Logger.LogHandler.WriteLog(GetUserNameForLogging(), pLogEntry, Common.Logger.LogType.InfoMsg);
        }

        private static String GetUserNameForLogging()
        {
            var userName = "";
            var dto = SessionManager.CurrentUser;
            if (dto != null)
                userName = dto.Login;

            //if (HttpContext.Current.Request.UserHostAddress != null)
                userName += "-IP:" + Utility.GetUserIPAddress();

            if (HttpContext.Current.Request.Url != null && HttpContext.Current.Request.Url.PathAndQuery != null)
                userName += "-URL: " + HttpContext.Current.Request.Url.AbsoluteUri;

            return userName;
        }



        public static String GetFileSizeFromBytes(int sizeInBytes)
        {
            if (sizeInBytes < 1024)
                return sizeInBytes + " B";
            else if (sizeInBytes >= 1024 && sizeInBytes < (1024 * 1024))
                return Math.Round((sizeInBytes / 1024.0), 2) + " KB";
            else if (sizeInBytes >= (1024 * 1024))
                return Math.Round((sizeInBytes / (1024.0 * 1024.0)), 2) + " MB";
            return "";
        }

        public static void LoadApplicationSettingFromWebConfig()
        {
            Boolean flag = false;
            Boolean.TryParse(ConfigurationManager.AppSettings["IsCSEncrypted"], out flag);

            GlobalDataManager.IsCSEncrypted = flag;

            Boolean.TryParse(ConfigurationManager.AppSettings["EnableOptimization"], out flag);
            GlobalDataManager.EnableOptimization = flag;

            Boolean.TryParse(ConfigurationManager.AppSettings["IgnoreHashing"], out flag);
            GlobalDataManager.IgnoreHashing = flag;

            Boolean.TryParse(ConfigurationManager.AppSettings["UseGmailSMTP"], out flag);
            GlobalDataManager.UseGmailSMTP = flag;

            Boolean.TryParse(ConfigurationManager.AppSettings["EnableRecaptcha"], out flag);
            GlobalDataManager.EnableRecaptcha = flag;

            Boolean.TryParse(ConfigurationManager.AppSettings["EnableGoogleAuthentication"], out flag);
            GlobalDataManager.EnableGoogleAuthentication = flag;

            String FromAddress = ConfigurationManager.AppSettings["FromAddress"];
            String FromDisplayName = ConfigurationManager.AppSettings["FromDisplayName"];
            String SMTPServer = ConfigurationManager.AppSettings["SMTPServer"];
            String SMTPPort = ConfigurationManager.AppSettings["SMTPPort"];
            String SMTPUser = ConfigurationManager.AppSettings["SMTPUser"];
            String SMTPPassword = ConfigurationManager.AppSettings["SMTPPassword"];

            if (GlobalDataManager.UseGmailSMTP)
            {
                GlobalDataManager._emailhandler = new PUCIT.AIMRL.Common.GmailEmailHandler( 
                    pSMTPHost : SMTPServer,
                    pPort : SMTPPort,
                    pUserLogin : SMTPUser,
                    pPassword : SMTPPassword,
                    pFromEmailAddress : FromAddress,
                    pFromDisplayName : FromDisplayName
                );
            }
            else
            {
                GlobalDataManager._emailhandler = new PUCIT.AIMRL.Common.GoDaddyEmailHandler(
                    pSMTPHost: SMTPServer,
                    pPort: SMTPPort,
                    pFromEmailAddress: FromAddress,
                    pFromDisplayName: FromDisplayName
                );
            }

            GlobalDataManager.PageTitlePrefix = ConfigurationManager.AppSettings["PageTitlePrefix"];
            GlobalDataManager.BuildVersion = ConfigurationManager.AppSettings["BuildVersion"];

            GlobalDataManager.ReCaptchaSiteKey = ConfigurationManager.AppSettings["ReCaptchaSiteKey"];
            GlobalDataManager.ReCaptchaSecretKey = ConfigurationManager.AppSettings["ReCaptchaSecretKey"];

            GlobalDataManager.G_CLIENT_ID = ConfigurationManager.AppSettings["G_CLIENT_ID"];
            GlobalDataManager.G_CLIENT_SECRET = ConfigurationManager.AppSettings["G_CLIENT_SECRET"];
            GlobalDataManager.G_RedirectUrl = ConfigurationManager.AppSettings["G_RedirectUrl"];
        }
        public static void LoadGlobalSettings()
        {
            LoadApplicationSettingFromWebConfig();

            var dal = new PRMDataService();

            GlobalDataManager.FormCategoriesList = dal.GetAllFormCategories();

            //GlobalDataManager.MessagesList = dal.GetAllNotificationMessages();

        }


    }


}

