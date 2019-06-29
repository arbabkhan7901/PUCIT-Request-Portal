using PUCIT.AIMRL.PRM.Entities.DBEntities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PUCIT.AIMRL.PRM.Entities
{
    public class CustomLeaveApplication
    {
        public LeaveApplicationForm leave { get; set; }
        public RequestMainData request { get; set; }
        public CustomLeaveApplication()
        {
            leave = new LeaveApplicationForm();
            request = new RequestMainData();
        }
    }
    public class CustomApplicationStatusReport
    {
        public String Login { get; set; }
        public String Name { get; set; }
        public String IsContributor { get; set; }
        public String Title { get; set; }
        public String Email { get; set; }
        public int UserId { get; set; }
        public int All { get; set; }
        public int Pending { get; set; }
        public int Accepted { get; set; }
        public int Rejected { get; set; }
        public int NotAssigned { get; set; }   
    }
    public class CustomRoomReservation
    {
        public RequestMainData request { get; set; }
        public RoomReservation roomReservationData { get; set; }
        public CustomRoomReservation()
        {
            request = new RequestMainData();
            roomReservationData = new RoomReservation();
        }
    }
     public class customCourseWithdraw
    {
        public RequestMainData request { get; set; }
        public List<CourseWithdrawal> course;
        public customCourseWithdraw()
        {
            request = new RequestMainData();
            course = new List<CourseWithdrawal>();
        }
    }
    public class CustomBscApplication
    {
        public OptionForBscDegree bsc { get; set; }
        public RequestMainData request { get; set; }

        public Attachments FatherCNIC { get; set; }
        public Attachments AppLicantCNIC { get; set; }
        public CustomBscApplication()
        {
            bsc = new OptionForBscDegree();
            request = new RequestMainData();
            AppLicantCNIC = new Attachments();
            FatherCNIC = new Attachments();
        }
    }
    public class CustomFinalAcad
    {
        public RequestMainData request { get; set; }
        public FinalTranscriptData finalTranscript { get; set; }
        public Attachments ClearanceFrom { get; set; }
        public CustomFinalAcad()
        {
            request = new RequestMainData();
            finalTranscript = new FinalTranscriptData();
            ClearanceFrom = new Attachments();
        }
    }
    public class CustomCollegeIDCard
    {
        public RequestMainData request { get; set; }
        public CollegeIDCardData IDCard { get; set; }

        public Attachments Challan { get; set; }

        public CustomCollegeIDCard()
        {
            request = new RequestMainData();
            Challan = new Attachments();
            IDCard = new CollegeIDCardData();
        }
    }
    public class CustomClearanceForm
    {
        public RequestMainData request { get; set; }
        public Attachments Photograph { get; set; }
        public ClearanceFormData clearanceFormData { get; set; }
        public CustomClearanceForm()
        {
            request = new RequestMainData();
            Photograph = new Attachments();
            clearanceFormData = new ClearanceFormData();
        }
    }
    public class CustomVehicalTokenData
    {
        public RequestMainData request { get; set; }
        public VehicalTokenData vehical { get; set; }

        public Attachments Photo { get; set; }
        public Attachments Registration { get; set; }
        public Attachments IDCard { get; set; }

        public CustomVehicalTokenData()
        {
            request = new RequestMainData();
            vehical = new VehicalTokenData();
            Photo = new Attachments();
            Registration = new Attachments();
            IDCard = new Attachments();
        }

    }
    public class customReceiptOfOrignalDocument
    {
        public RequestMainData request { get; set; }
        public List<ReceiptOfOrignalEducationalDocuments> documents;
        public Attachments IDCard { get; set; }
        public Attachments ClearanceForm { get; set; }
        public customReceiptOfOrignalDocument()
        {
            request = new RequestMainData();
            documents = new List<ReceiptOfOrignalEducationalDocuments>();
            IDCard = new Attachments();
            ClearanceForm = new Attachments();
        }
    }
    public class customBonafide
    {
        public RequestMainData request { get; set; }
        public BonafideCertificateData bonafide { get; set; }
        public Attachments challan { get; set; }

        public customBonafide()
        {
            request = new RequestMainData();
            bonafide = new BonafideCertificateData();
            challan = new Attachments();
        }
    }
    public class customSemesterRejoin
    {
        public RequestMainData request { get; set; }
        public SemesterRejoinData rejoin { get; set; }

        public customSemesterRejoin()
        {
            request = new RequestMainData();
            rejoin = new SemesterRejoinData();
        }
    }
    public class customSemesterAcademic
    {
        public RequestMainData request { get; set; }
        public SemesterAcademicTranscript semesterAcad { get; set; }
        public Attachments challan { get; set; }

        public customSemesterAcademic()
        {
            request = new RequestMainData();
            semesterAcad = new SemesterAcademicTranscript();
            challan = new Attachments();
        }
    }
    public class customGeneralRequest
    {
        public RequestMainData request { get; set; }
        public Attachments attach1 { get; set; }
        public AttachmentTypes type1 { get; set; }
        public Attachments attach2 { get; set; }
        public AttachmentTypes type2 { get; set; }
        public customGeneralRequest()
        {
            request = new RequestMainData();
            attach1 = new Attachments();
            attach2 = new Attachments();
            type1 = new AttachmentTypes();
            type2 = new AttachmentTypes();
        }
    }
    public class CustomAttachments
    {
        public Attachments attachment { get; set; }
        public AttachmentTypes type { get; set; }
        public CustomAttachments()
        {
            attachment = new Attachments();
            type = new AttachmentTypes();
        }

    }

    public class CustomDemandForm
    {
        public RequestMainData request { get; set; }
        public List<DemandForm> Items;
        public CustomDemandForm()
        {
            request = new RequestMainData();
            Items = new List<DemandForm>();
        }
    }

    public class CustomDemandVoucher
    {
        public RequestMainData request { get; set; }
        public List<DemandVoucher> Items;
        public CustomDemandVoucher()
        {
            request = new RequestMainData();
            Items = new List<DemandVoucher>();
        }
    }

    public class CustomStoreDemandVoucher
    {
        public RequestMainData request { get; set; }
        public List<StoreDemandVoucher> Items;
        public CustomStoreDemandVoucher()
        {
            request = new RequestMainData();
            Items = new List<StoreDemandVoucher>();

        }
    }

    public class CustomHardwareForm
    {
        public RequestMainData request { get; set; }
        public List<HardwareForm> Items;
        public CustomHardwareForm()
        {
            request = new RequestMainData();
            Items = new List<HardwareForm>();
        }
    }

    public class CustomLabReservationForm {
        public RequestMainData request { get; set; }
        public LabReservationData labReservationData { get; set; }
        public CustomLabReservationForm() {
            request = new RequestMainData();
            labReservationData = new LabReservationData();
        } 
    }

    public class customMappings
    {
        public List<PermissionsMapping> mappings { get; set; }
        public Roles roles { get; set; }
        public List<Permissions> permissions;
        public customMappings()
        {
            mappings = new List<PermissionsMapping>();
            permissions = new List<Permissions>();
            roles = new Roles();
        }
    }
    public class customPermissions
    {
        public int Id { get; set; }
        public String Name { get; set; }
        public Boolean Exist { get; set; }

    }
    public class customUpdateMappings
    {
        public int Roleid { get; set; }

        public List<customPermissions> Permissions;
        public customUpdateMappings()
        {
            Permissions = new List<customPermissions>();

        }
    }
    public class CustomItemReport
    {
        public String Login { get; set; }
        public String Name { get; set; }
        public String ItemName { get; set; }
        public String IsContributor { get; set; }
        public String Title { get; set; }
        public int UserId { get; set; }
        public int IssuedQty { get; set; }        
    }

    public class customUpdateIssuedQty
    {
        public RequestMainData request { get; set; }
        //public List<selectedItem> received_items { get; set; }
        public int[] isssuedQty;
        public int[] DemandId;
        public customUpdateIssuedQty()
        {
            request = new RequestMainData();
        }
    }
    public class customUpdateItems
    {

        public int[] ItemID;
        public int[] ItemQtyIssued;

    }
    public class customManageQty
    {

        public int ItemId;
        public String ItemName;
        public int Quantity;
        public int InQuantity;

    }



    public class DesignationDTO
    {
        public int DesignationID { get; set; }
        public String Designation { get; set; }
    }

    public class ApprDesigDTO
    {
        public int ApproverID { get; set; }
        public int DesignationID { get; set; }
    }

    public class ResponseResult
    {
        public Boolean success { get; set; }
        public String error { get; set; }

        public Object data { get; set; }

        public static ResponseResult GetErrorObject(String e = "Some error has occurred!", Object d = null)
        {
            var obj = new ResponseResult()
            {
                success = false,
                data= d,
                error = e
            };
            return obj;
        }
        public static ResponseResult GetSuccessObject(Object d = null, String msg = "")
        {
            var obj = new ResponseResult()
            {
                success = true,
                data = d,
                error = msg
            };
            return obj;
        }
    }

    public class PendingRequestsForNotification
    {
        public int ApproverID { get; set; }
        public int UserID { get; set; }
        public String Name { get; set; }
        public String Designation { get; set; }
        public String Email { get; set; }
        public int PendingDays { get; set; }
        public int RequestID { get; set; }
        public String RollNo { get; set; }
        public String Category { get; set; }

    }

    public class CustomUpdateIssuedQty
    {
        public RequestMainData request { get; set; }
        public int[] isssuedQty;
        public int[] DemandId;
        public CustomUpdateIssuedQty()
        {
            request = new RequestMainData();
        }
    }
    public class CustomUpdateItems
    {
        public int[] ItemID;
        public int[] ItemQtyIssued;
    }
    public class ClearanceDetails {
        public int clearanceReqId { get; set; }
        public int status { get; set; }
        public String clearanceUniqueReqId { get; set; }
    }
}
