using PUCIT.AIMRL.Common;
using PUCIT.AIMRL.PRM.DAL;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.MainApp.Security;
using PUCIT.AIMRL.PRM.UI.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Http;
namespace PUCIT.AIMRL.PRM.MainApp.APIControllers
{
    class SecurityRepository
    {
        private PRMDataService _dataService;
        public SecurityRepository()
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
        //public Object getRoles()
        //{
        //    try
        //    {
        //        var List = DataService.getRoles();
        //        return (new
        //        {
        //            data = new
        //            {
        //                RoleList = List
        //            },
        //            success = true,
        //            error = ""
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}
        //public object getPermissions()
        //{
        //    try
        //    {
        //        var List = DataService.getPermissions();
        //        return (new
        //        {
        //            data = new
        //            {
        //                PermissionList = List
        //            },
        //            success = true,
        //            error = ""
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}

        //public object EnableDisablePermission(PermissionsWithRoleID r)
        //{
        //    String msg = " ";
        //    try
        //    {

        //        bool rowdeleted = DataService.EnableDisablePermission(r.Id, r.IsActive, DateTime.UtcNow, SessionManager.CurrentUser.UserId);

        //        if (rowdeleted == true)
        //        {
        //            if (r.IsActive == true)
        //            {
        //                msg = "Permission Enabled Successfully";
        //            }
        //            else if (r.IsActive == false)
        //            {
        //                msg = "Permission Disabled Successfully";
        //            }
        //        }
        //        else
        //        {
        //            msg = " ";
        //        }
        //        return (new
        //        {

        //            success = true,
        //            error = msg
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}

        //public object SavePermission(PermissionsWithRoleID p)
        //{
        //    String msg = " ";
        //    try
        //    {
        //        var result = DataService.SavePermission(p);
        //        if (result > 0)
        //        {
        //            msg = " ";
        //        }
        //        if (result <= 0)
        //        {
        //            msg = " ";
        //        }
        //        return (new
        //        {
        //            data = new
        //            {
        //                PermissionList = result
        //            },
        //            success = true,
        //            error = msg
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}


        //public Object getMappings()
        //{
        //    try
        //    {
        //        var List = DataService.getMappings();
        //        return (new
        //        {
        //            data = new
        //            {
        //                MappingList = List
        //            },
        //            success = true,
        //            error = ""
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}
        //public Object DeleteRole(Roles r)
        //{
        //    String msg = " ";
        //    try
        //    {
        //        bool rowdeleted = DataService.DeleteRole(r);
        //        if (rowdeleted == true)
        //        {
        //            msg = " role Deleted Successfully";
        //        }
        //        else
        //        {
        //            msg = " ";
        //        }
        //        return (new
        //        {

        //            success = true,
        //            error = msg
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}
        //public Object SaveRole(Roles r)
        //{
        //    String msg = " ";
        //    try
        //    {
        //        var List = DataService.SaveRole(r);
        //        if (r.Id > 0)
        //        {
        //            msg = "Role Updated Successfully";
        //        }
        //        if (r.Id == 0)
        //        {
        //            msg = "Role added Successfully";
        //        }
        //        return (new
        //        {
        //            data = new
        //            {
        //                RoleList = List
        //            },
        //            success = true,
        //            error = msg
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}
        //public Object UpdateMappings(customUpdateMappings m)
        //{
        //    String msg = " ";
        //    try
        //    {
        //        var flag= DataService.UpdateMappings(m);
        //       msg = "mapping updated";
        //        return (new
        //        {
        //            success = true,
        //            error = msg
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}

        //public Object DeleteMappings(int rid)
        //{
        //    String msg = " ";
        //    try
        //    {
        //        var flag = DataService.DeleteMappings(rid);
        //        msg = "mapping Deleted";
        //        return (new
        //        {
        //            success = true,
        //            error = msg
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return (new
        //        {
        //            success = false,
        //            error = "Some Error has occurred"
        //        });
        //    }
        //}


        #region Permissions

        public object getPermissions()
        {
            try
            {
                var List = DataService.GetAllPermissions();
                return (new
                {
                    data = new
                    {
                        PermissionList = List
                    },
                    success = true,
                    error = ""
                });
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
        public object getActivePermissions()
        {
            try
            {
                var List = DataService.GetAllPermissions().Where(p => p.IsActive == true).ToList();
                return (new
                {
                    data = new
                    {
                        PermissionList = List
                    },
                    success = true,
                    error = ""
                });
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
        public object EnableDisablePermission(PermissionsWithRoleID r)
        {
            String msg = " ";
            try
            {

                bool rowdeleted = DataService.EnableDisablePermission(r.Id, r.IsActive, DateTime.UtcNow, SessionManager.CurrentUser.UserId);

                if (rowdeleted == true)
                {
                    var param = (r.IsActive == false ? "disabled" : "enabled");
                    msg = String.Format("Permission is {0} successfully", param);
                }
                else
                {
                    msg = " ";
                }
                return (new
                {

                    success = true,
                    error = msg
                });
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
        public object SavePermission(PermissionsWithRoleID p)
        {
            String msg = " ";
            try
            {
                var permId = DataService.SavePermission(p, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (p.Id > 0)
                {
                    msg = "Permission Updated Successfully";
                }
                if (p.Id == 0)
                {
                    msg = "Permission Added Successfully";
                }

                return (new
                {
                    data = new
                    {
                        PermssionId = permId
                    },
                    success = true,
                    error = msg
                });
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
        public object GetPermissionsByRoleID(int pRoleID)
        {
            try
            {
                var List = DataService.GetPermissionsByRoleID(pRoleID);

                return (new
                {
                    data = new
                    {
                        Permissions = List
                    },
                    success = true,
                    error = ""
                });
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

        public object SaveRolePermissionMapping(int pRoleID, List<int> pPermissionsList)
        {
            try
            {
                var List = DataService.SaveRolePermissionMapping(pRoleID, pPermissionsList);

                return (new
                {
                    data = new
                    {
                        Permissions = List
                    },
                    success = true,
                    error = "Mappings are saved"
                });
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

        #endregion

        #region Roles
        public Object getRoles()
        {
            try
            {
                var List = DataService.GetAllRoles();
                return (new
                {
                    data = new
                    {
                        RoleList = List
                    },
                    success = true,
                    error = ""
                });
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
        public Object EnableDisableRole(Roles pRoleObj)
        {
            String msg = " ";
            try
            {
                bool rowdeleted = DataService.EnableDisableRole(pRoleObj.Id, pRoleObj.IsActive, DateTime.UtcNow, SessionManager.CurrentUser.UserId);

                if (rowdeleted == true)
                {
                    var param = (pRoleObj.IsActive == false ? "disabled" : "enabled");
                    msg = String.Format("Role is {0} successfully", param);
                }
                else
                {
                    msg = " ";
                }
                return (new
                {

                    success = true,
                    error = msg
                });
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
        public Object SaveRole(Roles r)
        {
            String msg = " ";
            try
            {
                var roleId = DataService.SaveRole(r, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (r.Id > 0)
                {
                    msg = "Role Updated Successfully";
                }
                if (r.Id == 0)
                {
                    msg = "Role added Successfully";
                }
                return (new
                {
                    data = new
                    {
                        RoleId = roleId
                    },
                    success = true,
                    error = msg
                });
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
        public object getActiveRoles()
        {
            try
            {
                var List = DataService.GetAllRoles().Where(p => p.IsActive == true).ToList();
                return (new
                {
                    data = new
                    {
                        RoleList = List
                    },
                    success = true,
                    error = ""
                });
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

        public object GetRolesByUserID(int pUserID)
        {
            try
            {
                var List = DataService.GetRolesByUserID(pUserID);

                return (new
                {
                    data = new
                    {
                        Roles = List.Distinct().ToList()
                    },
                    success = true,
                    error = ""
                });
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

        public object SaveUserRoleMapping(int pUserID, List<int> pRoles)
        {
            try
            {
                var List = DataService.SaveUserRoleMapping(pUserID, pRoles);

                return (new
                {
                    data = new
                    {
                        Roles = List
                    },
                    success = true,
                    error = "Mappings are saved"
                });
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
        #endregion

        #region Users

        public object EnableDisableUser(User pUserObj)
        {
            try
            {
                String msg = "";
                var result = DataService.EnableDisableUser(pUserObj.UserId, pUserObj.IsActive, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (result == true)
                {
                    var param = (pUserObj.IsActive == false ? "disabled" : "enabled");
                    msg = String.Format("User is {0} successfully", param);
                }
                else
                {
                    msg = "";
                }


                if (result == true)
                {
                    return (new
                    {
                        data = new
                        {
                            UserList = result
                        },
                        success = true,
                        error = msg
                    });

                }
                else
                {

                    return (new
                    {
                        success = false,
                        error = "Some Error has occurred"
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

        public Object SaveUsersBulk(List<User> u)
        {
            try
            {
                String msg;
                for (int i = 0; i < u.Count; i++)
                {
                    u[i].IsActive = true;
                    u[i].UserId = 0;
                    u[i].Title = "Student";

                    u[i].Password = PasswordSaltedHashingUtility.HashPassword("123");


                    u[i].CreatedBy = SessionManager.CurrentUser.UserId;
                    u[i].CreatedOn = DateTime.UtcNow;
                }

                DataService.SaveUsersBulk(u);

                msg = "Users Added Successfully";


                return (new
                {

                    success = true,
                    error = msg
                });
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

        public Object SaveUsers(User u)
        {
            try
            {
                String msg;
                u.Password = PasswordSaltedHashingUtility.HashPassword("123");
                var result = DataService.SaveUsers(u, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (result > 0)
                {
                    if (u.UserId > 0)
                    {
                        msg = "User Updated Successfully";
                    }
                    else
                    {
                        msg = "User Added Successfully";
                    }

                    return (new
                    {
                        data = new
                        {
                            UserId = result
                        },
                        success = true,
                        error = msg
                    });

                }
                else
                {
                    return (new
                    {
                        success = false,
                        error = "Some Error has occurred"
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

        public Object getUsers()
        {
            try
            {
                var List = DataService.GetAllUsers();
                return (new
                {
                    data = new
                    {
                        UserList = List
                    },
                    success = true,
                    error = ""
                });
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

        public Object SearchUsers(UserSearchParam pSearchParam)
        {
            try
            {
                var result = DataService.SearchUsers(pSearchParam);

                return (new
                {
                    data = new
                    {
                        Count = result.ResultCount,
                        UserList = result.Result
                    },
                    success = true,
                    error = ""
                });
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

        public Object GetDesignationsByUserID(int pUserID)
        {
            try
            {
                var List = DataService.GetDesignationsByUserID(pUserID);
                return (new
                {
                    data = new
                    {
                        ContributorList = List
                    },
                    success = true,
                    error = ""
                });
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
        #endregion

        #region Items
        public Object Saveitems(Items item)
        {
            String msg = " ";
            try
            {
                var itemId = DataService.SaveItems(item, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (item.ItemId > 0)
                {
                    msg = "Items  Updated Successfully";
                }
                if (item.ItemId == 0)
                {
                    msg = "Items added Successfully";
                }
                var data = new
                {
                    ItemId = itemId
                };
                return ResponseResult.GetSuccessObject(data, msg);
            }
            catch (Exception ex)
            {
                return ResponseResult.GetErrorObject();
            }

        }
        public Object SaveQuantity(customManageQty qty)
        {
            String msg = " ";
            try
            {
                if (qty.InQuantity > 0)
                {
                    var roleId = DataService.SaveQuantity(qty);
                    if (qty.ItemId > 0)
                    {
                        msg = "Quantity  Updated Successfully";
                    }
                    if (qty.ItemId == 0)
                    {
                        msg = "Quantity added Successfully";
                    }
                    var data = new
                    {
                        ItemId = roleId
                    };
                    return ResponseResult.GetSuccessObject(data, msg);
                }
                else
                {
                    return ResponseResult.GetErrorObject("Enter a valid quantity!");
                }
            }
            catch (Exception ex)
            {
                return ResponseResult.GetErrorObject();
            }
        }
        public Object getItems()
        {
            try
            {
                //change10
                var List = DataService.getItems();
                var data = new
                {
                    //change14
                    ItemsList = List
                };
                return ResponseResult.GetSuccessObject(data, "");
            }
            catch (Exception ex)
            {
                return ResponseResult.GetErrorObject();
            }
        }
        public object EnableDisbaleItem(int id,Boolean IsActive)
        {
            try
            {
                //change10
                bool result = DataService.EnableDisbaleItem(id, IsActive, DateTime.UtcNow, SessionManager.CurrentUser.UserId);
                if (result == true)
                {
                    var data = new { };
                    var param = (IsActive == false ? "disabled" : "enabled");
                    String msg = String.Format("Item is {0} successfully", param);
                    return ResponseResult.GetSuccessObject(data, msg);
                }
                else
                {
                    return ResponseResult.GetErrorObject();
                }
            }
            catch (Exception ex)
            {
                return ResponseResult.GetErrorObject();
            }
        }


        #endregion

        #region Designations

        public object GetDesignations()
        {
            try
            {
                var List = DataService.GetDesignations();
                return (new
                {
                    data = new
                    {
                        Designations = List
                    },
                    success = true,
                    error = ""
                });
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


        #endregion

        public ResponseResult CreateUserFromGmailRequest(String pEmail, int pRoleId)
        {
            try
            {
                if (PermissionManager.perManageSecurityUsers)
                {
                    var result = DataService.CreateUserFromGmailRequest(pEmail, pRoleId, DateTime.UtcNow);
                    return ResponseResult.GetSuccessObject(result,"User is Created Successfully!");
                }
                else
                {
                    return ResponseResult.GetErrorObject("You are not allowed to do this action!");
                }
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
        public ResponseResult SearchGoogleLoginRequests(UserSearchParam pSearchParam)
        {
            try
            {
                if (PermissionManager.perManageSecurityUsers)
                {
                    var result = DataService.SearchGoogleLoginRequests(pSearchParam);
                    return ResponseResult.GetSuccessObject(new
                    {
                        Count = result.ResultCount,
                        UserList = result.Result
                    });
                }
                else
                {
                    return ResponseResult.GetErrorObject("You are not allowed to do this action!");
                }
                
            }
            catch (Exception ex)
            {
                PUCIT.AIMRL.PRM.MainApp.Util.Utility.HandleException(ex);
                return ResponseResult.GetErrorObject();
            }
        }
    }
}