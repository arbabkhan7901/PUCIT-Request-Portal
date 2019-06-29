using PUCIT.AIMRL.PRM.MainApp.APIControllers;
using PUCIT.AIMRL.PRM.MainApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers.Signout
{    
    public class SignOutDataController : BaseDataController
    {
        private  UserInfoRepository _repository;
        public SignOutDataController()
        {
            
        }

        private UserInfoRepository Repository
        {
            get
            {
                if(_repository == null)
                    _repository = new UserInfoRepository();

                return _repository;
            }
        }

        [HttpGet]
        public Object GetUserSignOut(Boolean pManualEclockLogout)
        {
            return Repository.SignOut(pManualEclockLogout);
        }
    }
}
