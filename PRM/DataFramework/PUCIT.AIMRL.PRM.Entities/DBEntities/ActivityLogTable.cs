using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.Common;


namespace PUCIT.AIMRL.PRM.Entities.DBEntities
{
    [Table("dbo.ActivityLogTable")]
    public class ActivityLogTable
    {
        [Key]
        public int Id { get; set; }
        public int RequestId { get; set; }
        public int UserId { get; set; }
        public String Comments { get; set; }
        public String Activity { get; set; }
        public DateTime ActivityTime { get; set; }

        public Boolean IsPrintable { get; set; }

        //public int ActivityVisibleTo { get; set; }
        //public int WhoCanReply { get; set; }

        public int VisibleToUserID { get; set; }
        public int CanReplyUserID { get; set; }

        public Boolean ShowActionPanel { get; set; }

        public Boolean CanReplyFlag { get; set; }

        [NotMapped]
        public String ReqUniqueId { get; set; }

        [NotMapped]
        public String SignatureName { get; set; }

        [NotMapped]
        public String ActivityTimeStr
        {
            get
            {
                return HelperMethods.ChangeDTFormat(this.ActivityTime);
            }
        }
       
    }

   
    public class ActivityLogConversation
    {
        
        public long ConversationID { get; set; }
        public int ActivityLogID { get; set; }
        public int UserID { get; set; }
        public String Message { get; set; }
        public DateTime MessageTime { get; set; }

        
        public String UserName { get; set; }


        [NotMapped]
        public int RequestId { get; set; }

        [NotMapped]
        public String ReqUniqueId { get; set; }

        [NotMapped]
        public String MessageTimeTimeStr
        {
            get
            {
                return HelperMethods.ChangeDTFormat(this.MessageTime);
            }
        }

    }
}
