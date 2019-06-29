using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.FormCategories")]
    public class FormCategories
    {
        [Key]
        public int CategoryID { get; set; }
        public String Category { get; set; }

        public Boolean IsParalApprovalAllowed { get; set; }

        public Boolean IsRecievingAllowed { get; set; }

        public String Instructions { get; set; }
    }
}
