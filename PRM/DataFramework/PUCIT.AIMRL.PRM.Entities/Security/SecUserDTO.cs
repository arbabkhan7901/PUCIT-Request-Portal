using PUCIT.AIMRL.PRM.Entities.DBEntities;
using PUCIT.AIMRL.PRM.Entities.Enum;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.Security
{
    public class SecUserDTO
    {
        
        public String UserFullName { get; set; }
        public int UserId { get; set; }
        public String Login { get; set; }
        public String SignatureName { get; set; }

        public String Email { get; set; }

        public String Title { get; set; }

        public String StdFatherName { get; set; }

        public String Section { get; set; }

        public Boolean IsContributor { get; set; }
        public Boolean IsActive { get; set; }
        public Boolean IsDisabledForLogin { get; set; }
        
        public ApplicationAccessType AppAccessType
        {
            get;
            set;
        }

        public List<String> Permissions { get; set; }

        public List<String> Roles { get; set; }

        public int CurrentApproverID { get; set; }

        public List<ApproverDesignation> ApproverDesignations
        {
            get;
            set;
        }
    }

    public class ApproverDesignation
    {
        public int ApproverID { get; set; }
        public String Designation { get; set; }
        public int UserID { get; set; }
    }
}
