using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.StatusTypes")]
    public class StatusTypes
    {
        [Key]
        public int StatusTypeID { get; set; }
        public String StatusType { get; set; }

        //Refer to child
        //public virtual ICollection<ReqWorkflow> RequestWorkflow { get; set; }
    }
}
