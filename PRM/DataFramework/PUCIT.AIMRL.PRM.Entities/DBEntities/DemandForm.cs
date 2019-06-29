using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.DemandForm")]
    public class DemandForm
    {
        [Key]
        public int demandId { get; set; }
        public int RequestID { get; set; }
        public int ItemId { get; set; }
        public String ItemName { get; set; }
        public int Quantity { get; set; }
        public int IssuedQty { get; set; }

        //Navigation Property
        public virtual RequestMainData requestData { get; set; }
    }
}
