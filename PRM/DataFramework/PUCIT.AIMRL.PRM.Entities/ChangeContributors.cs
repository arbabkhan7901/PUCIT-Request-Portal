using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities
{
    public class ChangeContributors
    {
        public int[] removeContrList { get; set; }
        public int[] addContrList { get; set; }
        public int requestId { get; set; }
        public int  CurrentUserId { get; set; }
    }
}
