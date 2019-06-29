using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using PUCIT.AIMRL.Common;


namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.OptionForBscDegree")]
    public class OptionForBscDegree
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public string CNIC { get; set; }
        public DateTime dateOfBirth { get; set; }
        public string PUreg { get; set; }
        public string fathersign { get; set; }
        [NotMapped]
        public String DobStr
        {
            get
            {
                return HelperMethods.ConvertOnlyDateToStr(this.dateOfBirth);
            }
        }

        //Navigation Property
        public virtual RequestMainData requestData { get; set; }
    }

    public class OptionForBscDegreeDTO
    {
        public int ID { get; set; }
        public int RequestID { get; set; }
        public string CNIC { get; set; }
        public DateTime dateOfBirth { get; set; }
        public string PUreg { get; set; }
        public string fathersign { get; set; }

    }
}
