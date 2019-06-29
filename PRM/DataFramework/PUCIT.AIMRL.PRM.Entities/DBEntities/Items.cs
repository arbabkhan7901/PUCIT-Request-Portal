using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.Items")]
    public class Items
    {
        [Key]
        public int ItemId { get; set; }
        public String ItemName { get; set; }
        public String Description { get; set; }
        public int Type { get; set; }
        public int Quantity { get; set; }
        public Boolean IsActive { get; set; }

        public int CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public int? ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }

        [NotMapped]
        public String ModifiedOnDateStr
        {
            get
            {
                if (this.ModifiedOn.HasValue)
                    return HelperMethods.ConvertOnlyDateToStr(ModifiedOn.Value);
                else
                    return "";
            }
        }
    }
    public class SelectedItem
    {
        public int ItemId { get; set; }
        public String ItemName { get; set; }
        public String Description { get; set; }
        public int Quantity { get; set; }
        public Boolean IsActive { get; set; }

    }
    public class SelectedItemWrapper
    {
        public List<SelectedItem> Items { get; set; }
    }
}

