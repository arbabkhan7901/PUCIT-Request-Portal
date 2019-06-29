
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

using PUCIT.AIMRL.PRM.MainApp.Models;
using PUCIT.AIMRL.PRM.MainApp.Security;
using PUCIT.AIMRL.PRM.MainApp.Utils.HttpFilters;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.UI.Common;
using PUCIT.AIMRL.PRM.Entities.Enum;

namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    public class UserInfoDataController : ApiController
    {
        public class Login
        {
            public String UserName { get; set; }
            public String Password { get; set; }
            public String reCaptcha_Response { get; set; }
    }

        private readonly UserInfoRepository _repository;
        public UserInfoDataController()
        {
            _repository = new UserInfoRepository();
        }

        private UserInfoRepository Repository
        {
            get
            {
                return _repository;
            }
        }

        [HttpPost]
        public Object ValidateUser(Login pLogin)
        {
            try
            {
                Boolean goToValidateFunction = true;
                if (GlobalDataManager.EnableRecaptcha)
                {
                    goToValidateFunction = Repository.CheckRecaptcha(pLogin.reCaptcha_Response);
                }

                if (goToValidateFunction == true)
                {
                    Util.Utility.LogData("Going to validate Login:" + pLogin.UserName);
                    return Repository.ValidateUser(pLogin.UserName, pLogin.Password, LoginType.Normal);
                }
                else
                {
                    return (new
                    {
                        success = false,
                        error = "ReCaptcha Failed"
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

        [HttpPost]
        public ResponseResult LoginWithAcToken(AcTokenDTO dto)
        {
            if (dto != null && !String.IsNullOrEmpty(dto.AccessToken))
            {
                var gUserProfile = PUCIT.AIMRL.GoogleApi.GoogleApiAuthenticator.GetUserProfileData(dto.AccessToken);
                if (gUserProfile != null)
                {
                    //call validate User function
                    UserInfoRepository repo = new UserInfoRepository();
                    return repo.ValidateUser(gUserProfile.email, "", LoginType.GAccessToken);
                }
                else
                {
                    return ResponseResult.GetErrorObject("Invalid Access Token");
                }
            }
            else
            {
                return ResponseResult.GetErrorObject("Invalid Access Token");
            }
            
        }

        //[AuthorizedForWebAPI]
        //public Object GetUsername()
        //{
        //    return Repository.getUsername();
        //}
        [HttpPost]
        public Object sendEmail(UserEmail obj)
        {
            return Repository.sendEmail(obj.emailAddress);
        }
        //[AuthorizedForWebAPI]
        public Object resetPassword(PasswordEntity pass)
        {
            return Repository.resetPassword(pass);
        }

        [AuthorizedForWebAPI]
        [HttpGet]
        public Object ChangeDesig(int aid)
        {
            return Repository.UpdateDesign(aid);
        }

        [HttpPost]
        public Object SaveContactUs(PUCIT.AIMRL.PRM.Entities.DBEntities.ContactUsDTO obj)
        {
            return Repository.SaveContactUs(obj);
        }
    }
    public class UserEmail
    {
        public string emailAddress { get; set; }
    }
    public class AcTokenDTO
    {
        public String AccessToken { get; set; }
    }
}