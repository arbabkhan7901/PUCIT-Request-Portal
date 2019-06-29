using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.AttachmentTypes")]
    public class AttachmentTypes
    {
        [Key]
        public int AttachmentTypeID { get; set; }
        public String typeName { get; set; }
        public String Description { get; set; }


    }
}
