using PUCIT.AIMRL.Common;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.LabReservationData")]
    public class LabReservationData
    {
        [Key]
        public int Id { get; set; }
        public int RequestId { get; set; }
        public String CourseTitle { get; set; } 
        public int noOfComputer { get; set; }
        public String SuggestedLab { get; set; }

      
        public String Day { get; set; }
        public DateTime? PerTimeFrom { get; set; }
        public DateTime? PerTimeTo { get; set; }

       
        public DateTime? TempDateFrom { get; set; }
        public DateTime? TempDateTo { get; set; }
        public DateTime? TempTimeFrom { get; set; }
        public DateTime? TempTimeTo { get; set; }

       
        public bool IsPermanent { get; set; }
        public bool IsTemporary { get; set; }

        [NotMapped]
        public String PerTimeFromStr {
            get {
                if (this.PerTimeFrom.HasValue)
                {
                    return HelperMethods.ConvertOnlyTimeToStr(this.PerTimeFrom.Value);
                }
                else
                    return "";
            }
        }
        [NotMapped]
        public String PerTimeToStr
        {
            get
            {
                if (this.PerTimeTo.HasValue)
                {
                    return HelperMethods.ConvertOnlyTimeToStr(this.PerTimeTo.Value);
                }
                else
                    return "";
            }
        }
        [NotMapped]
        public String TempTimeFromStr
        {
            get
            {
                if (this.TempTimeFrom.HasValue)
                {
                    return HelperMethods.ConvertOnlyTimeToStr(this.TempTimeFrom.Value);
                }
                else
                    return "";     
            }
        }
        [NotMapped]
        public String TempTimeToStr
        {
            get
            {
                if (this.TempTimeTo.HasValue)
                {
                    return HelperMethods.ConvertOnlyTimeToStr(this.TempTimeTo.Value);
                }
                else
                    return "";
            }
        }
        [NotMapped]
        public String TempDateFromStr
        {
            get
            {
                if (this.TempDateFrom.HasValue)
                {
                    return HelperMethods.ConvertOnlyDateToStr(this.TempDateFrom.Value);
                }
                else
                    return "";
            }
        }
        [NotMapped]
        public String TempDateToStr
        {
            get
            {
                if (this.TempDateTo.HasValue)
                {
                    return HelperMethods.ConvertOnlyDateToStr(this.TempDateTo.Value);
                }
                else
                    return "";
            }
        }
    }
}
