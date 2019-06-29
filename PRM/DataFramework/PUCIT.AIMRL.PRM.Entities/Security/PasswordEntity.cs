using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities
{
    public class PasswordEntity
    {
        public String Token { get; set; }
        public String CurrentPassword { get; set; }

        public String NewPassword { get; set; }
    }
}
