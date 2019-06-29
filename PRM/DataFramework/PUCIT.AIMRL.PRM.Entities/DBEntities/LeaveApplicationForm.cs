using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using PUCIT.AIMRL.Common;


namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.LeaveApplicationForm")]
    public class LeaveApplicationForm
    {
        [Key]
        public int ID { get; set; }
        public int RequestID { get; set; }
        public DateTime startDate { get; set; }
        public DateTime endDate { get; set; }

        //Navigation Property
        public virtual RequestMainData requestData { get; set; }


        [NotMapped]
        public String startDateStr
        {
            get
            {
                return HelperMethods.ConvertOnlyDateToStr(this.startDate);
            }
        }


        [NotMapped]
        public String endDateStr
        {
            get
            {
                return HelperMethods.ConvertOnlyDateToStr(this.endDate);
            }
        }

    }
}
