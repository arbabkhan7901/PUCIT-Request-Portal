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
    public class SecurityController : BaseDataController
    {
        //
        // GET: /Admin/

        private readonly SecurityRepository _repository;

        public SecurityController()
        {
            _repository = new SecurityRepository();
        }
        private SecurityRepository Repository
        {
            get
            {
                return _repository;
            }
        }
        //[HttpGet]
        //public Object getRoles()
        //{
        //    return Repository.getRoles();
        //}
        //[HttpPost]
        //public Object SaveRole(Roles r)
        //{
        //    return Repository.SaveRole(r);
        //}
        //[HttpPost]
        //public Object DeleteRole(Roles r)
        //{
        //    return Repository.DeleteRole(r);
        //}
        //[HttpGet]
        //public Object getMappings()
        //{
        //    return Repository.getMappings();
        //}
        //[HttpGet]
        //public Object getPermissions()
        //{
        //    return Repository.getPermissions();
        //}
        //[HttpPost]
        //public Object UpdateMappings(customUpdateMappings m)
        //{
        //    return Repository.UpdateMappings(m);
        //}
        //[HttpPost]
        //public Object DeleteMappings(int roleid)
        //{
        //    return Repository.DeleteMappings(roleid);
        //}
        //[HttpPost]
        //public Object SavePermission(PermissionsWithRoleID r)
        //{
        //    return Repository.SavePermission(r);
        //}
        //[HttpPost]
        //public Object EnableDisablePermission(PermissionsWithRoleID r)
        //{
        //    return Repository.EnableDisablePermission(r);
        //}

        [HttpGet]
        public Object getRoles()
        {
            return Repository.getRoles();
        }
        [HttpGet]
        public Object getActiveRoles()
        {
            return Repository.getActiveRoles();
        }

        [HttpPost]
        public Object SaveRole(Roles r)
        {
            return Repository.SaveRole(r);
        }
        [HttpPost]
        public Object EnableDisableRole(Roles r)
        {
            return Repository.EnableDisableRole(r);
        }
        [HttpGet]
        public Object getPermissions()
        {
            return Repository.getPermissions();
        }

        [HttpGet]
        public Object getActivePermissions()
        {
            return Repository.getActivePermissions();
        }
        [HttpGet]
        public Object GetPermissionsByRoleID(int pRoleID)
        {
            return Repository.GetPermissionsByRoleID(pRoleID);
        }
        [HttpPost]
        public Object SaveRolePermissionMapping(TempRolePermMapping r)
        {
            return Repository.SaveRolePermissionMapping(r.RoleID, r.Permissions);
        }

        [HttpPost]
        public Object SavePermission(PermissionsWithRoleID r)
        {
            return Repository.SavePermission(r);
        }
        [HttpPost]
        public Object EnableDisablePermission(PermissionsWithRoleID r)
        {
            return Repository.EnableDisablePermission(r);
        }


        [HttpGet]
        public Object getUsers()
        {
            return Repository.getUsers();
        }
        [HttpPost]
        public object SaveUsersBulk(List<User> u)
        {
            return Repository.SaveUsersBulk(u);
        }
        [HttpPost]
        public object SaveUsers(User u)
        {
            return Repository.SaveUsers(u);
        }

        [HttpPost]
        public object EnableDisableUser(User u)
        {
            return Repository.EnableDisableUser(u);
        }

        [HttpGet]
        public Object GetRolesByUserID(int pUserID)
        {
            return Repository.GetRolesByUserID(pUserID);
        }
        [HttpPost]
        public Object SaveUserRoleMapping(TempUserRoleMapping r)
        {
            return Repository.SaveUserRoleMapping(r.UserID, r.Roles);
        }

        [HttpPost]
        public Object SearchUsers(UserSearchParam u)
        {
            return Repository.SearchUsers(u);
        }

        [HttpGet]
        public Object GetDesignationsByUserID(int pUserID)
        {
            return Repository.GetDesignationsByUserID(pUserID);
        }

        [HttpGet]
        public object GetDesignations()
        {
            return Repository.GetDesignations();
        }


        [HttpPost]
        public Object SearchGoogleLoginRequests(UserSearchParam u)
        {
            return Repository.SearchGoogleLoginRequests(u);
        }

        [HttpPost]
        public Object CreateUserFromGoogleRequest(TempGoogleUserDataToCreate r)
        {
            return Repository.CreateUserFromGmailRequest(r.EmailID, r.RoleID);
        }
        [HttpGet]
        public Object getItems()
        {

            return Repository.getItems();
        }

        [HttpPost]
        public Object Saveitems(Items r)
        {
            return Repository.Saveitems(r);
        }

        [HttpPost]
        public Object SaveQuantity(customManageQty qty)
        {
            return Repository.SaveQuantity(qty);
        }


        [HttpPost]
        public object EnableDisbaleItem(TempItemEnableDisable i)
        {
            return Repository.EnableDisbaleItem(i.ItemId, i.IsActive);
        }

    }

    public class TempRolePermMapping
    {
        public int RoleID { get; set; }
        public List<int> Permissions { get; set; }
    }

    public class TempUserRoleMapping
    {
        public int UserID { get; set; }
        public List<int> Roles { get; set; }
    }

    public class TempGoogleUserDataToCreate
    {
        public String EmailID { get; set; }
        public int RoleID { get; set; }
    }
    public class TempItemEnableDisable {
        public int ItemId { get; set; }
        public Boolean IsActive { get; set; }
    }
}
