using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.MainApp.Models;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    public class InboxController : BaseDataController
    {
        private readonly InboxRepository _repository;
        public InboxController()
        {
            _repository = new InboxRepository();
        }

        private InboxRepository Repository
        {
            get
            {
                return _repository;
            }
        }

        public Object changePassword(PasswordEntity pass)
        {
            return Repository.changePassword(pass);
        }

        public Object searchApplications(SearchEntity Data)
        {
            return Repository.SearchApplications(Data);
        }
        [HttpGet]
        public Object FillDropDown()
        {
            return Repository.FillDropDown();
        }
    }
}
