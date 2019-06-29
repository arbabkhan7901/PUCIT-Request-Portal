using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.CourseWithdrawal")]
    public class CourseWithdrawal
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public String CourseID { get; set; }
        public String CourseTitle { get; set; }
        public int CreditHours { get; set; }
        public String TeacherName { get; set; }
        public int ApproverID { get; set; }

        //Navigation Property
        public virtual RequestMainData requestData { get; set; }
    }
}
