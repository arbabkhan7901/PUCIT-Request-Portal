MyWebApp.namespace("UI.Applications");

MyWebApp.UI.Applications = (function () {
    "use strict";
    var _isInitialized = false;
    var formCategoryData;
    var clicked_item_ID;
    var clicked_item;
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            hideAll();
            debugger;
            getInstructions();
            //setUserInfo();
            BindEvents();
        }
    }
    function BindEvents() {
        //Save Event
        $("#savedata").unbind('click').bind('click', function (e) {
            e.preventDefault();

            $('#SaveAlert').modal('show');
            //$.bsmodal.show("#SaveAlert");
            return false;
        });
        //modal alert events.
        $("#AlertModalClose").unbind("click").bind("click", function () {
            $('#SaveAlert').modal('hide');
            //$.bsmodal.hide("#SaveAlert");
            return false;
        });
        $("#save_no").unbind("click").bind("click", function () {
            $('#SaveAlert').modal('hide');
            //$.bsmodal.hide("#SaveAlert");
            return false;
        });
        $("#save_yes").unbind("click").bind("click", function () {
            $('#SaveAlert').modal('hide');
            //$.bsmodal.hide("#SaveAlert");
            var title = $("#formTitle").text();
            checkSavedForm(title);
        });

        $("#close").click(function (e) {
            e.preventDefault();
            debugger;
            hideAll();
            //return false;
        });
        $("#cancel").click(function (e) {
            e.preventDefault();
            debugger;
            hideAll();
            //return false;
        });
        $("#cancel_instruction").click(function (e) {
            $('#Note').modal('hide');
            //$.bsmodal.hide("#Note");
        });
        $("#Continue").click(function (e) {
            e.preventDefault();
            debugger;
            $('#Note').modal('hide');
            //$.bsmodal.hide("#Note");
            getSelected(clicked_item, clicked_item_ID);
            //return false;
        });
        //Click of dropdown
        $("#item_select").change(function (e) {
            e.preventDefault();
            debugger;
            hideAll();
            clicked_item_ID = $('#item_select').find(":selected").attr('value');
            clicked_item = $('#item_select').find(":selected").text();
            document.getElementById("item_select").value = $('#non').val();
            debugger;
            $("#title_formCategory").text(formCategoryData[clicked_item_ID - 1].Category);
            $("#instruction").text(formCategoryData[clicked_item_ID - 1].Instructions);
        
            $('#Note').modal('show');
            //$.bsmodal.show("#Note");
            //return false;
        }); //End of Save Click

    }
    function hasExtension(inputID, exts) {
        var fileName = (document.getElementById(inputID).value).toLowerCase();
        //alert((new RegExp('(' + exts.join('|').replace(/\./g, '\\.') + ')$')).test(fileName))
        return (new RegExp('(' + exts.join('|').replace(/\./g, '\\.') + ')$')).test(fileName);
    }

    function clearAttachment(id) {
        document.getElementById(id).value = "";
    }
    function showSuccessMsg(requestID) {
        debugger;
        //$.bsmodal.show("#SuccessMsg");
        $('#SuccessMsg').modal('show');

        $("#SuccessMsgClose").unbind("click").bind("click", function () {
            $('#SuccessMsg').modal('hide');
            //$.bsmodal.hide("#SuccessMsg");
            return false;
        });
        $("#viewApplication").unbind("click").bind("click", function () {
            $('#SuccessMsg').modal('hide');
            //$.bsmodal.hide("#SuccessMsg");
            window.location = MyWebApp.Globals.baseURL + 'Home/ApplicationView/' + requestID;
        });
        $("#ViewInbox").unbind("click").bind("click", function () {
            $('#SuccessMsg').modal('hide');
            //$.bsmodal.hide("#SuccessMsg");
            history.go(-1);
        });

    }
    function getInstructions() {
        var url = "Forms/getInstructions";

        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                console.log(result);
                debugger;
                formCategoryData = result.data;
            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting students: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function getSelected(clicked_item, clicked_item_ID) {
        if (clicked_item_ID == '1') {
            $("#formTitle").text(clicked_item);
            $("#widget_box_main").show();
            $("#widget_box_body").show();
            $("#Required_Reason_Div").show();
            $("#widget_footer").show();
            $("#clearanceForm").show();

        }
        else
            if (clicked_item_ID == '2') {
                $("#formTitle").text(clicked_item);
                $("#fatherName").show();
                $("#Current_Semester_Div").show();
                $("#widget_box_body").show();
                $("#Required_Reason_Div").show();
                $("#widget_footer").show();
                $("#widget_box_main").show();
                $("#leaveForm").show();

            }
            else
                if (clicked_item_ID == '3') {
                    $("#formTitle").text(clicked_item);
                    $("#fatherName").show();
                    $("#Current_Semester_Div").show();
                    $("#widget_box_body").show();
                    $("#Not_Required_Reason_Div").show();
                    $("#widget_footer").show();
                    $("#widget_box_main").show();
                    $("#optionsForBsc").show();

                }
                else
                    if (clicked_item_ID == '4') {
                        $("#formTitle").text(clicked_item);
                        $("#fatherName").show();
                        $("#widget_box_body").show();
                        $("#Not_Required_Reason_Div").show();
                        $("#widget_footer").show();
                        $("#widget_box_main").show();
                        $("#finalAcademic").show();

                    }
                    else
                        if (clicked_item_ID == '5') {
                            $("#formTitle").text(clicked_item);
                            $("#Current_Semester_Div").show();
                            $("#Section").show();
                            $("#widget_box_body").show();
                            $("#Not_Required_Reason_Div").show();
                            $("#widget_footer").show();
                            $("#widget_box_main").show();
                            $("#collegeIdCard").show();

                        }
                        else
                            if (clicked_item_ID == '6') {
                                $("#formTitle").text(clicked_item);
                                $("#Current_Semester_Div").show();
                                $("#Section").show();
                                $("#widget_box_body").show();
                                $("#Not_Required_Reason_Div").show();
                                $("#widget_footer").show();
                                $("#widget_box_main").show();
                                $("#vehicleToken").show();

                            }
                            else
                                if (clicked_item_ID == '7') {
                                    $("#formTitle").text(clicked_item);
                                    $("#fatherName").show();
                                    $("#Current_Semester_Div").show();
                                    $("#Section").show();
                                    $("#widget_box_body").show();
                                    $("#Not_Required_Reason_Div").show();
                                    $("#widget_footer").show();
                                    $("#widget_box_main").show();
                                    $("#receiptOfOriginal").show();

                                }
                                else
                                    if (clicked_item_ID == '8') {
                                        $("#formTitle").text(clicked_item);
                                        $("#Current_Semester_Div").show();
                                        $("#widget_box_body").show();
                                        $("#fatherName").show();
                                        $("#widget_footer").show();
                                        $("#Not_Required_Reason_Div").show();
                                        $("#widget_box_main").show();
                                        $("#bonafide").show();

                                    }
                                    else
                                        if (clicked_item_ID == '9') {
                                            $("#formTitle").text(clicked_item);
                                            $("#Current_Semester_Div").show();
                                            $("#widget_box_body").show();
                                            $("#Required_Reason_Div").show();
                                            $("#widget_footer").show();
                                            $("#widget_box_main").show();
                                            $("#semesterFreeze_Withdrawal").show();

                                        }
                                        else
                                            if (clicked_item_ID == '10') {
                                                $("#formTitle").text(clicked_item);
                                                $("#widget_box_body").show();
                                                $("#Not_Required_Reason_Div").show();
                                                $("#widget_footer").show();
                                                $("#widget_box_main").show();
                                                $("#semesterRejoin").show();

                                            }
                                            else
                                                if (clicked_item_ID == '11') {
                                                    $("#formTitle").text(clicked_item);
                                                    $("#fatherName").show();
                                                    $("#Current_Semester_Div").show();
                                                    $("#Section").show();
                                                    $("#widget_box_body").show();
                                                    $("#widget_footer").show();
                                                    $("#Not_Required_Reason_Div").show();
                                                    $("#widget_box_main").show();
                                                    $("#semesterAcademic").show();

                                                }
                                                else
                                                    if (clicked_item_ID == '12') {
                                                        $("#formTitle").text(clicked_item);
                                                        $("#Current_Semester_Div").show();
                                                        $("#Section").show();
                                                        $("#widget_box_main").show();
                                                        $("#courseWithdraw").show();
                                                        $("#widget_box_body").show();
                                                        $("#Not_Required_Reason_Div").show();
                                                        $("#widget_footer").show();
                                                    }
                                                    else
                                                        if (clicked_item_ID == '13') {
                                                            $("#formTitle").text(clicked_item);
                                                            $("#Current_Semester_Div").show();
                                                            $("#Section").show();
                                                            $("#widget_box_main").show();
                                                            $("#generalRequest").show();
                                                            $("#widget_box_body").show();
                                                            $("#Required_Reason_Div").show();
                                                            $("#widget_footer").show();
                                                        }

    }
    //function for hiding all the fields..
    function hideAll() {
        $("#Not_Required_Reason_Div").hide();
        $("#Required_Reason_Div").hide();
        $("#widget_box_main").hide();
        $("#clearanceForm").hide();
        $("#leaveForm").hide();
        $("#optionsForBsc").hide();
        $("#finalAcademic").hide();
        $("#collegeIdCard").hide();
        $("#vehicleToken").hide();
        $("#receiptOfOriginal").hide();
        $("#bonafide").hide();
        $("#semesterFreeze_Withdrawal").hide();
        $("#semesterRejoin").hide();
        $("#semesterAcademic").hide();
        $("#generalRequest").hide();
        $("#courseWithdraw").hide();
        $("#widget_box_body").hide();
        $("#widget_footer").hide();
        $("#fatherName").hide();
        $("#Current_Semester_Div").hide();
        $("#Section").hide();
        cleanErrorFields();
        cleanFields();
    }
    //clear red fields
    function cleanErrorFields() {
        $("#reason_result").text("");
        //clearnce
        $('#date_result').text("");      
        //leave
        $('#daterange_result_leave').text("");
        //$('#fnameLeave_result').text("");
        //finalAcad
        $('#PUreg_result_Acad').text("");
        $('#fyp_result_Acad').text("");
        //$('#finalAcademic_fname_result').text("");
        $('#Attachments_result_Acad').text("");
        //idCard
        $('#challan_result_ID').text("");
        $('#attach_result_ID').text("");
        $('#ID_result_date').text("");
        //$('#section_result_ID').text("");
        //bsc
        $('#bsc_PUreg_result').text("");
        $('#bsc_cnic_result').text("");
        $('#bsc_Attach_result').text("");
        //$('#bsc_fname_result').text("");
        $('#bsc_date_result').text("");
        //vehical
        $('#v_photo').text("");
        $('#v_register').text("");
        $('#v_IDcard').text("");
        $('#v_owner').text("");
        $('#v_manu').text("");
        $('#v_Reg').text("");
        $('#v_model').text("");
        //receipt
        $("#d_attach").text("");
        $("#d_doc").text("");
        //bonafide
        $("#b_gpa").text("");
        $("#b_reg").text("");
        $("#b_challan").text("");
        $("#b_attachC").text("");
        $("#b_fname").text("");
        //semesteracad
        $("#a_challan").text("");
        $('#a_challanForm').text("");
        $('#a_fname').text("");
        //rejoin
        $("#semester_rejoin").text("");
        //freeze
        $("#f_with").text("");
        //withdraw
        $('#course_result').text("");
        //general
        $('#semester_result').text("");
        $('#general_Subject_result').text("");
        $('#genera_A1').text("");
        $('#genera_A2').text("");
    }
    //clean fields
    function cleanFields() {
        $("#required_reason").text("");
        $("#not_required_reason").text("");
        document.getElementById("current_semester").value = $('#non').val();
        //clearnce
        $("#clearance_finalResultDate").val("");
        //leave
        $("#startDate").val("");
        $("#endDate").val("");
        //$("#Leave_fname").val("");
        //finalAcad
        $("#finalAcademic_PU").val("");
        $("#finalAcademic_FYPTitle").val("");
        $("#target_date_id").val("");
        $("#collegeIdCard_challan").val("");
        //bsc
        $("#optionsForBsc_CNIC").val("");
        $("#optionsForBsc_puReg").val("");
        $("#optionsForBsc_DOB").val("");
        //$("#optionsForBsc_fname").val("");
        //vehical
        //document.getElementById("vehicleToken_section").value = $('#non').val();
        $("#vehicle_model").val("");
        $("#vehicle_reason").val("");
        $("#vehicle_regNo").val("");
        $("#vehicle_manufacturer").val("");
        $("#vehicle_ownersName").val("");
        //receipt
        //$("#receiptOfOriginal_fname").val("");
        //document.getElementById("receiptOfOriginal_section").value = $('#non').val();
        //bonafide
        $("#bonafide_CGPA").val("");
        $("#bonafide_PuRegistration").val("");
        $("#bonafideChallan").val("");
        //$("#bonafide_fname").val("");
        //semesteracad
        //document.getElementById("semesterAcademic_section").value = $('#non').val();
        $('input[name=acadsemester]').attr('checked', false);
        $("#semesterAcademic_fname").val("");
        $("#semesterAcademic_challan").val("");
        //rejoin
        $('input[name=choose]').attr('checked', false);
        //freeze
        $('input[name=freeze]').attr('checked', false);
        //withdraw
        $("#code1").val("");
        $("#title1").val("");
        $("#cr1").val("");
        $("#code2").val("");
        $("#title2").val("");
        $("#cr2").val("");
        $("#code3").val("");
        $("#title3").val("");
        $("#cr3").val("");      
        //document.getElementById("course_section").value = $('#non').val();
        //general
        //document.getElementById("general_section").value = $('#non').val();
        $('#general_Subject').val("");
        $('#general_reason').val("");
        $('#general_Subject_result').val("");
        $('#Attachment1').val("");
        $('#Attachment2').val("");
    }
    //function for saving forms
    function checkSavedForm(title) {
        if (title == 'CLEARANCE FORM') {
            debugger;
            if (ValidateClearanceForm()) {
                SaveClearanceForm();
            }
        }
        else
            if (title == 'LEAVE APPLICATION FORM') {
                if (ValidateLeaveForm()) {
                    SaveLeaveForm();

                }
            }
            else
                if (title == 'OPTION FOR BSc DEGREE') {
                    if (ValidateBscForm()) {
                        SaveBscForm();
                    }
                }
                else
                    if (title == 'FINAL ACADAEMIC TRANSCRIPT FORM') {
                        if (ValidateFinalAcademicForm()) {
                            SaveFinalAcademicForm();
                        }
                    }
                    else
                        if (title == 'COLLEGE ID CARD FORM') {
                            if (ValidateIdCardForm()) {
                                SaveIdCardForm();
                            }
                        }
                        else
                            if (title == 'MOTORCYCLE TOKEN FORM') {
                                if (ValidateVehicalForm()) {
                                    SaveVehicalForm();
                                }

                            }
                            else
                                if (title == 'RECEIPT OF ORIGINAL EDUCATIONAL DOCUMENTS FORM') {
                                    if (ValidateReceiptOfOrignalDocumentForm()) {
                                        SaveReceiptOfOrignalDocumentForm();

                                    }
                                }
                                else
                                    if (title == 'BONAFIDE/CHARACTER CERTIFICATE FORM') {
                                        if (ValidateBonafideForm()) {
                                            SaveBonafideForm();
                                        }
                                    }
                                    else
                                        if (title == 'SEMESTER FREEZE/WITHDRAWAL FORM') {
                                            if (validateSemesterFreezeWithdrawForm()) {
                                                SaveSemesterFreezeForm();
                                            }

                                        }
                                        else
                                            if (title == 'SEMESTER RE-JOIN FORM') {
                                                if (validateSemesterRejoinForm()) {
                                                    SaveSemesterRejoinForm();
                                                }
                                            }
                                            else
                                                if (title == 'SEMESTER ACADAEMIC TRANSCRIPT FORM') {

                                                    if (validateSemesterAcadTranscriptForm()) {
                                                        SaveSemesterAcadTranscriptForm();

                                                    }
                                                }
                                                else if (title == 'COURSE(S) WITHDRAWAL FORM') {
                                                    if (validateWithDraw()) {
                                                        SaveCourseWithDrawal();
                                                    }
                                                }
                                                else if (title == 'GENERAL REQUEST FORM') {
                                                    if (validateGeneralRequest()) {
                                                        SaveGeneralRequest();
                                                    }
                                                }

    }
    //FormValidations
    function ValidateClearanceForm() {
        debugger;
        $('#date_result').text("");
        $('#reason_result').text("");
        var TargetDate = $("#clearance_finalResultDate").val();
        var Reason = $("#required_reason").val();
        var isValid = true;
        if (TargetDate == '') {
            $('#date_result').text("Please enter Final Result Date");
            $('#date_result').css("color", "red");
            isValid = false;
        }
        if (Reason == '') {
            $('#reason_result').text("Please enter reason");
            $('#reason_result').css("color", "red");
            isValid = false;
        }
        return isValid;
    }
    function ValidateLeaveForm() {
        debugger;
        $('#reason_result').text("");
        $('#semester_result').text("");
        $('#daterange_result_leave').text("");
        //$('#fnameLeave_result').text("");

        var startDate = $("#startDate").val();
        var endDate = $("#endDate").val();
        var TargetSemester = $('#current_semester').find(":selected").text();
        var TargetSemester = $("#current_semester").val();
        var Reason = $("#required_reason").val();
        //var fname = $("#Leave_fname").val();

        var isValid = true;

        if (Reason == '') {
            $('#reason_result').text("Please enter reason");
            $('#reason_result').css("color", "red");
            isValid = false;
        }
        //if (fname == '') {
        //    $('#fnameLeave_result').text("Please enter father's name");
        //    $('#fnameLeave_result').css("color", "red");
        //    isValid = false;
        //}
        debugger;
        //if (fname.length >= 3) {
        //    var patt1 = /[0-9.%+-]/g;
        //    var result = patt1.test(fname);
        //    if (result == true) {
        //        $('#fnameLeave_result').text("Please enter valid name");
        //        debugger;
        //        $('#fnameLeave_result').css("color", "red");
        //        isValid = false;
        //    }
        //}
        //else {
        //    $('#fnameLeave_result').text("Please enter valid name");
        //    $('#fnameLeave_result').css("color", "red");
        //    isValid = false;
        //}

        if (TargetSemester == '') {
            $('#semester_result').text("Please enter semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        } else
            if (TargetSemester > 8 || TargetSemester <= 0) {
                $('#semester_result').text("Please enter valid semester");
                $('#semester_result').css("color", "red");
                isValid = false;
            }
        if (startDate == '' && endDate == '') {
            $('#daterange_result_leave').text("Please enter leave duration");
            $('#daterange_result_leave').css("color", "red");
            isValid = false;
        } else if (startDate == '' && endDate != '') {
            $('#daterange_result_leave').text("Please enter start date for leave");
            $('#daterange_result_leave').css("color", "red");
            isValid = false;
        } else if (startDate > endDate) {
            $('#daterange_result_leave').text("Please enter valid date range for leave");
            $('#daterange_result_leave').css("color", "red");
            isValid = false;
        }

        return isValid;
    }
    function ValidateFinalAcademicForm() {
        debugger;
        $('#PUreg_result_Acad').text("");
        $('#fyp_result_Acad').text("");
        //$('#finalAcademic_fname_result').text("");
        $('#Attachments_result_Acad').text("");

        var isValid = true;
        var ClearanceCopy = $("#finalAcademicAttachment").get(0).files;

        if (!hasExtension('finalAcademicAttachment', ['.jpg', '.gif', '.png'])) {
            isValid = false;
            clearAttachment('finalAcademicAttachment');
        }

        if (ClearanceCopy.length == 0) {
            $('#Attachments_result_Acad').text("Please upload a valid file");
            $('#Attachments_result_Acad').css("color", "red");
        }

        var puReg = $("#finalAcademic_PU").val();
        var FYPTitle = $("#finalAcademic_FYPTitle").val();
        //var fname = $("#finalAcademic_fname").val();



        if (puReg != '') {
            var patt1 = /[1-9][0-9][0-9][0-9]_[A-Z][A-Z][A-Z]_[0-9][0-9][0-9]/g;
            var result = patt1.test(puReg);
            if (result == false) {
                $('#PUreg_result_Acad').text("Please enter valid PU registration number.");
                $('#PUreg_result_Acad').css("color", "red");
                isValid = false;
            }
        }
        if (FYPTitle == '') {
            $('#fyp_result_Acad').text("Please enter Final Year Project Title");
            $('#fyp_result_Acad').css("color", "red");
            isValid = false;
        }
        
        return isValid;
    }
    function ValidateIdCardForm() {
        debugger;
        $('#semester_result').text("");
        $('#challan_result_ID').text("");
        $('#attach_result_ID').text("");
        $('#ID_result_date').text("");
        //$('#section_result_ID').text("");
        var isValid = true;
        debugger;
        var Challan = $("#collegeIdCardAttachment").get(0).files;

        // Add the uploaded image content to the form data collection
        if (Challan.length == 0) {
            $('#attach_result_ID').text("Please upload a copy of paid challan form");
            $('#attach_result_ID').css("color", "red");
            isValid = false;
        }

        else if (Challan.length != 0 && !hasExtension('collegeIdCardAttachment', ['.jpg', '.gif', '.png'])) {
            $('#attach_result_ID').text("Please upload a valid file");
            $('#attach_result_ID').css("color", "red");
            isValid = false;
            clearAttachment('collegeIdCardAttachment');
        }

        var semesterNo = $("#current_semester").val();
        var ChallanNO = $("#collegeIdCard_challan").val();
        //var section = $("#collegeIdCard_section").val();
        var TargetDate = $("#target_date_id").val();

        if (TargetDate == '') {
            $('#ID_result_date').text("Please enter Date");
            $('#ID_result_date').css("color", "red");
            isValid = false;
        }
        if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        } else if (semesterNo == '') {
            $('#PUreg_result_Acad').text("Please enter semester");
            $('#PUreg_result_Acad').css("color", "red");
            isValid = false;
        }
        debugger
        if (ChallanNO != '') {
            var patt1 = /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9]/g;
            var result = patt1.test(ChallanNO);
            if (result == false) {
                $('#challan_result_ID').text("Please enter Valid  Challan no");
                $('#challan_result_ID').css("color", "red");
                isValid = false;
            }
        }
        return isValid;
    }
    function ValidateBscForm() {
        $('#semester_result').text("");
        $('#bsc_PUreg_result').text("");
        $('#bsc_cnic_result').text("");
        $('#bsc_Attach_result').text("");
        //$('#bsc_fname_result').text("");
        $('#bsc_date_result').text("");
        debugger;
        var isValid = true;
        var Father_CNIC = $("#applicantsFathersCnic").get(0).files;
        var Applicant_CNIC = $("#applicantsCnic").get(0).files;

        if (!hasExtension('applicantsFathersCnic', ['.jpg', '.gif', '.png'])) {
            clearAttachment('applicantsFathersCnic');
            isValid = false;
        }

        if (!hasExtension('applicantsCnic', ['.jpg', '.gif', '.png'])) {
            clearAttachment('applicantsCnic');
            isValid = false;
        }

        // Add the uploaded image content to the form data collection
        if (Father_CNIC.length == 0 && Applicant_CNIC.length == 0) {
            $('#bsc_Attach_result').text("Please upload valid files");
            $('#bsc_Attach_result').css("color", "red");
            isValid = false;
        }
        else
            if (Applicant_CNIC.length != 0 && Father_CNIC.length == 0) {
                $('#bsc_Attach_result').text("Please upload valid Father's CNIC");
                $('#bsc_Attach_result').css("color", "red");
                isValid = false;

            }
            else
                if (Applicant_CNIC.length == 0 && Father_CNIC.length != 0) {
                    $('#bsc_Attach_result').text("Please upload valid Applicant's CNIC");
                    $('#bsc_Attach_result').css("color", "red");
                    isValid = false;


                }

        var semesterNo = $("#current_semester").val();
        //var fname = $("#optionsForBsc_fname").val();
        var cnic = $("#optionsForBsc_CNIC").val();
        var puReg = $("#optionsForBsc_puReg").val();
        var DOB = $("#optionsForBsc_DOB").val();

        if (semesterNo == '') {
            $('#semester_result').text("Please enter semester number");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        else if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        if (puReg != '') {
            debugger;
            var patt1 = /[1-9][0-9][0-9][0-9]_[A-Z][A-Z][A-Z]_[0-9][0-9][0-9]/g;
            var result = patt1.test(puReg);
            if (result == false) {
                $('#bsc_PUreg_result').text("Please enter valid PU registration number.");
                $('#bsc_PUreg_result').css("color", "red");
                isValid = false;
            }
        }
        if (DOB == '') {
            $('#bsc_date_result').text("Please enter date of birth");
            $('#bsc_date_result').css("color", "red");
            isValid = false;
        }

        if (cnic == '') {
            $('#bsc_cnic_result').text("Please enter CNIC");
            $('#bsc_cnic_result').css("color", "red");
            isValid = false;
        }
        else {
            var patt1 = /^[0-9+]{5}-[0-9+]{7}-[0-9]{1}$/;
            var result = patt1.test(cnic);
            if (result == false) {
                $('#bsc_cnic_result').text("Please enter valid cnic");
                $('#bsc_cnic_result').css("color", "red");
                isValid = false;
            }
        }
        return isValid;

    }
    function ValidateVehicalForm() {
        $('#v_photo').text("");
        $('#v_register').text("");
        $('#v_IDcard').text("");
        $('#semester_result').text("");
        $('#v_owner').text("");
        $('#v_manu').text("");
        $('#v_Reg').text("");
        $('#v_model').text("");
        //$('#v_section').text("");
        debugger;
        var isValid = true;
        var Photo = $("#vehicle_photo").get(0).files;
        var Reg = $("#vehicle_registration").get(0).files;
        var IdCard = $("#vehicleIDcard").get(0).files;

        if (!hasExtension('vehicle_photo', ['.jpg', '.gif', '.png'])) {
            clearAttachment('vehicle_photo');
        }

        if (Photo.length == 0) {
            $('#v_photo').text("Please upload a valid file");
            $('#v_photo').css("color", "red");
            isValid = false;
        }

        if (!hasExtension('vehicle_registration', ['.jpg', '.gif', '.png'])) {
            clearAttachment('vehicle_registration');
        }

        if (Reg.length == 0) {
            $('#v_register').text("Please upload a valid file");
            $('#v_register').css("color", "red");
            isValid = false;

        }

        if (!hasExtension('vehicleIDcard', ['.jpg', '.gif', '.png'])) {
            clearAttachment('vehicleIDcard');
        }

        if (IdCard.length == 0) {
            $('#v_IDcard').text("Please upload a valid file");
            $('#v_IDcard').css("color", "red");
            isValid = false;

        }

        //getting fields from Form
        var Model = $("#vehicle_model").val();
        var regNum = $("#vehicle_regNo").val();
        var Manufacturer = $("#vehicle_manufacturer").val();
        var owner = $("#vehicle_ownersName").val();
      
        var semesterNo = $("#current_semester").val();

        if (semesterNo == '') {
            $('#semester_result').text("Please enter semester number");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        else if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        if (Model == '') {
            $('#v_model').text("Please enter Model");
            $('#v_model').css("color", "red");
            isValid = false;
        }
        else if (Model.length > 20) {
            $('#v_model').text("Please enter valid Model");
            $('#v_model').css("color", "red");
            isValid = false;
        }
        if (regNum == '') {
            $('#v_Reg').text("Please enter Registration Number");
            $('#v_Reg').css("color", "red");
            isValid = false;
        }
        else if (regNum.length > 20) {
            $('#v_Reg').text("Please enter valid Registration Number");
            $('#v_Reg').css("color", "red");
            isValid = false;
        }
        if (Manufacturer == '') {
            $('#v_manu').text("Please enter Manufacturer");
            $('#v_manu').css("color", "red");
            isValid = false;
        }
        else if (Manufacturer.length > 50) {
            $('#v_manu').text("Please enter valid  Manufacturer");
            $('#v_manu').css("color", "red");
            isValid = false;
        }
        if (owner == '') {
            $('#v_owner').text("Please enter Owner's Name");
            $('#v_owner').css("color", "red");
            isValid = false;
        }
        debugger;
        if (owner.length >= 3) {
            var patt1 = /[0-9.%+-]/g;
            var result = patt1.test(owner);
            if (result == true) {
                $('#v_owner').text("Please enter valid name");
                debugger;
                $('#v_owner').css("color", "red");
                isValid = false;
            }
        }
        else {
            $('#v_owner').text("Please enter valid name");
            $('#v_owner').css("color", "red");
            isValid = false;
        }
        return isValid

    }
    function ValidateReceiptOfOrignalDocumentForm() {
        $("#d_attach").text("");
        $("#d_doc").text("");
        $("#semester_result").text("");
        //$("#d_fname").text("");
        //$("#d_section").text("");
        var isValid = true;
        var semesterNo = $("#current_semester").val();
        var idCard = $("#receiptOfOriginalAttachment").get(0).files;

        if (!hasExtension('receiptOfOriginalAttachment', ['.jpg', '.gif', '.png'])) {
            clearAttachment('receiptOfOriginalAttachment');
        }
        //var section = $("#receiptOfOriginal_section").val();
        //var fname = $("#receiptOfOriginal_fname").val();

        if (semesterNo == '') {
            $('#semester_result').text("Please enter semester number");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        else if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }

        if (idCard.length == 0) {
            $("#d_attach").text("Please upload a valid file");
            $('#d_attach').css("color", "red");

            isValid = false;
        }
      
        if ($('#receiptOfOriginal_matric').is(":checked") == false && $('#receiptOfOriginal_bs').is(":checked") == false && $('#receiptOfOriginal_inter').is(":checked") == false) {
            $("#d_doc").text("Select the document you want to receive");
            $('#d_doc').css("color", "red");
            isValid = false;

        }
        return isValid;
    }
    function ValidateBonafideForm() {
        debugger;
        $("#b_gpa").text("");
        $("#b_reg").text("");
        $("#semester_result").text("");
        $("#b_challan").text("");
        $("#b_attachC").text("");
        $("#b_fname").text("");
        var isValid = true;
        var ChallanCopy = $("#bonafideAttachment").get(0).files;

        //getting fields from Form
        var semesterNo = $("#current_semester").val();
        var CGPA = $("#bonafide_CGPA").val();
        var PUreg = $("#bonafide_PuRegistration").val();
        var Challan = $("#bonafideChallan").val();
       
        if (semesterNo == '') {
            $('#semester_result').text("Please enter semester number");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        else if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        if (CGPA == '') {
            $('#b_gpa').text("Please enter CGPA");
            $('#b_gpa').css("color", "red");
            isValid = false;
        }
        var patt1 = /^[0]|[0-3]\.[0-9][0-9]|[4].[0][0]$/;
        var result = patt1.test(CGPA);
        if (result == false) {
            $('#b_gpa').text("Please enter valid CGPA");
            $('#b_gpa').css("color", "red");
            isValid = false;
        }
        if (PUreg != '') {
            debugger;
            var patt1 = /[1-9][0-9][0-9][0-9]_[A-Z][A-Z][A-Z]_[0-9][0-9][0-9]/g;
            var result = patt1.test(PUreg);
            if (result == false) {
                $('#b_reg').text("Please enter valid PU registration number.");
                $('#b_reg').css("color", "red");
                isValid = false;
            }
        }
        if ((semesterNo >= 1 && semesterNo < 8) && ChallanCopy.length == 0) {
            isValid = false;
            $("#b_attachC").text("Please attach copy of paid challan form If you are not in 8th semester");
            $('#b_attachC').css("color", "red");
        }
        if ((semesterNo >= 1 && semesterNo < 8) && Challan == '') {
            isValid = false;
            $("#b_challan").text("Please Enter Challan no");
            $('#b_challan').css("color", "red");
        }
        if ((semesterNo >= 1 && semesterNo < 8) && Challan != '') {

            var patt1 = /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9]/g;
            var result = patt1.test(Challan);
            if (result == false) {
                $('#b_challan').text("Please enter valid Challan no");
                $('#b_challan').css("color", "red");
                isValid = false;
            }
        }
        else if ((semesterNo >= 1 && semesterNo < 8) && !hasExtension('bonafideAttachment', ['.jpg', '.gif', '.png'])) {
            isValid = false;
            clearAttachment('bonafideAttachment');
        }

        //if (Challan == '') {
        //    $('#b_challan').text("Please Challan No.");
        //    $('#b_challan').css("color", "red");
        //    isValid = false;
        //}
        return isValid;
    }
    function validateSemesterAcadTranscriptForm() {
        $("#semester_result").text("");
        $("#a_challan").text("");
        $('#a_challanForm').text("");
        //$('#a_section').text("");
        $('#a_fname').text("");
        var isValid = true;
        debugger;
        var ChallanCopy = $("#semesterAcademic_reason_challan").get(0).files;

        if (!hasExtension('semesterAcademic_reason_challan', ['.jpg', '.gif', '.png'])) {
            clearAttachment('semesterAcademic_reason_challan');
        }

        if (ChallanCopy.length == 0) {
            $("#a_challanForm").text("Please upload a valid file");
            $('#a_challanForm').css("color", "red");
            isValid = false;
        }
        //getting fields from Form
        var semesterNo = $("#current_semester").val();
        //var section = $("#semesterAcademic_section").val();
        var Challan = $("#semesterAcademic_challan").val();
        var fname = $("#semesterAcademic_fname").val();
        if (fname == '') {
            $('#a_fname').text("Please enter father name");
            $('#a_fname').css("color", "red");
            isValid = false;
        }
        debugger;
        if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        } else if (semesterNo == '') {
            $('#semester_result').text("Please enter semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        if (Challan != '') {
            var patt1 = /[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9]/g;
            var result = patt1.test(Challan);
            if (result == false) {

                $('#a_challan').text("Please enter valid Challan no");
                $('#a_challan').css("color", "red");
                isValid = false;
            }
        }

        return isValid;
    }
    function validateSemesterRejoinForm() {
        $("#semester_rejoin").text("");

        var isValid = true;
        debugger;
        if ($("#semester_rejoin_1").is(':checked') == false && $("#semester_rejoin_2").is(':checked') == false && $("#semester_rejoin_3").is(':checked') == false && $("#semester_rejoin_4").is(':checked') == false && $("#semester_rejoin_5").is(':checked') == false && $("#semester_rejoin_6").is(':checked') == false && $("#semester_rejoin_7").is(':checked') == false && $("#semester_rejoin_8").is(':checked') == false) {
            isValid = false;
            $('#rejoin_sem').text("Please choose semester");
            $('#rejoin_sem').css("color", "red");
        }
        return isValid;
    }
    function validateSemesterFreezeWithdrawForm() {
        $("#semester_result").text("");
        $("#f_with").text("");
        $("#reason_result").text("");

        var isValid = true;
        debugger;

        //getting fields from Form
        var semesterNo = $("#current_semester").val();

        if ($("#semesterFreeze_Withdrawal_1").is(':checked') == false && $("#semesterFreeze_Withdrawal_2").is(':checked') == false && $("#semesterFreeze_Withdrawal_3").is(':checked') == false && $("#semesterFreeze_Withdrawal_4").is(':checked') == false && $("#semesterFreeze_Withdrawal_5").is(':checked') == false && $("#semesterFreeze_Withdrawal_6").is(':checked') == false && $("#semesterFreeze_Withdrawal_7").is(':checked') == false && $("#semesterFreeze_Withdrawal_8").is(':checked') == false) {
            isValid = false;
            $('#f_with').text("Please choose semester");
            $('#f_with').css("color", "red");
        }
        var reason = $("#required_reason").val();

        if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        } else if (semesterNo == '') {
            $('#semester_result').text("Please enter semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        if (reason == '') {
            $('#reason_result').text("Please enter reason");
            $('#reason_result').css("color", "red");
            isValid = false;
        }
        return isValid;
    }
    function validateWithDraw() {
        $('#course_result').text("");
        $('#semester_result').text("");
        //$('#course_section_result').text("");
        var i = 0;
        var courseStatus = true;
        var coursesList = [];
        var isValid = true;

        if ($("#code1").val() != "" && $("#title1").val() != "" && $("#cr1").val() != "") {
            var course1 = {
                CourseID: $("#code1").val(),
                CourseTitle: $("#title1").val(),
                CreditHours: $("#cr1").val()
            }
            coursesList[i] = course1;
            i++;

            if ($("#code1").val().length > 6) {
                $('#course_result').text("Please Enter Valid Course Code");
                $('#course_result').css("color", "red");
                $("#code1").focus();
                isValid = false;
            }
            else if ($("#title1").val().length < 2 || $("#title1").val().length > 30) {
                $('#course_result').text("Please Enter Valid Course Title");
                $('#course_result').css("color", "red");
                $("#title1").focus();
                isValid = false;
            }
            else if ($("#cr1").val() != '1' && $("#cr1").val() != '3') {
                $('#course_result').text("Please Enter Valid Credit Hours(1 OR 3)");
                $('#course_result').css("color", "red");
                $("#cr1").focus();
                isValid = false;
            }
        }
        if ($("#code2").val() != "" && $("#title2").val() != "" && $("#cr2").val() != "") {
            var course1 = {
                CourseID: $("#code2").val(),
                CourseTitle: $("#title2").val(),
                CreditHours: $("#cr2").val()
            }
            coursesList[i] = course1;
            i++;
            if ($("#code2").val().length > 6) {
                $('#course_result').text("Please Enter Valid Course Code");
                $('#course_result').css("color", "red");
                $("#code2").focus();
                isValid = false;
            }
            else if ($("#title2").val().length < 2 || $("#title1").val().length > 30) {
                $('#course_result').text("Please Enter Valid Course Title");
                $('#course_result').css("color", "red");
                $("#title2").focus();
                isValid = false;
            }
            else if ($("#cr2").val() != '1' && $("#cr2").val() != '3') {
                $('#course_result').text("Please Enter Valid Credit Hours(1 OR 3)");
                $('#course_result').css("color", "red");
                $("#cr2").focus();
                isValid = false;
            }
        }
        if ($("#code3").val() != "" && $("#title3").val() != "" && $("#cr3").val() != "") {
            var course1 = {
                CourseID: $("#code3").val(),
                CourseTitle: $("#title3").val(),
                CreditHours: $("#cr3").val()
            }
            coursesList[i] = course1;
            i++;
            if ($("#code3").val().length > 6) {
                $('#course_result').text("Please Enter Valid Course Code");
                $('#course_result').css("color", "red");
                $("#code3").focus();
                isValid = false;
            }
            else if ($("#title3").val().length < 2 || $("#title1").val().length > 30) {
                $('#course_result').text("Please Enter Valid Course Title");
                $('#course_result').css("color", "red");
                $("#title3").focus();
                isValid = false;
            }
            else if ($("#cr3").val() != '1' && $("#cr3").val() != '3') {
                $('#course_result').text("Please Enter Valid Credit Hours(1 OR 3)");
                $('#course_result').css("color", "red");
                $("#cr3").focus();
                isValid = false;
            }
        }
        if (coursesList.length == 0) {
            $('#course_result').text("Please enter proper course information");
            $('#course_result').css("color", "red");
            isValid = false;
        }
        var CurrentSemester = $("#current_semester").val();
        
        if (CurrentSemester == "") {
            $('#semester_result').text("Please enter current semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        else if (CurrentSemester > 8 || CurrentSemester <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('semester_result').css("color", "red");
            isValid = false;

        }
    
        return isValid;
    }
    function validateGeneralRequest() {
        debugger;
        cleanErrorFields();
        var isValid = true;
        var attach1_type = $("#Attachment1").val();
        var attach1 = $("#Attach1").get(0).files;
        var attach2_type = $("#Attachment2").val();
        var attach2 = $("#Attach2").get(0).files;

        if (!hasExtension('Attach1', ['.jpg', '.gif', '.png'])) {
            //alert("checked");
            clearAttachment('Attach1');
        }

        if (attach1_type != "" && attach1.length == 0) {
            $("#genera_A1").text("Please upload valid file");
            $('#genera_A1').css("color", "red");
            isValid = false;
        }
        else if (attach1_type == "" && attach1.length != 0) {
            $("#geneT_A1").text("Enter document name!");
            $('#geneT_A1').css("color", "red");
            isValid = false;
        }
        if (!hasExtension('Attach2', ['.jpg', '.gif', '.png'])) {
            //alert("checked");
            clearAttachment('Attach2');
        }
        if (attach2_type != "" && attach2.length == 0) {
            $("#genera_A2").text("Please upload valid file");
            $('#genera_A2').css("color", "red");
            isValid = false;
        }
        else if (attach2_type == "" && attach2.length != 0) {
            $("#geneT_A2").text("Enter document name!");
            $('#geneT_A2').css("color", "red");
            isValid = false;
        }

        //var Section = $("#general_section").val();
        var semesterNo = $("#current_semester").val();
        var subject = $("#general_Subject").val();
        var reason = $("#required_reason").val();

        //if (Section == null) {
        //    $('#general_section_result').text("Please enter section");
        //    $('#general_section_result').css("color", "red");
        //    isValid = false;
        //}

        if (semesterNo == '') {
            $('#semester_result').text("Please enter semester number");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        else if (semesterNo > 8 || semesterNo <= 0) {
            $('#semester_result').text("Please enter valid semester");
            $('#semester_result').css("color", "red");
            isValid = false;
        }
        if (subject == '') {
            $('#general_Subject_result').text("Please enter subject");
            $('#general_Subject_result').css("color", "red");
            isValid = false;
        }

        if (subject.length >= 2) {
            var patt1 = /[0-9.%+-]/g;
            var result = patt1.test(subject);
            if (result == true) {
                $('#general_Subject_result').text("Please enter valid subject");
                debugger;
                $('#general_Subject_result').css("color", "red");
                isValid = false;
            }
        }
        else {
            $('#general_Subject_result').text("Please enter valid subject");
            $('#general_Subject_result').css("color", "red");
            isValid = false;
        }
        if (reason == '') {
            $('#reason_result').text("Please enter reason");
            $('#reason_result').css("color", "red");
            isValid = false;
        }
        return isValid;
    }
    //Form Submission
    function SaveGeneralRequest() {
        debugger;
        var attach1_type = $("#Attachment1").val();
        var attach1 = $("#Attach1").get(0).files;
        var attach2_type = $("#Attachment2").val();
        var attach2 = $("#Attach2").get(0).files;

 
        var semesterNo = $("#current_semester").val();
        var subject = $("#general_Subject").val();
        var reason = $("#required_reason").val();
        var rollno = $("#rollNo").text();
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (attach1.length > 0) {
            data.append("Attachment1", attach1[0]);
        }
        if (attach2.length > 0) {
            data.append("Attachment2", attach2[0]);
        }

        //data.append("section", Section);
        data.append("semester", semesterNo);
        data.append("Reason", reason);
        data.append("subject", subject);
        data.append("roll", rollno);
        data.append("A1_type", attach1_type);
        data.append("A2_type", attach2_type);
        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveGeneralRequest",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                hideAll();
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });

    }
    function SaveClearanceForm() {
        debugger;
        var clearanceFormData = {
            RollNo: $("#rollNo").text(),
            TargetDate: $("#clearance_finalResultDate").val(),
            Reason:  $("#required_reason").val(),
            CategoryID: 1
        }

        var dataToSend = JSON.stringify(clearanceFormData);
        var url = "Forms/SaveClearanceForm";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('Successfully Submitted Form', Enums.MessageType.Success);
                showSuccessMsg(result.data);
                //window.location = 'ApplicationView/' + result.data;

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                hideAll();
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function SaveFinalAcademicForm() {
        var ClearanceCopy = $("#finalAcademicAttachment").get(0).files;
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (ClearanceCopy.length > 0) {
            data.append("ClearanceCopy", ClearanceCopy[0]);
        }

        var puReg = $("#finalAcademic_PU").val();
        var FYPTitle = $("#finalAcademic_FYPTitle").val();
        var reason = $("#not_required_reason").val();
        //var fname = $("#finalAcademic_fname").val();
        var rollno = $("#rollNo").text();

        data.append("PUreg", puReg);
        data.append("FYPTitle", FYPTitle);
        data.append("Reason", reason);
        //data.append("fname", fname);
        data.append("roll", rollno);

        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveFinalAcadTrans",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });
    }
    function SaveSemesterRejoinForm() {
        debugger;
        var semesterToRejoin;
        if ($("#semester_rejoin_1").is(':checked') == true) {
            semesterToRejoin = 1;
        } else if ($("#semester_rejoin_2").is(':checked') == true) {
            semesterToRejoin = 2;
        } else if ($("#semester_rejoin_3").is(':checked') == true) {
            semesterToRejoin = 3;
        } else if ($("#semester_rejoin_4").is(':checked') == true) {
            semesterToRejoin = 4;
        } else if ($("#semester_rejoin_5").is(':checked') == true) {
            semesterToRejoin = 5;
        } else if ($("#semester_rejoin_6").is(':checked') == true) {
            semesterToRejoin = 6;
        } else if ($("#semester_rejoin_7").is(':checked') == true) {
            semesterToRejoin = 7;
        } else if ($("#semester_rejoin_8").is(':checked') == true) {
            semesterToRejoin = 8;
        }
        var RejoinData = {
            RollNo: $("#rollNo").text(),
            TargetSemester: semesterToRejoin,
            Reason: $("#not_required_reason").val(),
            CategoryID: 10
        }
        var dataToSend = JSON.stringify(RejoinData);
        var url = "Forms/SaveSemesterRejoinForm";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                hideAll();
                //window.location = 'ApplicationView/' + result.data;
                showSuccessMsg(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                hideAll();
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }
    function SaveSemesterFreezeForm() {
        debugger;
        var data = new FormData();
        // Add the uploaded image content to the form data collection
        var semesterToFreeze;
        if ($("#semesterFreeze_Withdrawal_1").is(':checked') == true) {
            semesterToFreeze = 1;
        } else if ($("#semesterFreeze_Withdrawal_2").is(':checked') == true) {
            semesterToFreeze = 2;
        } else if ($("#semesterFreeze_Withdrawal_3").is(':checked') == true) {
            semesterToFreeze = 3;
        } else if ($("#semesterFreeze_Withdrawal_4").is(':checked') == true) {
            semesterToFreeze = 4;
        } else if ($("#semesterFreeze_Withdrawal_5").is(':checked') == true) {
            semesterToFreeze = 5;
        } else if ($("#semesterFreeze_Withdrawal_6").is(':checked') == true) {
            semesterToFreeze = 6;
        } else if ($("#semesterFreeze_Withdrawal_7").is(':checked') == true) {
            semesterToFreeze = 7;
        } else if ($("#semesterFreeze_Withdrawal_8").is(':checked') == true) {
            semesterToFreeze = 8;
        }
        //getting fields from Form
        var FreezeApplication = {
            CurrentSemester: $("#current_semester").find(":selected").text(),
            RollNo: $("#rollNo").text(),
            TargetSemester: semesterToFreeze,
            Reason:  $("#required_reason").val(),
            CategoryID: 9
        }
        var dataToSend = JSON.stringify(FreezeApplication);
        var url = "Forms/SaveSemesterFreezeForm";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage('Successfully Submitted Form', Enums.MessageType.Success);
                showSuccessMsg(result.data);
                hideAll();
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                hideAll();
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });
    }
    function SaveBonafideForm() {
        debugger;
        var ChallanCopy = $("#bonafideAttachment").get(0).files;
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (ChallanCopy.length > 0) {
            data.append("ChallanCopy", ChallanCopy[0]);
        }
    
        //getting fields from Form
        var semesterNo = $("#current_semester").find(":selected").text();
        var CGPA = $("#bonafide_CGPA").val();
        var reason = $("#not_required_reason").val();
        var rollno = $("#rollNo").text();
        var PUreg = $("#bonafide_PuRegistration").val();
        var Challan = $("#bonafideChallan").val();
        //var fname = $("#bonafide_fname").val();

        data.append("SemesterNo", semesterNo);
        data.append("CGPA", CGPA);
        data.append("Reason", reason);
        data.append("roll", rollno);
        data.append("PUreg", PUreg);
        data.append("Challan", Challan);
        //data.append("fname", fname);

        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveBonafideForm",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });

    }
    function SaveReceiptOfOrignalDocumentForm() {
        debugger;
        var documents = [];
        var i = 0;
        if ($('#receiptOfOriginal_matric').is(":checked") == true) {
            documents[i] = 'Matriculation Certificate';
            i = i + 1;
        }
        if ($('#receiptOfOriginal_inter').is(":checked") == true) {
            documents[i] = 'Intermediate Certificate';
            i = i + 1;
        }
        if ($('#receiptOfOriginal_bs').is(":checked") == true) {
            documents[i] = ' BSc Certifcate';
            i = i + 1;

        }
        var idCard = $("#receiptOfOriginalAttachment").get(0).files;
        var data = new FormData();
        // Add the uploaded image content to the form data collection
        if (idCard.length > 0) {
            data.append("idCard", idCard[0]);
        }
        debugger;
        var semester = $("#current_semester").find(":selected").text();
        var reason = $("#not_required_reason").val();
        var rollno = $("#rollNo").text();
        //var fname = $("#receiptOfOriginal_fname").val();
        //var section = $("#receiptOfOriginal_section").find(":selected").text();

        //data.append("fname", fname);
        //data.append("section", section);
        data.append("SemesterNo", semester);
        data.append("Reason", reason);
        data.append("roll", rollno);
        data.append("document", documents);
        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/receiptOfOriginal",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });
    }
    function SaveVehicalForm() {
        debugger;
        var Photo = $("#vehicle_photo").get(0).files;
        var Reg = $("#vehicle_registration").get(0).files;
        var IdCard = $("#vehicleIDcard").get(0).files;
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (Photo.length > 0) {
            data.append("Photo", Photo[0]);
        }
        if (Reg.length > 0) {
            data.append("Reg", Reg[0]);
        }
        if (IdCard.length > 0) {
            data.append("IdCard", IdCard[0]);
        }

        //getting fields from Form
        var semesterNo = $("#current_semester").find(":selected").text();
        var Model = $("#vehicle_model").val();
        var reason = $("#not_required_reason").val();
        var rollno = $("#rollNo").text();
        var regNum = $("#vehicle_regNo").val();
        var Manufacturer = $("#vehicle_manufacturer").val();
        var owner = $("#vehicle_ownersName").val();
        //var Section = $("#vehicleToken_section").find(":selected").text();
        data.append("SemesterNo", semesterNo);
        data.append("Model", Model);
        data.append("Reason", reason);
        data.append("roll", rollno);
        data.append("regNum", regNum);
        data.append("Manufacturer", Manufacturer);
        data.append("owner", owner);
        //data.append("section", Section);

        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveVehicalTokenForm",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });
    }
    function SaveIdCardForm() {
        debugger;
        var Challan = $("#collegeIdCardAttachment").get(0).files;
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (Challan.length > 0) {
            data.append("Challan", Challan[0]);
        }
        //var section = $("#collegeIdCard_section").find(":selected").text();
        var semesterNo = $("#current_semester").find(":selected").text();
        var ChallanNO = $("#collegeIdCard_challan").val();
        var reason = $("#not_required_reason").val();
        var rollno = $("#rollNo").text();

        data.append("SemesterNo", semesterNo);
        data.append("ChallanNO", ChallanNO);
        //data.append("section", section);
        data.append("Reason", reason);
        data.append("roll", rollno);

        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveIdCardForm",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });

    }
    function SaveSemesterAcadTranscriptForm() {
        debugger;
        var ChallanCopy = $("#semesterAcademic_reason_challan").get(0).files;
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (ChallanCopy.length > 0) {
            data.append("ChallanCopy", ChallanCopy[0]);
        }
        var TargetSemester;
        if ($("#semesterAcademic_semester1").is(':checked') == true) {
            TargetSemester = 1;
        } else if ($("#semesterAcademic_semester2").is(':checked') == true) {
            TargetSemester = 2;
        } else if ($("#semesterAcademic_semester3").is(':checked') == true) {
            TargetSemester = 3;
        } else if ($("#semesterAcademic_semester4").is(':checked') == true) {
            TargetSemester = 4;
        } else if ($("#semesterAcademic_semester5").is(':checked') == true) {
            TargetSemester = 5;
        } else if ($("#semesterAcademic_semester6").is(':checked') == true) {
            TargetSemester = 6;
        } else if ($("#semesterAcademic_semester7").is(':checked') == true) {
            TargetSemester = 7;
        } else if ($("#semesterAcademic_semester8").is(':checked') == true) {
            TargetSemester = 8;
        }

        //getting fields from Form
        var CurrentSemester = $("#current_semester").find(":selected").text();
        var reason = $("#not_required_reason").val();
        var rollno = $("#rollNo").text();
        var fname = $("#semesterAcademic_fname").val();
        //var section = $("#semesterAcademic_section").find(":selected").text();
        var Challan = $("#semesterAcademic_challan").val();
        data.append("Reason", reason);
        data.append("roll", rollno);
        data.append("Challan", Challan);
        data.append("current", CurrentSemester);
        data.append("fname", fname);
        //data.append("section", section);
        data.append("targetSemester", TargetSemester);
        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveSemesterAcadTranscriptForm",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });

    }
    function SaveBscForm() {
        var Father_CNIC = $("#applicantsFathersCnic").get(0).files;
        var Applicant_CNIC = $("#applicantsCnic").get(0).files;
        var data = new FormData();

        // Add the uploaded image content to the form data collection
        if (Father_CNIC.length > 0) {
            data.append("FatherCNIC", Father_CNIC[0]);
        }
        if (Applicant_CNIC.length > 0) {
            data.append("ApplicationCNIC", Applicant_CNIC[0]);
        }

        var semesterNo = $("#current_semester").find(":selected").text();
        var cnic = $("#optionsForBsc_CNIC").val();
        var puReg = $("#optionsForBsc_puReg").val();
        var DOB = $("#optionsForBsc_DOB").val();
        var reason = $("#not_required_reason").val();
        var rollno = $("#rollNo").text();
        //var fname = $("#optionsForBsc_fname").val();

        data.append("SemesterNo", semesterNo);
        data.append("CNIC", cnic);
        data.append("PUreg", puReg);
        data.append("DOB", DOB);
        data.append("Reason", reason);
        data.append("roll", rollno);
        //data.append("fname", fname);

        var ajaxRequest = $.ajax({
            type: "POST",
            url: window.MyWebAppBasePath + "aapi/Forms/SaveBScForm",
            contentType: false,
            processData: false,
            data: data,
            success: function (response) {
                debugger;
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
                //window.location = 'ApplicationView/' + response.data;

            },
            error: function (response) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        });

    }
    function SaveLeaveForm() {

        var leaveFormData = {
            leave: {
                startDate: $("#startDate").val(),
                endDate: $("#endDate").val()
            },
            request: {
                RollNo: $("#rollNo").text(),
                CurrentSemester: $('#current_semester').find(":selected").text(),
                Reason:  $("#required_reason").val(),
                CategoryID: 2
                //,FatherName: $("#Leave_fname").val()

            }
        }
        var dataToSend = JSON.stringify(leaveFormData);
        var url = "Forms/SaveLeaveForm";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                hideAll();
                showSuccessMsg(result.data);
                //window.location = 'ApplicationView/' + result.data;

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                hideAll();
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function SaveCourseWithDrawal() {
        var i = 0;
        var coursesList = [];
        if ($("#code1").val() != "" && $("#title1").val() != "" && $("#cr1").val() != "") {
            var course1 = {
                CourseID: $("#code1").val(),
                CourseTitle: $("#title1").val(),
                CreditHours: $("#cr1").val()
            }
            coursesList[i] = course1;
            i++;
        }
        if ($("#code2").val() != "" && $("#title2").val() != "" && $("#cr2").val() != "") {
            var course1 = {
                CourseID: $("#code2").val(),
                CourseTitle: $("#title2").val(),
                CreditHours: $("#cr2").val()
            }
            coursesList[i] = course1;
            i++;
        }
        if ($("#code3").val() != "" && $("#title3").val() != "" && $("#cr3").val() != "") {
            var course1 = {
                CourseID: $("#code3").val(),
                CourseTitle: $("#title3").val(),
                CreditHours: $("#cr3").val()
            }
            coursesList[i] = course1;
            i++;
        }

        var courseWithdraw = {
            course: coursesList,
            request: {
                RollNo: $("#rollNo").text(),
                CurrentSemester: $("#current_semester").find(":selected").text(),
                Reason: $("#not_required_reason").val(),
                CategoryID: 12
                //Section: $("#course_section").find(":selected").text()

            }
        }
        var dataToSend = JSON.stringify(courseWithdraw);
        var url = "Forms/SaveWithDraw";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                hideAll();
                showSuccessMsg(result.data);
                //window.location = 'ApplicationView/' + result.data;

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                hideAll();
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });
    }
    return {

        readyMain: function () {
            debugger;
            initialisePage();

        }
    };
}
());