﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.Permissions")]
    public class Permissions
    {
        [Key]
        public int Id { get; set; }
        public String Name { get; set; }
        public String Description { get; set; }
        public Boolean IsActive { get; set; }
        public int CreatedBy { get; set; }
        public DateTime CreatedOn { get; set; }
        public int? ModifiedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
    }
}
