using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.MainApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;


namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    public class ReportsController : BaseDataController
    {
        //
        // GET: /Admin/

        private readonly ReportsRepository _repository;

        public ReportsController()
        {
            _repository = new ReportsRepository();
        }
        private ReportsRepository Repository
        {
            get
            {
                return _repository;
            }
        }
        [HttpPost]
        public Object SearchApplicationStatuses(AppStatusesSearchParam a)
        {
            return Repository.SearchApplicationStatuses(a);
        }

        [HttpPost]
        public Object SearchLoginHistory(LoginHistorySearchParam u)
        {
            return Repository.SearchLoginHistory(u);
        }
        [HttpPost]
        public Object SearchContactUs(ContactUsSearchParam u)
        {
            return Repository.SearchContactUs(u);
        }

        [HttpPost]
        public Object SearchForgotPasswordLog(ForgotPasswordSearchParam u)
        {
            return Repository.SearchForgotPasswordLog(u);
        }
        [HttpPost]
        public Object GetActivityLogList(ActivityLogSearchParam u)
        {
            return Repository.GetActivityLogList(u);
        }
        [HttpGet]
        public Object getVoucherItemsName()
        {
            return Repository.getVoucherItemsName();
        }
        [HttpPost]
        public Object SearchItemReport(AppItemSearchParam a)
        {
            return Repository.SearchItemReport(a);
        }
    }
}