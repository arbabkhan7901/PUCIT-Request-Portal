using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.MainApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers.Signout
{
    public class FormsApplicationsDataController : BaseDataController
    {
        //
        // GET: /Forms/
        private readonly FormApplicationRepository _repository;

        public FormsApplicationsDataController()
        {
            _repository = new FormApplicationRepository();
        }
        private FormApplicationRepository Repository
        {
            get
            {
                return _repository;
            }
        }
        
    }
}
