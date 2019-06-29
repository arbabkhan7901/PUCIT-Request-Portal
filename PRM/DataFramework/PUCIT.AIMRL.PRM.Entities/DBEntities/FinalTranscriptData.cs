using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.FinalTranscriptData")]
    public class FinalTranscriptData
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public String FYPtitle { get; set; }
        public String PUreg { get; set; }

        //Navigation Property
        public virtual RequestMainData requestData { get; set; }
    }
}
