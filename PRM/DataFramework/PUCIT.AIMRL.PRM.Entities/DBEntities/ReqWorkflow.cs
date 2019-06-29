using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.ReqWorkflow")]
    public class ReqWorkflow
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public int ApproverID { get; set; }
        public int? AltApproverID { get; set; }
        public int ApprovalOrder { get; set; }
        public int Status { get; set; }
        public String Remarks { get; set; }
        public DateTime EntryTime { get; set; }
        public DateTime? StatusTime { get; set; }
        public int? ActionUserID { get; set; }
        [NotMapped]
        public String ReqUniqueId { get; set; }

        //// Navigation properties
        //public virtual Approvers Approver { get; set; }
        //public virtual Approvers AltApprover { get; set; }
        //public virtual Approvers ActionUser { get; set; }
        //public virtual StatusTypes RequestStatus { get; set; }
        //public virtual RequestMainData RequestMainData { get; set; }

        [NotMapped]
        public String EntrytimeStr
        {
            get
            {
                return HelperMethods.ConvertOnlyDateToStr(this.EntryTime);
            }
        }
        [NotMapped]
        public String StatusTimeStr
        {
            get
            {
                if (this.StatusTime.HasValue)
                    return HelperMethods.ConvertOnlyDateToStr(this.StatusTime.Value);
                else
                    return "";
            }
        }

    }


    public class ReqWorkFlowShort
    {
        public int ID { get; set; }
        public int ApproverID { get; set; }
        public int ApprovalOrder { get; set; }

    }
}
