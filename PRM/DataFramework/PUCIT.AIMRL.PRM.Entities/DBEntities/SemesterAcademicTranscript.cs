using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.SemesterAcademicTranscript")]
    public class SemesterAcademicTranscript
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public String ChallanNo { get; set; }
    }
}
