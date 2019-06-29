using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Configuration;
using System.Collections;

using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.UI.Common;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.Common;
using PUCIT.AIMRL.PRM.MainApp.Security;
using PUCIT.AIMRL.PRM.Entities.Enum;

namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class InboxRepository
    {
        private PRMDataService _dataService;
        public InboxRepository()
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

        public Object changePassword(PasswordEntity pass)
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
                if (GlobalDataManager.IgnoreHashing == false)
                {
                    //  var emailid = EncryptDecryptUtility.Decrypt(pass.ID);
                    pass.CurrentPassword = PasswordSaltedHashingUtility.HashPassword(pass.CurrentPassword);
                    pass.NewPassword = PasswordSaltedHashingUtility.HashPassword(pass.NewPassword);
                }
                var userObj = SessionManager.CurrentUser;

                var id = DataService.UpdatePassword(userObj.Login, pass.CurrentPassword, pass.NewPassword, userObj.UserId, DateTime.UtcNow, true);

                //var id = DataService.changePassword(pass);
                if (id == false)
                {
                    return (new
                    {
                        data = new
                        {
                            Id = id
                        },
                        success = false,
                        error = "Wrong Password"
                    });
                }
                else
                {
                    return (new
                    {
                        data = new
                        {
                            Id = id
                        },
                        success = true,
                        error = "Password Changed"
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
        public Object FillDropDown()
        {
            try
            {
                int UserID = SessionManager.GetLoggedInUserId();
                ApplicationAccessType appAccess = PUCIT.AIMRL.PRM.UI.Common.SessionManager.CurrentUser.AppAccessType;
                List<FormCategories> details = null;
                if (appAccess.ToString() == "SelfCreated")
                {
                    details = DataService.FillDropDown(UserID, 0);
                }
                else if (appAccess.ToString() == "Assigned")
                {
                    details = DataService.FillDropDown(UserID, 1);
                }
                else if (appAccess.ToString() == "All")
                {
                    details = DataService.FillDropDown(UserID, 2);
                }
                return (new
                {
                    data = details,
                    success = true,
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
        public Object SearchApplications(SearchEntity pSearchParam)
        {

            if (pSearchParam.SDate <= DateTime.MinValue)
                pSearchParam.SDate = new DateTime(1900, 1, 1);

            if (pSearchParam.EDate <= DateTime.MinValue)
                pSearchParam.EDate = DateTime.MaxValue;


            if (!String.IsNullOrEmpty(pSearchParam.DiaryNo))
            {
                var splits = pSearchParam.DiaryNo.Split('/');
                pSearchParam.DiaryNoInt = Convert.ToInt32(splits[splits.Length - 1]);
            }
            try
            {

                var user = SessionManager.CurrentUser;

                var userId = user.UserId;

                if (user.AppAccessType == ApplicationAccessType.Assigned)
                    userId = user.CurrentApproverID;

                var List = DataService.SearchApplications(pSearchParam, user.AppAccessType, userId);


                return (new
                {
                    data = new
                    {
                        ApplicationList = List
                    },
                    success = true,
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


    }
}