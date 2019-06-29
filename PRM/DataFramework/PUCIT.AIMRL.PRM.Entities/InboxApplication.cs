using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PUCIT.AIMRL.Common;


namespace PUCIT.AIMRL.PRM.Entities
{
    public class InboxApplication
    {
        public String RollNo { get; set; }
        public String Subject { get; set; }
        public DateTime EntryTime { get; set; }
        public int ApplicationId { get; set; }


        public string DiaryNo
        {
            get
            {
                return "Acad/" + ApplicationId;
            }
        }
        public int Status { get; set; }

        public String StatusText
        {
            get
            {
                if (this.Status == 1)
                    return "Not Assigned";
                else if (this.Status == 2)
                    return "Pending";
                else if (this.Status == 3)
                    return "Accepted";
                else if (this.Status == 4)
                    return "Rejected";
                else if (this.Status == 5)
                    return "Rejected Before Assignment";
                else return "";


            }
        }
        public String EntryTimeStr
        {
            get
            {
                return HelperMethods.ConvertOnlyDateToStr(this.EntryTime);
            }
        }
    }

    public class AppCountDataStatusWise
    {
        public int All { get; set; }
        public int Pending { get; set; }
        public int Accepted { get; set; }
        public int Rejected { get; set; }

        public int NotAssigned { get; set; }

        public int RejectedBeforeAssignment { get; set; }
    }

    public class ApplicationAccessData
    {
        public Boolean IsValidAccess { get; set; }
        public Boolean RecFlag { get; set; }
        public Boolean RouteBackFlag { get; set; }
        public Boolean CanStdEditFlag { get; set; }
        public Boolean IsPendingForCurrUser { get; set; }
        public int AppStatus { get; set; }
        public String ReqUniqueId { get; set;}
    }

}
