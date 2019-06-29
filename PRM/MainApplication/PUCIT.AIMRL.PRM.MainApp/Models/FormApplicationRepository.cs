using System.Linq;
using System.Web;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using System;
using PUCIT.AIMRL.PRM.UI.Common;
using System.Collections.Generic;
using System.IO;
using PUCIT.AIMRL.PRM.MainApp.Security;

namespace PUCIT.AIMRL.PRM.MainApp.Models
{
    public class FormApplicationRepository
    {
        private PRMDataService _dataService;
        public FormApplicationRepository()
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

    }
}