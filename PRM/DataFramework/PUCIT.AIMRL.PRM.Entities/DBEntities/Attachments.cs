using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.Attachments")]
    public class Attachments
    {
        [Key]
        public int AttachmentID { get; set; }
        public int RequestID { get; set; }
        public int AttachmentTypeID { get; set; }
        public DateTime UploadDate { get; set; }
        public int IsActive { get; set; }
        public String FileName { get; set; }
        public String Description { get; set; }


    }
}
