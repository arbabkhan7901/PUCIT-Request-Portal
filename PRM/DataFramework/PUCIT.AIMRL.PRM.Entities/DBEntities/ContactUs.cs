using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;

namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    public class ContactUsDTO
    {
        public Int64 ID { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String MachineIP { get; set; }
        public String Description { get; set; }
        public DateTime EntryTime { get; set; }
        
        [NotMapped]
        public String EntryDateTimeStr
        {
            get
            {
                return HelperMethods.ChangeDTFormat(this.EntryTime);
            }
        }
    }

    public class ContactUsSearchParam
    {
        public ContactUsSearchParam()
        {
            SDate = new DateTime(1900, 1, 1);
            EDate = DateTime.MaxValue;
            Name = "";
            Email = "";
            PageSize = 10;
            PageIndex = 0;
        }
        public String Name { get; set; }
        public String Email { get; set; }
        
        public DateTime SDate { get; set; }
        public DateTime EDate { get; set; }
        public int PageSize { get; set; }
        public int PageIndex { get; set; }
    }
    public class ContactUsSearchResult
    {
        public int ResultCount { get; set; }
        public List<ContactUsDTO> Result { get; set; }
    }
}