using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using PUCIT.AIMRL.PRM.MainApp.Util;
using PUCIT.AIMRL.PRM.Entities.Enum;

namespace PUCIT.AIMRL.PRM.MainApp.Security
{
    public static class PermissionManager
    {
        public static Boolean PerCanAddContributer
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanAddContributer"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanAddContributer"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanAddContributer"] = value;
            }
        }
        //public static Boolean PerCanSeeActivityLog
        //{
        //    get
        //    {
        //        if (System.Web.HttpContext.Current.Session["PerCanSeeActivityLog"] != null)
        //            return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanSeeActivityLog"]);
        //        else
        //            return false;
        //    }
        //    set
        //    {
        //        System.Web.HttpContext.Current.Session["PerCanSeeActivityLog"] = value;
        //    }
        //}
        public static Boolean PerCanWriteApplication
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanWriteApplication"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanWriteApplication"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanWriteApplication"] = value;
            }
        }
        public static Boolean PerCanEditApplication
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanEditApplication"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanEditApplication"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanEditApplication"] = value;
            }
        }
        public static Boolean PerCanApproveApplication
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanApproveApplication"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanApproveApplication"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanApproveApplication"] = value;
            }
        }

        public static Boolean PerCanRejectApplication
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanRejectApplication"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanRejectApplication"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanRejectApplication"] = value;
            }
        }
        public static Boolean PerCanPrintApplication
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanPrintApplication"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanPrintApplication"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanPrintApplication"] = value;
            }
        }

        public static Boolean PerCanGiveRemarks
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanGiveRemarks"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanGiveRemarks"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanGiveRemarks"] = value;
            }
        }

        public static Boolean perCanProvideSignature
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perCanProvideSignature"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perCanProvideSignature"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perCanProvideSignature"] = value;
            }
        }

        public static Boolean perCanForwardApplication
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perCanForwardApplication"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perCanForwardApplication"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perCanForwardApplication"] = value;
            }
        }

        public static Boolean perCanAccessAttachedDocs
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perCanAccessAttachedDocs"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perCanAccessAttachedDocs"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perCanAccessAttachedDocs"] = value;
            }
        }

        public static Boolean perAccessToAppsOtherThanSelfAssigned
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perAccessToAppsOtherThanSelfAssigned"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perAccessToAppsOtherThanSelfAssigned"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perAccessToAppsOtherThanSelfAssigned"] = value;
            }
        }

        public static Boolean perAccessToAssignedApps
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perAccessToAssignedApps"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perAccessToAssignedApps"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perAccessToAssignedApps"] = value;
            }
        }

        public static Boolean perAccessToSelfCreatedApps
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perAccessToSelfCreatedApps"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perAccessToSelfCreatedApps"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perAccessToSelfCreatedApps"] = value;
            }
        }

        public static Boolean perAccessToAllApps
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perAccessToAllApps"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perAccessToAllApps"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perAccessToAllApps"] = value;
            }
        }


        public static Boolean PerCanHandleRecieving
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanHandleRecieving"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanHandleRecieving"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanHandleRecieving"] = value;
            }
        }
        public static Boolean PerCanAllowApplicationEditing
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanAllowApplicationEditing"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanAllowApplicationEditing"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanAllowApplicationEditing"] = value;
            }
        }

        public static Boolean PerCanRouteBack
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerCanRouteBack"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerCanRouteBack"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerCanRouteBack"] = value;
            }
        }
        public static Boolean PerUpdateBonaFiedCGPA
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["PerUpdateBonaFiedCGPA"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["PerUpdateBonaFiedCGPA"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["PerUpdateBonaFiedCGPA"] = value;
            }
        }
        public static Boolean perManageWorkFlows
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perManageWorkFlows"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perManageWorkFlows"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perManageWorkFlows"] = value;
            }
        }
        public static Boolean perCanLoginAsOtherUser
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perCanLoginAsOtherUser"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perCanLoginAsOtherUser"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perCanLoginAsOtherUser"] = value;
            }
        }
        public static Boolean perDecideBehalfOnOtherUser
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perDecideBehalfOnOtherUser"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perDecideBehalfOnOtherUser"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perDecideBehalfOnOtherUser"] = value;
            }
        }
        public static Boolean perManageSecurityUsers
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perManageSecurityUsers"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perManageSecurityUsers"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perManageSecurityUsers"] = value;
            }
        }
        public static Boolean perManageSecurityRoles
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perManageSecurityRoles"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perManageSecurityRoles"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perManageSecurityRoles"] = value;
            }
        }
        public static Boolean perManageSecurityPermissions
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perManageSecurityPermissions"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perManageSecurityPermissions"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perManageSecurityPermissions"] = value;
            }
        }
        public static Boolean
            perManageSecurityInventory
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perManageSecurityInventory"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perManageSecurityInventory"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perManageSecurityInventory"] = value;
            }
        }
        public static Boolean perViewLoginHistoryReport
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perViewLoginHistoryReport"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perViewLoginHistoryReport"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perViewLoginHistoryReport"] = value;
            }
        }
        public static Boolean perViewApplicationCountStatuswise
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perViewApplicationCountStatuswise"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perViewApplicationCountStatuswise"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perViewApplicationCountStatuswise"] = value;
            }
        }
        public static Boolean perCanSwapRequestAssignmentWithApprover
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perCanSwapRequestAssignmentWithApprover"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perCanSwapRequestAssignmentWithApprover"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perCanSwapRequestAssignmentWithApprover"] = value;
            }
        }
        public static Boolean perCanAccessSelfAndAssigned
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perCanAccessSelfAndAssigned"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perCanAccessSelfAndAssigned"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perCanAccessSelfAndAssigned"] = value;
            }
        }
        public static Boolean perViewItemsReport
        {
            get
            {
                if (System.Web.HttpContext.Current.Session["perViewItemsReport"] != null)
                    return Convert.ToBoolean(System.Web.HttpContext.Current.Session["perViewItemsReport"]);
                else
                    return false;
            }
            set
            {
                System.Web.HttpContext.Current.Session["perViewItemsReport"] = value;
            }
        }
        public static ApplicationAccessType GetAccessTypeForLoggedInUser()
        {
            ApplicationAccessType accessType = ApplicationAccessType.None;

            if (PermissionManager.perAccessToSelfCreatedApps == true)
            {
                accessType = ApplicationAccessType.SelfCreated;
            }
            if (PermissionManager.perAccessToAssignedApps)
            {
                accessType = ApplicationAccessType.Assigned;
            }
            if (PermissionManager.perAccessToAppsOtherThanSelfAssigned)
            {
                accessType = ApplicationAccessType.OtherThanSelfAndAssigned;
            }
            if (PermissionManager.perAccessToAllApps)
            {
                accessType = ApplicationAccessType.All;
            }

            return accessType;
        }

    }
}