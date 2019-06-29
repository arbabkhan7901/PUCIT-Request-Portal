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
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities.Enum;

namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class DashboardRepository
    {
        private PRMDataService _dataService;
        public DashboardRepository()
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

        public Object getCount()
        {
            try
            {

                

                var user = SessionManager.CurrentUser;

                var userId = user.UserId;

                if (user.AppAccessType == ApplicationAccessType.Assigned)
                    userId = user.CurrentApproverID;

                var data = DataService.GetAppCountStatusWise(user.AppAccessType, userId);


                List<int> counts = new List<int>();
                if(data!=null)
                {
                    counts.Add(data.All);
					counts.Add(data.Pending);
					counts.Add(data.Accepted);
					counts.Add(data.Rejected);
                }
                
                List<String> names = new List<String> { "All", "Pending", "Accepted", "Rejected" };

                if(SessionManager.CurrentUser.AppAccessType == ApplicationAccessType.Assigned)
                {
                    names.Add("Not Assigned Yet");
                    counts.Add(data.NotAssigned);
                    //names.Add("Rejected Before Assignment");
                }
                

                return (new
                {
                    data = new
                    {
                        countList = counts,
                        namesList = names
                    },
                    success = true,
                    error = "Problem in loading data."
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

        public Object getLatestPending()
        {
            try
            {
                List<InboxApplication> result = new List<InboxApplication>();

                SearchEntity entity = new SearchEntity();

                entity.Status = (int) ApplicationStatus.Pending;

                var user = SessionManager.CurrentUser;

                var userId = user.UserId;

                if (user.AppAccessType == ApplicationAccessType.Assigned)
                    userId = user.CurrentApproverID;


                var data = DataService.SearchApplications(entity, user.AppAccessType, userId).Take(5);


                return (new
                {
                    data = new
                    {
                        Applications = data
                    },
                    success = true,
                    error = "Problem in loading data."
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
        public ResponseResult changeAccessType(String access) {
            try {
                if (access == "self")
                {
                    PUCIT.AIMRL.PRM.UI.Common.SessionManager.CurrentUser.AppAccessType = ApplicationAccessType.SelfCreated;
                }
                else if (access == "assigned")
                {
                    PUCIT.AIMRL.PRM.UI.Common.SessionManager.CurrentUser.AppAccessType = ApplicationAccessType.Assigned;
                }
                return ResponseResult.GetSuccessObject(null, "Access Type Switched Successfully");
            }
            catch (Exception ex) {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
             
        }
    }
}