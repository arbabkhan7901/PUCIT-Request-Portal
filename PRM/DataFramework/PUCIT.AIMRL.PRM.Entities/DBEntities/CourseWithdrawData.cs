using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.CourseWithdrawData")]
    public class CourseWithdrawData
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public String CourseID { get; set; }
        public String CourseTitle { get; set; }
        public int CreditHours { get; set; }


        //Navigation Properties
        public virtual RequestMainData Request { get; set; }
       
    }
}
