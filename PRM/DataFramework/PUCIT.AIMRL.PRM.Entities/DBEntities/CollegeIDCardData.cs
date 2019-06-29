using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.CollegeIDCardData")]
    public class CollegeIDCardData
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public int? serialNo { get; set; }
        public DateTime? issueDate { get; set; }
        public DateTime? ExpiryDate { get; set; }

        public String ChallanForm { get; set; }
    }
}
