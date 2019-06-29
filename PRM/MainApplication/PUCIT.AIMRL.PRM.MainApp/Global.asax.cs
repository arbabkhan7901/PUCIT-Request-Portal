using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.MainApp.Utils.HttpFilters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.SessionState;

namespace PUCIT.AIMRL.PRM.MainApp
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        private const string _WebApiPrefix = "aapi";
        private static string _WebApiExecutionPath = String.Format("~/{0}", _WebApiPrefix);

        protected void Application_Start()
        {
            PUCIT.AIMRL.Common.Logger.LogHandler.ConfigureLogger(Server.MapPath("~/logging.config"));
            PUCIT.AIMRL.Common.EncryptDecryptUtility.SetParameters("pUcITaImRLarrRPRojecT", "pUcITaImRLarrRPRojecT", "MD5", 50, "aIMRLpuCIToReRPJ", 256);

            AreaRegistration.RegisterAllAreas();

            try
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.LoadGlobalSettings();
            }
            catch (Exception ex)
            {
                //Utility.HandleException(ex);
            }

            WebApiConfig.Register(GlobalConfiguration.Configuration);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            var xmlFormatters = GlobalConfiguration.Configuration.Formatters.XmlFormatter;
            var appXmlType = xmlFormatters.SupportedMediaTypes.FirstOrDefault(t => t.MediaType == "application/xml");
            GlobalConfiguration.Configuration.Formatters.XmlFormatter.SupportedMediaTypes.Remove(appXmlType);


            GlobalConfiguration.Configuration.Filters.Add(new CustomExceptionFilterAttribute());

            try
            {
                //Create UploadedFiles folder if it doesn't exist
                var uploadedFilesPath = HttpContext.Current.Server.MapPath("~/UploadedFiles");

                if (!System.IO.Directory.Exists(uploadedFilesPath))
                {
                    System.IO.Directory.CreateDirectory(uploadedFilesPath);
                }
            }
            catch (Exception ex)
            {
                Util.Utility.HandleException(ex);
            }

            try
            {
                //Create TempFiles folder if it doesn't exist
                var uploadedFilesPath = HttpContext.Current.Server.MapPath("~/TempFiles");

                if (!System.IO.Directory.Exists(uploadedFilesPath))
                {
                    System.IO.Directory.CreateDirectory(uploadedFilesPath);
                }
            }
            catch (Exception ex)
            {
                Util.Utility.HandleException(ex);
            }

            try
            {
                //Create TempFiles folder if it doesn't exist
                var uploadedFilesPath = HttpContext.Current.Server.MapPath("~/Barcodes");

                if (!System.IO.Directory.Exists(uploadedFilesPath))
                {
                    System.IO.Directory.CreateDirectory(uploadedFilesPath);
                }
            }
            catch (Exception ex)
            {
                Util.Utility.HandleException(ex);
            }
        }

        protected void Application_PostAuthorizeRequest()
        {
            if (IsWebApiRequest())
            {
                HttpContext.Current.SetSessionStateBehavior(SessionStateBehavior.Required);
            }
        }

        private static bool IsWebApiRequest()
        {
            return HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath.StartsWith(_WebApiExecutionPath);
        }
    }
}