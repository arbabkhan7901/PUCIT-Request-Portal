using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using PUCIT.AIMRL.PRM.Entities.DBEntities;

namespace PUCIT.AIMRL.IMS.Entities.DBEntities
{
    [Table("dbo.HardwareItems")]
    public class HardwareItems
    {
        [Key]
        public int ItemId { get; set; }
        public String ItemName { get; set; }
        public String Description { get; set; }
        public int Quantity { get; set; }
        public Boolean IsActive { get; set; }

        public int CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public int? ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
    }
    public class selectedHardwareItem
    {
        public int ItemId { get; set; }
        public String ItemName { get; set; }
        public String Description { get; set; }
        public int Quantity { get; set; }
        public Boolean IsActive { get; set; }
    }
    public class selectedHardwareItemWrapper
    {
        public List<SelectedItem> Items { get; set; }
    }
}
