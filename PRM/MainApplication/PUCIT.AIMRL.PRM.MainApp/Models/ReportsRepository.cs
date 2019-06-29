using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities.Enum;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Http;
namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    class ReportsRepository
    {
        private PRMDataService _dataService;
        public ReportsRepository()
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

        public Object SearchApplicationStatuses(AppStatusesSearchParam a)
        {
            try
            {
                if (a.SDate <= DateTime.MinValue)
                    a.SDate = new DateTime(1900, 1, 1);

                if (a.EDate <= DateTime.MinValue)
                    a.EDate = DateTime.MaxValue;

                var List = DataService.SearchApplicationStatuses(a);
                return (new
                {
                    data = new
                    {
                        StatusList = List
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



        public Object SearchLoginHistory(LoginHistorySearchParam pSearchParam)
        {
            try
            {
                if (pSearchParam.SDate <= DateTime.MinValue)
                    pSearchParam.SDate = new DateTime(1900, 1, 1);

                if (pSearchParam.EDate <= DateTime.MinValue)
                    pSearchParam.EDate = DateTime.MaxValue;

                var result = DataService.SearchLoginHistory(pSearchParam);

                return (new
                {
                    data = new
                    {
                        Count = result.ResultCount,
                        LoginHistoryList = result.Result
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
        public ActivityLogReportSearchResult GetActivityLogData(ActivityLogSearchParam u)
        {
            var user = SessionManager.CurrentUser;
            var userId = user.UserId;
            if (user.AppAccessType == ApplicationAccessType.Assigned)
                userId = user.CurrentApproverID;
            var result = DataService.GetActivityLogDataForReport(user.AppAccessType, userId, u);
           return result;
        }

        public Object GetActivityLogList(ActivityLogSearchParam u)
        {
            try
            {
                var result = GetActivityLogData(u);
                return (new
                {
                    data = new
                    {
                        LogList = result.Result,
                        Count = result.ResultCount
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

        public Object getVoucherItemsName()
        {
            var upload = DataService.getVoucherItemsName();
            return (new
            {
                data = upload,

                success = true,

            });
        }

        public Object SearchContactUs(ContactUsSearchParam pSearchParam)
        {
            try
            {
                if (pSearchParam.SDate <= DateTime.MinValue)
                    pSearchParam.SDate = new DateTime(1900, 1, 1);

                if (pSearchParam.EDate <= DateTime.MinValue)
                    pSearchParam.EDate = DateTime.MaxValue;

                var result = DataService.SearchContactUs(pSearchParam);

                return (new
                {
                    data = new
                    {
                        Count = result.ResultCount,
                        ContactUsList = result.Result
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


        public Object SearchForgotPasswordLog(ForgotPasswordSearchParam pSearchParam)
        {
            try
            {
                if (pSearchParam.SDate <= DateTime.MinValue)
                    pSearchParam.SDate = new DateTime(1900, 1, 1);

                if (pSearchParam.EDate <= DateTime.MinValue)
                    pSearchParam.EDate = DateTime.MaxValue;

                var result = DataService.SearchForgotPasswordLog(pSearchParam);

                return (new
                {
                    data = new
                    {
                        Count = result.ResultCount,
                        ForgotPasswordLogList = result.Result
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
        public Object SearchItemReport(AppItemSearchParam a)
        {
            try
            {
                if (a.SDate <= DateTime.MinValue)
                    a.SDate = new DateTime(1900, 1, 1);

                if (a.EDate <= DateTime.MinValue)
                    a.EDate = DateTime.MaxValue;

                var List = DataService.SearchItemReport(a);
                return (new
                {
                    data = new
                    {
                        StatusList = List
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