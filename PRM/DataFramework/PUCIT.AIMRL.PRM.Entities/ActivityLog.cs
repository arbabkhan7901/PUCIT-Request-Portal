using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities
{
    public class ActivityLog
    {
        public String Approver { get; set; }
        public String statusType { get; set; }
        public DateTime StatusTime { get; set; }
        public String Remarks { get; set; }
        public int ApproverId { get; set; }
    }
}
