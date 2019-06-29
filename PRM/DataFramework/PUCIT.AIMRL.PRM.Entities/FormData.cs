using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using PUCIT.AIMRL.PRM.Entities.DBEntities;

namespace PUCIT.AIMRL.PRM.Entities
{
    public class FormData
    {
        public RequestMainData MainData;
        public ClearanceFormData ClearanceFormData;
        public List<CourseWithdrawal> CourseWithdrawdata;
        public LeaveApplicationForm LeaveApplication;
        public CollegeIDCardData CollegeIdCard;
        public BonafideCertificateData BonafideCertificate;
        public FinalTranscriptData FinalTranscript;
        public OptionForBscDegree OptionForBsc;
        public List<ReceiptOfOrignalEducationalDocuments> ReceiptOfOriginal;
        public SemesterAcademicTranscript SemesterAcadamicTranscript;
        public SemesterRejoinData SemesterRejoin;
        public VehicalTokenData VehicalToken;
        public List<DemandForm> ItemDemandForm;
        public List<HardwareForm> HardwareFormItems;
        public List<DemandVoucher> DemandVoucherItems;
        public List<StoreDemandVoucher> StoreDemandVoucher;
        public RoomReservation RoomReservation;
        public LabReservationData LabReservation;
    }
}
