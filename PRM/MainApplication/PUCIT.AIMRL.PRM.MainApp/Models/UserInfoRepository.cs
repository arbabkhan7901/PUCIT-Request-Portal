using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Configuration;
using System.Collections;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using PUCIT.AIMRL.PRM.Entities.Security;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.MainApp.Security;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.Common;
using System.Net;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.Configuration;
using PUCIT.AIMRL.PRM.Entities.Enum;

namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class UserInfoRepository
    {
        private PRMDataService _dataService;
        public UserInfoRepository()
        {
        }
        private PRMDataService DataService
        {
            get
            {
                if (_dataService == null)
                    _dataService = new PRMDataService();

                return _dataService;
            }
        }

        private void HandlePermissions(List<string> permissionStrList)
        {
            //Set all permissions to false
            PermissionManager.PerCanAddContributer = false;
            PermissionManager.PerCanWriteApplication = false;
            PermissionManager.PerCanEditApplication = false;
            PermissionManager.PerCanApproveApplication = false;
            PermissionManager.PerCanRejectApplication = false;
            PermissionManager.PerCanPrintApplication = false;
            PermissionManager.PerCanGiveRemarks = false;
            PermissionManager.perCanProvideSignature = false;
            PermissionManager.perCanForwardApplication = false;
            PermissionManager.perCanAccessAttachedDocs = false;
            PermissionManager.perAccessToAssignedApps = false;
            PermissionManager.perAccessToSelfCreatedApps = false;
            PermissionManager.perAccessToAppsOtherThanSelfAssigned = false;
            PermissionManager.perAccessToAllApps = false;
            PermissionManager.PerCanHandleRecieving = false;
            PermissionManager.PerCanAllowApplicationEditing = false;
            PermissionManager.PerCanRouteBack = false;
            PermissionManager.PerUpdateBonaFiedCGPA = false;
            PermissionManager.perManageSecurityPermissions = false;
            PermissionManager.perManageSecurityRoles = false;
            PermissionManager.perManageSecurityUsers = false;
            PermissionManager.perManageWorkFlows = false;
            PermissionManager.perViewApplicationCountStatuswise = false;
            PermissionManager.perViewLoginHistoryReport = false;
            PermissionManager.perCanLoginAsOtherUser = false;
            PermissionManager.perDecideBehalfOnOtherUser = false;

            PermissionManager.perCanSwapRequestAssignmentWithApprover = false;
            PermissionManager.perCanAccessSelfAndAssigned = false;
            PermissionManager.perManageSecurityInventory = false;
            PermissionManager.perViewItemsReport = false;

            //Now check if permission list contains specific string, then make relevant boolean permission true
            if (permissionStrList.Contains("PERDECIDEBEHALFONOTHERUSER"))
                PermissionManager.perDecideBehalfOnOtherUser = true;

            if (permissionStrList.Contains("PERMANAGESECURITYPERMISSIONS"))
                PermissionManager.perManageSecurityPermissions = true;

            if (permissionStrList.Contains("PERMANAGESECURITYROLES"))
                PermissionManager.perManageSecurityRoles = true;

            if (permissionStrList.Contains("PERMANAGESECURITYUSERS"))
                PermissionManager.perManageSecurityUsers = true;

            if (permissionStrList.Contains("PERMANAGEWORKFLOWS"))
                PermissionManager.perManageWorkFlows = true;

            if (permissionStrList.Contains("PERVIEWAPPLICATIONCOUNTSTATUSWISE"))
                PermissionManager.perViewApplicationCountStatuswise = true;

            if (permissionStrList.Contains("PERVIEWLOGINHISTORYREPORT"))
                PermissionManager.perViewLoginHistoryReport = true;

            if (permissionStrList.Contains("PERCANLOGINASOTHERUSER"))
                PermissionManager.perCanLoginAsOtherUser = true;

            if (permissionStrList.Contains("CANADDCONTRIBUTOR"))
                PermissionManager.PerCanAddContributer = true;

            if (permissionStrList.Contains("CANWRITEAPPLICATION"))
                PermissionManager.PerCanWriteApplication = true;

            if (permissionStrList.Contains("CANEDITAPPLICATION"))
                PermissionManager.PerCanEditApplication = true;

            if (permissionStrList.Contains("CANAPPROVEAPPLICATION"))
                PermissionManager.PerCanApproveApplication = true;

            if (permissionStrList.Contains("CANREJECTAPPLICATION"))
                PermissionManager.PerCanRejectApplication = true;

            if (permissionStrList.Contains("CANPRINTAPPLICATION"))
                PermissionManager.PerCanPrintApplication = true;

            if (permissionStrList.Contains("CANGIVEREMARKS"))
                PermissionManager.PerCanGiveRemarks = true;

            if (permissionStrList.Contains("PERCANPROVIDESIGNATURE"))
                PermissionManager.perCanProvideSignature = true;

            if (permissionStrList.Contains("PERCANFORWARDAPPLICATION"))
                PermissionManager.perCanForwardApplication = true;

            if (permissionStrList.Contains("PERCANACCESSATTACHEDDOCS"))
                PermissionManager.perCanAccessAttachedDocs = true;

            if (permissionStrList.Contains("PERACCESSTOAPPSOTHERTHANSELFASSIGNED"))
                PermissionManager.perAccessToAppsOtherThanSelfAssigned = true;

            if (permissionStrList.Contains("PERACCESSTOASSIGNEDAPPS"))
                PermissionManager.perAccessToAssignedApps = true;

            if (permissionStrList.Contains("PERACCESSTOSELFCREATEDAPPS"))
                PermissionManager.perAccessToSelfCreatedApps = true;

            if (permissionStrList.Contains("PERACCESSTOALLAPPS"))
                PermissionManager.perAccessToAllApps = true;

            if (permissionStrList.Contains("PERCANHANDLERECIEVING"))
                PermissionManager.PerCanHandleRecieving = true;

            if (permissionStrList.Contains("PERCANALLOWAPPLICATIONEDITING"))
                PermissionManager.PerCanAllowApplicationEditing = true;

            if (permissionStrList.Contains("PERCANROUTEBACK"))
                PermissionManager.PerCanRouteBack = true;

            if (permissionStrList.Contains("PERUPDATEBONAFIEDCGPA"))
                PermissionManager.PerUpdateBonaFiedCGPA = true;

            if (permissionStrList.Contains("perCanSwapRequestAssignmentWithApprover".ToUpper()))
                PermissionManager.perCanSwapRequestAssignmentWithApprover = true;

            if (permissionStrList.Contains("perCanAccessSelfAndAssigned".ToUpper()))
                PermissionManager.perCanAccessSelfAndAssigned = true;

            if (permissionStrList.Contains("perManageSecurityInventory".ToUpper()))
                PermissionManager.perManageSecurityInventory = true;

            if (permissionStrList.Contains("PERVIEWITEMSREPORT"))
                PermissionManager.perViewItemsReport = true;
        }
        private class DummyDTO
        {
            public string success { get; set; }
        }

        //ReCaptcha Response Valdiation Function

        public bool CheckRecaptcha(string response)
        {
            bool isResponseValid = false;
            
            try
            {
                //Request to Google Server
                var url = String.Format("https://www.google.com/recaptcha/api/siteverify?secret={0}&response={1}", GlobalDataManager.ReCaptchaSecretKey, response);
                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);

                //Google recaptcha Response
                using (WebResponse wResponse = req.GetResponse())
                {
                    using (StreamReader readStream = new StreamReader(wResponse.GetResponseStream()))
                    {
                        string jsonResponse = readStream.ReadToEnd();

                        JavaScriptSerializer js = new JavaScriptSerializer();
                        DummyDTO data = js.Deserialize<DummyDTO>(jsonResponse);// Deserialize Json
                        isResponseValid = Convert.ToBoolean(data.success);
                    }
                }

                return isResponseValid;
            }
            catch (WebException ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return false;
            }
        }

        public ResponseResult ValidateUser(String login, String pPassword, LoginType pLoginType)
        {
            Boolean pIgnorePassword = false;
            //GlobalDataManager._emailhandler.SendEmail(new EmailMessageParam() { 
            //    ToIDs = "bilal.shahzad@yahoo.com",
            //    Subject = "Login Request: " + login,
            //    Body = "Testing Body"
            //});

            //Object dataToReturn = null;
            //Check to see if the user is provided the rights on the application
            try
            {

                var ipAddress = Utility.GetUserIPAddress();
                var currTime = DateTime.UtcNow;

                if (pLoginType == LoginType.LoginAs && SessionManager.IsUserLoggedIn == true)
                {
                    if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perDecideBehalfOnOtherUser == true)
                    {
                        SessionManager.CanDecideOnBehalfOfOther = true;
                    }
                    SessionManager.LogsInAsOtherUser = true;
                    SessionManager.ActualUserUserID = SessionManager.CurrentUser.UserId;
                    SessionManager.ActualUserLoginID = SessionManager.CurrentUser.Login;
                }

                else
                {
                    SessionManager.LogsInAsOtherUser = false;
                    SessionManager.ActualUserUserID = 0;
                    SessionManager.ActualUserLoginID = "";
                    SessionManager.CanDecideOnBehalfOfOther = false;
                }
                if (pLoginType != LoginType.Normal)
                {
                    pIgnorePassword = true;
                }
                else
                {
                    if (GlobalDataManager.IgnoreHashing == false)
                        pPassword = PasswordSaltedHashingUtility.HashPassword(pPassword);
                }
                var secUserForSession = DataService.ValidateUserSP(login, pPassword, currTime, ipAddress, pIgnorePassword, SessionManager.ActualUserLoginID, pLoginType);

                if (secUserForSession != null)
                {
                    if (secUserForSession.IsActive == false)
                    {
                        Utility.LogData("User Is Inactive, can't log in");
                        SessionManager.CurrentUser = null;

                        //dataToReturn = new
                        //{
                        //    success = false,
                        //    error = "Your account is not active, Please Contact Administrator"
                        //};

                        return ResponseResult.GetErrorObject("Your account is not active, Please Contact Administrator");

                    }
                    else if (secUserForSession.IsDisabledForLogin == true)
                    {
                        SessionManager.CurrentUser = null;
                        //dataToReturn = new
                        //{
                        //    success = false,
                        //    error = "Your account is disabled, Please Contact Administrator"
                        //};
                        return ResponseResult.GetErrorObject("Your account is disabled, Please Contact Administrator");

                    }
                    else
                    {
                        HandlePermissions(secUserForSession.Permissions);

                        secUserForSession.AppAccessType = PermissionManager.GetAccessTypeForLoggedInUser();
                        secUserForSession.Permissions = null;

                        secUserForSession.CurrentApproverID = 0;

                        if (secUserForSession.ApproverDesignations.Count > 0 && secUserForSession.IsContributor)
                        {
                            var desig = secUserForSession.ApproverDesignations.First();
                            secUserForSession.CurrentApproverID = desig.ApproverID;
                            secUserForSession.Title = desig.Designation;
                        }

                        SessionManager.CurrentUser = secUserForSession;

                        var RedirectURl = Resources.PAGES_MANAGERS_DEFAULT_HOME_PAGE;
                        RedirectURl = RedirectURl.Replace("~/", "");
                        
                        //dataToReturn = new
                        //{
                        //    redirect = RedirectURl,
                        //    success = true,
                        //    error = ""
                        //};

                        return ResponseResult.GetSuccessObject(new { redirect = RedirectURl });
                    }
                }

                else
                {
                    //If the user was not detected as an authorized user
                    Utility.LogData("Invalid Login: " + login + " Password: " + pPassword);
                    SessionManager.CurrentUser = null;
                    //dataToReturn = new
                    //{
                    //    success = false,
                    //    error = "Invalid Login/Password"
                    //};
                    return ResponseResult.GetErrorObject("Invalid Login/Password");
                }
                //return (dataToReturn);
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                Utility.HandleException(ex);
                SessionManager.CurrentUser = null;
                //var exception = new
                //{
                //    success = false,
                //    error = "Some problem has occurred, Please Try again!"
                //};
                return ResponseResult.GetErrorObject("Some problem has occurred, Please Try again!");
                
            }
        }

        public Object UpdateDesign(int aid)
        {
            var returnObj = (new
            {
                success = false,
                error = "Invalid Request"
            });

            try
            {

                Boolean flag = false;
                var secUserForSession = SessionManager.CurrentUser;

                if (secUserForSession.ApproverDesignations.Count > 0 && secUserForSession.IsContributor)
                {
                    var desig = secUserForSession.ApproverDesignations.Where(p => p.ApproverID == aid).FirstOrDefault();
                    if (desig != null)
                    {
                        //var rolesList = new List<String>();
                        //var permList = new List<String>();

                        //permList = DataService.GetRolePermissionById(aid, out rolesList);

                        //HandlePermissions(permList);

                        //secUserForSession.Roles = rolesList;

                        secUserForSession.CurrentApproverID = 0;
                        secUserForSession.CurrentApproverID = desig.ApproverID;
                        secUserForSession.Title = desig.Designation;
                        flag = true;
                    }
                }

                if (flag)
                {
                    SessionManager.CurrentUser = secUserForSession;
                    return (new
                    {
                        success = true,
                        error = ""
                    });
                }
                else
                {
                    return returnObj;
                }
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return returnObj;
            }
        }

        public Object sendEmail(string email_login)
        {

            try
            {
                if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
                {
                    return (new
                    {
                        success = false,
                        error = "You Are Not Allowed"
                    });
                }


                var ipAddress = Utility.GetUserIPAddress();
                var currTime = DateTime.UtcNow;

                String token = Guid.NewGuid().ToString();

                String url = PUCIT.AIMRL.PRM.UI.Common.Resources.GetCompletePath("~/Login/ResetPassword1");
                url = String.Format("{0}?rt={1}", url, token);
                //url = url.Replace(@":8081", "");
                //url = url.Replace(@"http://", "").Replace(@"https://", "");


                String userEmail = DataService.UpdateResetToken(email_login, token,ipAddress,currTime,url);

                //var userObj = DataService.GetUserByEmail(emailAddress);

                if (!String.IsNullOrEmpty(userEmail))
                {
                    //emailAddress = userObj.Email;
                    //string token = "";
                    //token = HttpUtility.UrlEncode(EncryptDecryptUtility.Encrypt(emailAddress));

                    String subject = "Reset Password";
                    String msg = String.Format("Dear User, <br> Open the following link or copy and open in browser to reset your password <br><br> <a href='{0}' target='_blank'>{0}</a> <br><br> If you hadn't generated this request, Kindly ignore it.", url);

                    var flag = GlobalDataManager._emailhandler.SendEmail(new EmailMessageParam()
                    {
                        ToIDs = userEmail,
                        Subject = subject,
                        Body = msg
                    });

                    return (new
                    {
                        data = new
                        {
                            Id = email_login
                        },
                        success = flag,
                        error = ""
                    });
                }
                else
                {
                    return (new
                    {
                        success = false,
                        error = "Unable to recognize provided Login/Email ID"
                    });
                }
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some problem has occurred"
                });
            }
        }

        public Object SignOut(Boolean pManualEclockLogout)
        {
            try
            {
                SessionManager.CurrentUser = null;
                SessionManager.AbandonSession();
                HttpContext.Current.Response.Cache.SetCacheability(HttpCacheability.NoCache);
                HttpContext.Current.Response.Cache.SetExpires(DateTime.UtcNow.AddSeconds(-1));
                HttpContext.Current.Response.Cache.SetNoStore();

                if (HttpContext.Current.Request.Cookies["breadcrumbs"] != null)
                {
                    HttpCookie myCookie = new HttpCookie("breadcrumbs");
                    myCookie.Expires = DateTime.UtcNow.AddDays(-1d);
                    HttpContext.Current.Response.Cookies.Add(myCookie);
                }

                var result = new
                {
                    success = true,
                    error = ""
                };

                return (result);

            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        public Object resetPassword(PasswordEntity pass)
        {
            if (PUCIT.AIMRL.PRM.UI.Common.SessionManager.LogsInAsOtherUser == true)
            {
                return (new
                {
                    success = false,
                    error = "You Are Not Allowed"
                });
            }
            try
            {
                //var emailid = EncryptDecryptUtility.Decrypt(pass.Token);
                var password = pass.NewPassword;
                if (GlobalDataManager.IgnoreHashing == false)
                {
                    password = PasswordSaltedHashingUtility.HashPassword(pass.NewPassword);
                }

                var flag = DataService.UpdatePassword(pass.Token, "", password, 0, DateTime.UtcNow, false);

                return (new
                {
                    success = flag,
                    error = ""
                });
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        public Boolean IsValidResetToken(String pReset_Token)
        {
            return DataService.IsValidResetToken(pReset_Token);
        }

        public Object SaveContactUs(ContactUsDTO per)
        {
            {
                try
                {
                    per.MachineIP = Utility.GetUserIPAddress();
                    var permId = DataService.SaveContactUs(per, DateTime.UtcNow);

                    return (new
                    {
                        success = true
                    });
                }
                catch (Exception ex)
                {
                    PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                    return (new
                    {
                        success = false,
                        error = "Some Error has occurred"
                    });

                }
            }
        }
        public long SaveGmailLoginRequest(String pEmail, String pName, String pGmail_Id, String pGmail_Pic)
        {
            {
                try
                {
                    var id = DataService.SaveGmailLoginRequest(pEmail, pName, pGmail_Id, pGmail_Pic, DateTime.UtcNow);
                    return id;
                    
                }
                catch (Exception ex)
                {
                    PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                    return 0;
                }
            }
        }
    }
}