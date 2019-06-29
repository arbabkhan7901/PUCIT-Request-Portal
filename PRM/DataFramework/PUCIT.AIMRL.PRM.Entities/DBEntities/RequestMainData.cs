using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.RequestMainData")]
    public class RequestMainData
    {
        [Key]
        public int RequestID { get; set; }
        public int CategoryID { get; set; }
        public int UserId { get; set; }
        public String RollNo { get; set; }
        public DateTime CreationDate { get; set; }
        public DateTime? TargetDate { get; set; }
        public int TargetSemester { get; set; }
        public int? CurrentSemester { get; set; }
        public String Reason { get; set; }
        public DateTime? ActionDate { get; set; }

        public String Subject { get; set; }
        public int RequestStatus { get; set; }

        public Boolean IsRecievingDone { get; set; }

        public Boolean CanStudentEdit { get; set; }
        public String RequestToken { get; set; }
        public String ReqUniqueId { get; set; }

        [NotMapped]
        public String Section { get; set; }

        [NotMapped]
        public String FatherName { get; set; }
        
        [NotMapped]
        public String DateStr
        {
            get
            {
                return HelperMethods.ConvertOnlyDateToStr(this.CreationDate);
            }
        }
        [NotMapped]
        public String ActionDateStr
        {
            get
            {
                if (this.ActionDate.HasValue)
                    return HelperMethods.ChangeDTFormat2(this.ActionDate.Value);
                else
                    return "";
                
            }
        }
        [NotMapped]
        public String TargetDateStr
        {
            get
            {
                if (this.TargetDate.HasValue)
                    return HelperMethods.ConvertOnlyDateToStr(this.TargetDate.Value);
                else
                    return "";
            }
        }

        [NotMapped]
        public String ApplicantName { get; set; }

        [NotMapped]
        public String Title { get; set; }
        
    }
}
