using PUCIT.AIMRL.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.RoomReservation")]
    public class RoomReservation
    {
        [Key]
        public int ID { get; set; }
        public int RequestID{ get; set; }
        public int TotalStudents{ get; set; }
        public String Purpose { get; set; }
        public Boolean isMultimediaRequired { get; set; }
        public DateTime? Date{ get; set; }
        public DateTime? TimeFrom{ get; set; }
        public DateTime? TimeTo { get; set; }
        [NotMapped]
        public String RoomResDateStr
        {
            get
            {
                if (this.Date.HasValue)
                {
                    return HelperMethods.ConvertOnlyDateToStr(this.Date.Value);
                }
                else
                    return "";
            }
        }
        [NotMapped]        public String TimeFromStr        {            get            {                if (this.TimeFrom.HasValue)                {                    return HelperMethods.ConvertOnlyTimeToStr(this.TimeFrom.Value);                }                else                    return "";
            }        }        [NotMapped]        public String TimeToStr        {            get            {                if (this.TimeTo.HasValue)                {                    return HelperMethods.ConvertOnlyTimeToStr(this.TimeTo.Value);                }                else                    return "";            }        }

    }

}

