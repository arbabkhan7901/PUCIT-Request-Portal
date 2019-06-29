using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.BonafideCertificateData")]
    public class BonafideCertificateData
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public double? CGPA { get; set; }
        public String ChallanForm { get; set; }
        public String PUreg { get; set; }
    }
}
