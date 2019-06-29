using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.ClearanceFormData")]
    public class ClearanceFormData
    {
        [Key]
        public int ID { get; set; }
        public int RequestId { get; set; }
        public String LibraryID { get; set; }
    }
}
