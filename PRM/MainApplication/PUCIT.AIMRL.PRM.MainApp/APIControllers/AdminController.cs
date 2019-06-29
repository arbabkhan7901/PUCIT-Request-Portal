using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.MainApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{

    //    ->DB side paging(DB Level):
    //        Pass page index, page size & search criteria to your SP and get specific records only by using FETCH, OFFSET feature

    //    ->Background: In admin panels, there is mostly an option for admins to login by another user(without providing password). It is to check how system is working for a specific user.
    //Task: We need to design a screen where we'll provide
    //Autocomplete box(to search any user by name, login or by email id)
    //User will click on "Login as" button and same login process will work as it works for normal user on lo



    public class AdminController : BaseDataController
    {
        //
        // GET: /Admin/

        private readonly AdminRepository _repository;

        public AdminController()
        {
            _repository = new AdminRepository();
        }
        private AdminRepository Repository
        {
            get
            {
                return _repository;
            }
        }


        [HttpGet]
        public Object getAllContributers()
        {
            return Repository.getAllContributers();
        }

        [HttpGet]
        public Object getFormContributers(int pFormID)
        {
            return Repository.getFormContributers(pFormID);
        }


        [HttpGet]
        public Object getAllApplications()
        {
            return Repository.getAllApplications();
        }
        [HttpPost]
        public Object AddContributers(ApproverHierarchy u)
        {
            return Repository.AddContributers(u);
        }

        [HttpPost]
        public Object ValidateUser(Login pLogin)
        {
            try
            {
                if (PUCIT.AIMRL.PRM.MainApp.Security.PermissionManager.perCanLoginAsOtherUser == true)
                {
                    UserInfoRepository userInfoRepo = new UserInfoRepository();
                    return userInfoRepo.ValidateUser(pLogin.UserName, "",Entities.Enum.LoginType.LoginAs);
                }
                else
                {
                    return (new
                    {
                        success = false,
                        error = "Invalid Access"
                    });
                }
            }
            catch (Exception ex)
            {
                return (new
                {
                    success = false,
                    error = "Some Error has occurred"
                });
            }
        }

        [HttpGet]
        public Object SearchUser(string key)
        {

            return Repository.SearchUser(key);
        }
        [HttpPost]
        public Object deleteContributor(ApproverHierarchy u)
        {
            return Repository.deleteContributor(u);
        }

        [HttpPost]
        public Object SaveContributorsForForm(TempContrForm u)
        {
            return Repository.SaveContributorsForForm(u.FormID, u.ContributorList);
        }

    }
    public class Login
    {
        public String UserName { get; set; }
    }
    public class TempContrForm
    {
        public int FormID { get; set; }
        public List<ApproverHeirachyDTO> ContributorList { get; set; }
    }
}
