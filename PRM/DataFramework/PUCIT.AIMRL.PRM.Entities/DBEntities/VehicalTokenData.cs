using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.VehicalTokenData")]
    public class VehicalTokenData
    {
        [Key]
        public string VehicalRegNo { get; set; }
        public int RequestID { get; set; }
        public string Model { get; set; }
        public string manufacturer { get; set; }
        public string ownerName { get; set; }
    }
}
