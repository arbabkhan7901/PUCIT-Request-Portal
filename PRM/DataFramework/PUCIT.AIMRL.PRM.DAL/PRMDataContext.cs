using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.ComponentModel.DataAnnotations.Schema;
using PUCIT.AIMRL.PRM.Entities;
using PUCIT.AIMRL.PRM.Entities.DBEntities;

namespace PUCIT.AIMRL.PRM.DAL
{
    public class PRMDataContext : DbContext
    {
        private static readonly string ConnectionString = DatabaseHelper.Instance.MainDBConnectionString;

        public DbSet<SampleStudent> SampleStudents { get; set; }

        public DbSet<ApproverHierarchy> ApproverHierarchy { get; set; }
        public DbSet<Approvers> Approvers { get; set; }
        public DbSet<FormCategories> FormCategories { get; set; }
        public DbSet<RequestMainData> RequestMainData { get; set; }
        public DbSet<ReqWorkflow> ReqWorkflow { get; set; }
        public DbSet<StatusTypes> StatusTypes { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<BonafideCertificateData> BonafideCertificateData { get; set; }

        public DbSet<CollegeIDCardData> CollegeIDCardData { get; set; }
        public DbSet<CourseWithdrawal> CourseWithdrawalData { get; set; }
        // public DbSet<CourseWithdrawData> CourseWithdrawData { get; set; }
        public DbSet<FinalTranscriptData> FinalTranscriptData { get; set; }
        public DbSet<SemesterAcademicTranscript> SemesterAcademicTranscript { get; set; }

        public DbSet<LeaveApplicationForm> LeaveApplicationForm { get; set; }
        public DbSet<OptionForBscDegree> OptionForBscDegree { get; set; }
        public DbSet<ReceiptOfOrignalEducationalDocuments> ReceiptOfOrignalEducationalDocuments { get; set; }
        public DbSet<SemesterRejoinData> SemesterRejoinData { get; set; }
        public DbSet<VehicalTokenData> VehicalTokenData { get; set; }
        public DbSet<RoomReservation> RoomReservation { get; set; }

        //    public DbSet<CourseWithdrawData> CourseWithdrawData { get; set; }
        public DbSet<Roles> Roles { get; set; }
        
        public DbSet<PermissionsMapping> PermissionsMapping { get; set; }
        public DbSet<UserRoles> UserRoles { get; set; }
        public DbSet<Attachments> Attachments { get; set; }
        public DbSet<AttachmentTypes> AttachmentTypes { get; set; }
        public DbSet<ActivityLogTable> ActivityLogData { get; set; }
        public DbSet<ClearanceFormData> ClearanceFormData { get; set; }
        public DbSet<DemandForm> DemandForm { get; set; }
        public DbSet<DemandVoucher> DemandVoucher { get; set; }
        public DbSet<HardwareForm> HardwareForm { get; set; }
        public DbSet<EmailRequest> EmailRequests { get; set; }
        public DbSet<StoreDemandVoucher> StoreDemandVoucher { get; set; }
        public DbSet<LabReservationData> LabReservationData { get; set; }

        public PRMDataContext()
            : base(ConnectionString)
        {
            // We'll eager load entities whenever required.
            Configuration.LazyLoadingEnabled = false;
            Configuration.ProxyCreationEnabled = false;
            ((IObjectContextAdapter)this).ObjectContext.CommandTimeout = 3000;
        }


        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
        }
    }
}



