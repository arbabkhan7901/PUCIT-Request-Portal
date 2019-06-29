using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.ApproverHierarchy")]
    public class ApproverHierarchy
    {
        [Key]
        public int ID { get; set; }
        public int FormID { get; set; }
        public int ApproverID { get; set; }
        public int? AltApproverID { get; set; }
        public int ApprovalOrder { get; set; }
        public bool IsForNewCampus { get; set; }
        public bool IsForOldCampus
        {
            get; set;
            //Navigation Properties

            //public virtual FormCategories Form { get; set; }
            //public virtual Approvers Approver { get; set; }
            //public virtual Approvers AltApprover { get; set; }
        }


        public class ApproverHierarchyDTO
        {
            public int ApproverID { get; set; }
            public int ApprovalOrder { get; set; }
            public String ApproverName { get; set; }
        }
    }
}
