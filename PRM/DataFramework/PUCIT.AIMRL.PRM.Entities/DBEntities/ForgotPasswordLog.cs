using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    public class ForgotPasswordLogDTO
    {
        public Int64 ID { get; set; }
        public String Login { get; set; }
        public String Token { get; set; }
        public String MachineIP { get; set; }
        public String URL { get; set; }
        public Boolean Found { get; set; }
        public Boolean IsUsed { get; set; }
        public DateTime EntyDate { get; set; }
        //public DateTime UpdatedOn { get; set; }

        [NotMapped]
        public String EntryDateTimeStr
        {
            get
            {
                return HelperMethods.ChangeDTFormat(this.EntyDate);
            }
        }

        //[NotMapped]
        //public String UpdatedOnTimeStr
        //{
        //    get
        //    {
        //        return HelperMethods.ChangeDTFormat(this.UpdatedOn);
        //    }
        //}
    }

    public class ForgotPasswordSearchParam
    {
        public ForgotPasswordSearchParam()
        {
            SDate = new DateTime(1900, 1, 1);
            EDate = DateTime.MaxValue;
            Login = "";
            PageSize = 10;
            PageIndex = 0;
        }
        public String Login { get; set; }
        public DateTime SDate { get; set; }
        public DateTime EDate { get; set; }
        public int PageSize { get; set; }
        public int PageIndex { get; set; }
    }
    public class ForgotPasswordSearchResult
    {
        public int ResultCount { get; set; }
        public List<ForgotPasswordLogDTO> Result { get; set; }
    }
}