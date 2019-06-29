using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using PUCIT.AIMRL.PRM.MainApp.Models;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    public class DashboardController : BaseDataController
    {
        private readonly DashboardRepository _repository;
        public DashboardController()
        {
            _repository = new DashboardRepository();
        }

        private DashboardRepository Repository
        {
            get
            {
                return _repository;
            }
        }
        [HttpGet]
        public Object getCount()
        {
           return Repository.getCount();
        }
        [HttpGet]
        public Object getLatestPending()
        {
            return Repository.getLatestPending();
        }
        [HttpGet]
        public Object changeAccessType(String access) {
            return Repository.changeAccessType(access);
        }
    }
}

