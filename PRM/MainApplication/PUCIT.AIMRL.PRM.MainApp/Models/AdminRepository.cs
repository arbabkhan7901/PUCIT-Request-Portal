using System.Web;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using System.Web.Security;
using System.Configuration;
using System;
using System.Linq;
using PUCIT.AIMRL.PRM.UI.Common;
using System.Collections.Generic;
using System.IO;
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.Entities.Security;
using PUCIT.AIMRL.PRM.MainApp.Security;
using PUCIT.AIMRL.Common;
using System.Collections;


namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class AdminRepository
    {
        private PRMDataService _dataService;
        public AdminRepository()
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
        public Object AddContributers(ApproverHierarchy u)
        {
            try
            {

                var result = DataService.AddContributers(u);
                if (result > 0)
                {
                    return (new
                    {
                        data = new
                        {
                            UserList = result
                        },
                        success = true,
                        error = ""
                    });

                }
                else
                {

                    return (new
                    {
                        success = false,
                        error = "Some Error has occurred"
                    });


                }

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

        public Object getFormContributers(int pFormID)
        {
            try
            {
                var List = DataService.GetApproverHerirachyByFormID(pFormID);
                return (new
                {
                    data = new
                    {
                        FormContributersList = List
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
        public Object getAllContributers()
        {
            try
            {
                var List = DataService.getAllContributers();
                return (new
                {
                    data = new
                    {
                        ContributorsList = List
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

        public Object getAllApplications()
        {
            try
            {
                var List = DataService.getAllApplications();
                return (new
                {
                    data = new
                    {
                        AppList = List
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
        public Object SearchUser(string key)
        {
            try
            {

                var list = DataService.SearchUser(key);

                var result = (from p in list
                              select new
                              {
                                  ID = p.UserId,
                                  Login = p.Login,
                                  Name = p.Name
                              }).ToList();
                return result;
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
        
        public Object deleteContributor(ApproverHierarchy u)
        {
            try
            {
                var List = DataService.deleteContributor(u);
                return (new
                {
                    data = new
                    {
                        ContributorList = List
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

        public Object SaveContributorsForForm(int pFormID, List<ApproverHeirachyDTO> pContributorList)
        {
            try
            {
                var formID = DataService.SaveContributorsForForm(pFormID,pContributorList);

                return (new
                {
                    data = new
                    {
                        FormID = formID
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