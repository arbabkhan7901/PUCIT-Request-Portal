using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Collections;
using PUCIT.AIMRL.PRM.Entities.DBEntities;

namespace PUCIT.AIMRL.PRM.UI.Common
{
    public static class GlobalDataManager
    {
        #region Private Data

        private static String FORMCATEGORIESLIST_KEY = "FormCategoriesData";

        #endregion
        public static String PageTitlePrefix = String.Empty;
        public static Boolean IsCSEncrypted = false;
        public static String BuildVersion = "";
        public static Boolean EnableOptimization = false;

        public static Boolean IgnoreHashing = false;

        public static String BasePath = VirtualPathUtility.ToAbsolute("~");

        public static Boolean UseGmailSMTP = false;
        public static String FromAddress = "";
        public static String SMTPServer = "";
        public static String SMTPPort = "";
        public static String SMTPUser = "";
        public static String SMTPPassword = "";

        public static Boolean EnableRecaptcha = false;
        public static String ReCaptchaSiteKey = "";
        public static String ReCaptchaSecretKey = "";

        public static Boolean EnableGoogleAuthentication = false;
        public static String G_CLIENT_ID = "";
        public static String G_CLIENT_SECRET = "";
        public static String G_RedirectUrl = "";


        public static PUCIT.AIMRL.Common.IEmailHandler _emailhandler = null;

        public static List<FormCategories> FormCategoriesList
        {
            get
            {
                if (ApplicationState[FORMCATEGORIESLIST_KEY] != null)
                    return ApplicationState[FORMCATEGORIESLIST_KEY] as List<FormCategories>;
                else
                    return new List<FormCategories>();
            }
            set
            {
                ApplicationState[FORMCATEGORIESLIST_KEY] = value;
            }
        }

        private static HttpApplicationState ApplicationState
        {
            get
            {
                return System.Web.HttpContext.Current.Application;
            }
        }
    }
}