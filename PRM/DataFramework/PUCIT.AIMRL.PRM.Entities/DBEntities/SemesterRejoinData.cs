using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.SemesterRejoinData")]
    public class SemesterRejoinData
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public string withDrawApplicationNo { get; set; }
        public virtual RequestMainData requestData { get; set; }
    }
}
