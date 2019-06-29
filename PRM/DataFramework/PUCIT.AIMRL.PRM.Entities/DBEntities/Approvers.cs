using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.Approvers")]
    public class Approvers
    {
        [Key]
        public int ApproverID { get; set; }
        public int DesignationID { get; set; }
        public int UserID { get; set; }
        public Boolean IsActive { get; set; }

    }

    public class ApproverHeirachyDTO
    {
        public int ApproverID { get; set; }
        public int ApprovalOrder { get; set; }
        public Boolean IsForNewCampus { get; set; }
        public Boolean IsForOldCampus { get; set; }

        public String DesigWithName { get; set; }
    }
}
