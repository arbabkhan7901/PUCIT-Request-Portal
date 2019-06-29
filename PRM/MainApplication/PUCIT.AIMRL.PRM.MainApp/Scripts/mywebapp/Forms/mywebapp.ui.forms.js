
MyWebApp.namespace("UI.Forms");

MyWebApp.UI.Forms = (function () {
    "use strict";
    var _isInitialized = false;
    var formCategoryData;
    var clicked_item_ID;
    var clicked_item;
    var ApproverID1 = [];
    var ApproverID2 = [];
    var ApproverID3 = [];
    var name1 = [];
    var name2 = [];
    var name3 = [];
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            hideAll();
            debugger;
            getInstructions();
            FillDropDown();
            FillItemdropdown();
            FillHardwareItemDropdown();
            FillStoreItemDropDown();
            AutoFillDropDown();
            BindEvents();
        }
    }
    function BindEvents() {
        $("#clearance_check").change(function () {
            if ($(this).is(':checked')) {
                $("#attach_clearance").show();
            }
            else {
                $("#attach_clearance").hide();
            }
        });
        
        $("#uploadPicture").change(function (e) {
            debugger;
            e.preventDefault();
            //alert("hello");
            previewImage(this);
        });
        //Save Event
        $("#savedata").unbind('click').bind('click', function (e) {
            debugger;
            e.preventDefault();

            $('#SaveAlert').modal('show');
            //$.bsmodal.show("#SaveAlert");
            return false;
        });
        //modal alert events.
        $("#AlertModalClose").unbind("click").bind("click", function () {
            debugger;
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
            debugger;
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
            clicked_item_ID = $('#item_select').find(":selected").attr('id');
            clicked_item = $('#item_select').find(":selected").text();
            document.getElementById("item_select").value = $('#non').val();
            debugger;
            $("#title_formCategory").text(formCategoryData[clicked_item_ID - 1].Category);
            $("#instruction").text(formCategoryData[clicked_item_ID - 1].Instructions);

            $('#Note').modal('show');
        }); //End of Save Click

        $("#addItem").click(function () {
            cleanErrorFields();
            debugger;
            var item_selected = $('#general_item :selected').text();
            var quantity = $('#general_quantity').val();
            var itemId = $('#general_item').val();

            var items = $("#general_item").val();

            //quantity check
            if (items == null) {
                $('#select_item_result').text("Please select some items");
                $('#select_item_result').css("color", "red");
            }
           
            var decimal = /^[+]?[0-9]+\./;
            if (quantity.match(decimal) || quantity % 1 != 0 || quantity < 0) {
                $('#item_quantity').text("Please enter an integer value");
                $('#item_quantity').css("color", "red");
            }

            else if (quantity <= 0) {               
                $('#item_quantity').text("Please enter a valid value");
                $('#item_quantity').css("color", "red");
            }

            else if (items != null && quantity != "") {
                $('#selecteItemsTable').find('tbody')
                    .append($('<tr>').attr("itemId", itemId)
                .append($('<td>')
                    .append($('<b class="name">')
                    .text(item_selected)
                    )
                )
                .append($('<td>')
                    .append($('<b class="qty">')
                    .text(quantity)
                    )
                )

                .append($('<td>')
                    .append($('<i class="icon-minus-sign" >')
                    )
                )
                );

                $("#selecteItemsTable .icon-minus-sign").unbind("click").bind("click", function () {
                    $(this).closest("tr").remove();
                });
                $("#general_item")[0].selectedIndex = 0;
                document.getElementById("general_quantity").value = ""
                cleanErrorFields();
            }
        });


        $("#addvoucher").click(function () {
            debugger;
            cleanErrorFields();
            var item_selected = $('#voucher_items').val();
            var quantity = $('#demandQuantity').val();
            var itemId = $('#demanditems').val();
            var unit = "";

            if (item_selected == "") {
                $('#demand_item_result').text("Please enter a valid item");
                $('#demand_item_result').css("color", "red");
            }
            //quantity check
            var decimal = /^[+]?[0-9]+\./;
            if (quantity.match(decimal) || quantity % 1 != 0 || quantity <= 0) {
                $('#demand_quantity_result').text("Please enter a valid value");
                $('#demand_quantity_result').css("color", "red");
            }

            else if (item_selected != "" && quantity != "") {
                $('#demandvoucherTable').find('tbody')
                    .append($('<tr>').attr("itemId", itemId)
                .append($('<td>')
                    .append($('<b class="name">')
                    .text(item_selected)
                    )
                )
                .append($('<td>')
                    .append($('<b class="qty">')
                    .text(quantity)
                    )
                )
                .append($('<td>')
                    .append($('<i class="icon-minus-sign" >')
                    )
                )
                );
                debugger;
                $("#demandvoucherTable .icon-minus-sign").unbind("click").bind("click", function () {
                    $(this).closest("tr").remove();
                });
                document.getElementById("voucher_items").value = "";
                document.getElementById("demandQuantity").value = "";
                cleanErrorFields();
            }
        });

        $("#addStoreItem").click(function () {
            debugger;
            cleanErrorFields();
            var item_selected = $('#Store_Voucher_items :selected').text();
            var quantity = $('#storedemandQuantity').val();
            var itemId = $('#Store_Voucher_items').val();
            var unit = "";
            var items = $("#Store_Voucher_items").val();

            if (items == null) {
                $('#store_item_result').text("Please enter a valid item");
                $('#store_item_result').css("color", "red");
            }
            //quantity check
            var decimal = /^[+]?[0-9]+\./;
            if (quantity.match(decimal) || quantity % 1 != 0 || quantity <= 0) {
                $('#store_quantity').text("Please enter a valid value");
                $('#store_quantity').css("color", "red");
            }

            else if (items != null && quantity != "") {
                $('#storevoucherTable').find('tbody')
                    .append($('<tr>').attr("itemId", itemId)
                .append($('<td>')
                    .append($('<b class="name">')
                    .text(item_selected)
                    )
                )
                .append($('<td>')
                    .append($('<b class="qty">')
                    .text(quantity)
                    )
                )
                .append($('<td>')
                    .append($('<i class="icon-minus-sign" >')
                    )
                )
                );
                debugger;
                $("#storevoucherTable .icon-minus-sign").unbind("click").bind("click", function () {
                    $(this).closest("tr").remove();
                });
                $("#Store_Voucher_items")[0].selectedIndex = 0;
                document.getElementById("storedemandQuantity").value = "";
                cleanErrorFields();
            }
        });

        $("#addHardwareItem").click(function () {
            debugger;
            cleanErrorFields();
            var item_selected = $('#hardware_items :selected').text();
            var quantity = $('#Hardware_quantity').val();
            var itemId = $('#hardware_items').val();

            var items = $("#hardware_items").val();

            //quantity check
            if (items == null) {
                $('#select_hardware_result').text("Please select some items");
                $('#select_hardware_result').css("color", "red");
            }
            var decimal = /^[+]?[0-9]+\./;
            if (quantity % 1 != 0 || quantity <= 0) {
                $('#hardware_quantity').text("Please enter a valid value");
                $('#hardware_quantity').css("color", "red");
            }
           
            else if (items != null && quantity != "") {
                $('#hardwareTable').find('tbody')
                    .append($('<tr>').attr("itemId", itemId)

                .append($('<td>')
                    .append($('<b class="name">')
                    .text(item_selected)
                    )
                )
                .append($('<td>')
                    .append($('<b class="qty">')
                    .text(quantity)
                    )
                )
                .append($('<td>')
                    .append($('<i class="icon-minus-sign" >')
                    )
                )
                );

                $("#hardwareTable .icon-minus-sign").unbind("click").bind("click", function () {
                    $(this).closest("tr").remove();
                });
                $("#hardware_items")[0].selectedIndex = 0;
                document.getElementById("Hardware_quantity").value = ""
                cleanErrorFields();
            }
        });

        $("input:radio[name=choose]").unbind("click").bind("click", function () {
            if ($(this).val() == 1) {
                $("#purpose_initial").css("display", "block");
                $("#hw_reason").css("display", "block");
                $("#purpose_replacement").css("display", "none");
                $("#purpose_loss").css("display", "none");
            }
            if ($(this).val() == 2) {
                $("#purpose_replacement").css("display", "block");
                $("#hw_reason").css("display", "block");
                $("#purpose_initial").css("display", "none");
                $("#purpose_loss").css("display", "none");
            }
            if ($(this).val() == 3) {
                $("#purpose_loss").css("display", "block");
                $("#hw_reason").css("display", "block");
                $("#purpose_initial").css("display", "none");
                $("#purpose_replacement").css("display", "none");
            }
        });

        $("input:radio[name=lab_type]").unbind("click").bind("click", function () {
            if ($(this).val() == "per") {
                $("#permanent_div").css("display", "block");
                $("#temporary_div").css("display", "none");
            }
            else if ($(this).val() == "temp") {
                $("#temporary_div").css("display", "block");
                $("#permanent_div").css("display", "none");
            }
        });

    }
    
        function previewImage(input) {
            debugger;
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    // $("#uploadedPic").attr('display', 'block');
                    $("#uploadedPic").attr('src', e.target.result);
                }
            }
            reader.readAsDataURL(input.files[0]);
        }

        function hasExtension(inputID, exts) {
            var fileName = (document.getElementById(inputID).value).toLowerCase();
            return (new RegExp('(' + exts.join('|').replace(/\./g, '\\.') + ')$')).test(fileName);
        }

        function FillDropDown() {
            var url = "Forms/FillDropDown";
            MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
                if (result.success === true) {
                    debugger;
                    var forms = document.getElementById("item_select");
                    for (var i = 0; i < result.data.length; i++) {
                        var option = document.createElement("OPTION");
                        option.innerHTML = result.data[i].Category;
                        option.value = result.data[i].CategoryID;
                        option.setAttribute("id", result.data[i].CategoryID);
                        forms.options.add(option);
                    }
                } else {
                    MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
                }
            }, function (xhr, ajaxOptions, thrownError) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred while getting students: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
            });
        }

        function FillStoreItemDropDown() {
            debugger;
            var url = "Reports/getVoucherItemsName";
            var forms = document.getElementById("Store_Voucher_items");
            var option = document.createElement("OPTION");
            option.innerHTML = "Choose one";
            option.value = '0';
            option.setAttribute("id", 0);
            forms.options.add(option);
            $("#Store_Voucher_items option[value='0']").attr("disabled", "disabled");
            MyWebApp.Globals.MakeAjaxCall("GET", url, {}, function (result) {
                if (result != null) {
                    console.log(result);
                    for (var i = 0; i < result.data.length; i++) {
                        var option = document.createElement("OPTION");
                        option.innerHTML = result.data[i].ItemName;
                        option.value = result.data[i].ItemId;
                        option.setAttribute("id", result.data[i].ItemId);
                        forms.options.add(option);
                    }
                }
                else {
                    MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
                }
            }, function (xhr, ajaxOptions, thrownError) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);

            });

        }
        function FillItemdropdown() {
            var url = "Forms/getItemsName";
            var forms = document.getElementById("general_item");
            var option = document.createElement("OPTION");
            option.innerHTML = "Choose one";
            option.value = '0';
            option.setAttribute("id", 0);
            forms.options.add(option);
            $("#general_item option[value='0']").attr("disabled", "disabled");
            MyWebApp.Globals.MakeAjaxCall("GET", url, {}, function (result) {
                if (result.success === true) {
                    console.log(result);
                    for (var i = 0; i < result.data.length; i++) {
                        var option = document.createElement("OPTION");
                        option.innerHTML = result.data[i].ItemName;
                        option.value = result.data[i].ItemId;
                        option.setAttribute("id", result.data[i].ItemId);
                        forms.options.add(option);
                    }
                } else {
                    MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
                }
            }, function (xhr, ajaxOptions, thrownError) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
            });
        }


        function FillHardwareItemDropdown() {
            var url = "Forms/getHardwareItemsName";
            var forms = document.getElementById("hardware_items");
            var option = document.createElement("OPTION");
            option.innerHTML = "Choose one";
            option.value = '0';
            option.setAttribute("id", 0);
            forms.options.add(option);
            $("#hardware_items option[value='0']").attr("disabled", "disabled");
            MyWebApp.Globals.MakeAjaxCall("GET", url, {}, function (result) {
                if (result != null) {
                    console.log(result);
                    for (var i = 0; i < result.data.length; i++) {
                        var option = document.createElement("OPTION");
                        option.innerHTML = result.data[i].ItemName;
                        option.value = result.data[i].ItemId;
                        option.setAttribute("id", result.data[i].ItemId);
                        forms.options.add(option);
                    }
                }
                else {
                    MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
                }
            }, function (xhr, ajaxOptions, thrownError) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred while getting data: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
            });        
    }
    function AutoFillDropDown() {
        $("#tchr1").on("keyup", function () {
            var value = $(this).val();
            if (!value)
                return false;
            var url = "Forms/SearchContributor/?key=" + value;
            MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
                if (result != null) {
                    for (var i = 0; i < result.data.length; i++) {
                        var nam = result.data[i].NME;
                        var designation = result.data[i].Desg;
                        name1[i] = nam + " (" + designation + ")";
                        ApproverID1[i] = result.data[i].ID;
                    }
                    $("#tchr1").autocomplete({
                        source: name1
                    });
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            });
        });

        $("#tchr2").on("keyup", function () {
            var value = $(this).val();
            if (!value)
                return false;
            var url = "Forms/SearchContributor/?key=" + value;
            MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
                if (result != null) {
                    for (var i = 0; i < result.data.length; i++) {
                        var nam = result.data[i].NME;
                        var designation = result.data[i].Desg;
                        name2[i] = nam + " (" + designation + ")";
                        ApproverID2[i] = result.data[i].ID;
                    }
                    $("#tchr2").autocomplete({
                        source: name2
                    });
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            });
        });

        $("#tchr3").on("keyup", function () {
            var value = $(this).val();
            if (!value)
                return false;
            var url = "Forms/SearchContributor/?key=" + value;
            MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
                if (result != null) {
                    for (var i = 0; i < result.data.length; i++) {
                        var nam = result.data[i].NME;
                        var designation = result.data[i].Desg;
                        name3[i] = nam + " (" + designation + ")";
                        ApproverID3[i] = result.data[i].ID;
                    }
                    $("#tchr3").autocomplete({
                        source: name3
                    });
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            });
        });
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

                window.location = MyWebApp.Globals.baseURL + 'Home/Inbox';
                //$.bsmodal.hide("#SuccessMsg");
                //history.go(-1);
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
                $("#widget_footer").show();
                $("#clearanceForm").show();

            }
            else
                if (clicked_item_ID == '2') {
                    $("#formTitle").text(clicked_item);
                    $("#widget_box_body").show();
                    $("#widget_footer").show();
                    $("#widget_box_main").show();
                    $("#leaveForm").show();

                }
                else
                    if (clicked_item_ID == '3') {
                        $("#formTitle").text(clicked_item);
                        $("#widget_box_body").show();
                        $("#widget_footer").show();
                        $("#widget_box_main").show();
                        $("#optionsForBsc").show();

                    }
                    else
                        if (clicked_item_ID == '4') {
                            $("#formTitle").text(clicked_item);
                            $("#widget_box_body").show();
                            $("#widget_footer").show();
                            $("#widget_box_main").show();
                            $("#finalAcademic").show();

                        }
                        else
                            if (clicked_item_ID == '5') {
                                $("#formTitle").text(clicked_item);
                                $("#widget_box_body").show();
                                $("#widget_footer").show();
                                $("#widget_box_main").show();
                                $("#collegeIdCard").show();

                            }
                            else
                                if (clicked_item_ID == '6') {
                                    $("#formTitle").text(clicked_item);
                                    $("#widget_box_body").show();
                                    $("#widget_footer").show();
                                    $("#widget_box_main").show();
                                    $("#vehicleToken").show();

                                }
                                else
                                    if (clicked_item_ID == '7') {
                                        $("#formTitle").text(clicked_item);
                                        $("#widget_box_body").show();
                                        $("#widget_footer").show();
                                        $("#widget_box_main").show();
                                        $("#receiptOfOriginal").show();

                                    }
                                    else
                                        if (clicked_item_ID == '8') {
                                            $("#formTitle").text(clicked_item);
                                            $("#widget_box_body").show();
                                            $("#widget_footer").show();
                                            $("#widget_box_main").show();
                                            $("#bonafide").show();

                                        }
                                        else
                                            if (clicked_item_ID == '9') {
                                                $("#formTitle").text(clicked_item);
                                                $("#widget_box_body").show();
                                                $("#widget_footer").show();
                                                $("#widget_box_main").show();
                                                $("#semesterFreeze_Withdrawal").show();

                                            }
                                            else
                                                if (clicked_item_ID == '10') {
                                                    $("#formTitle").text(clicked_item);
                                                    $("#widget_box_body").show();
                                                    $("#widget_footer").show();
                                                    $("#widget_box_main").show();
                                                    $("#semesterRejoin").show();

                                                }
                                                else
                                                    if (clicked_item_ID == '11') {
                                                        $("#formTitle").text(clicked_item);
                                                        $("#widget_box_body").show();
                                                        $("#widget_footer").show();
                                                        $("#widget_box_main").show();
                                                        $("#semesterAcademic").show();

                                                    }
                                                    else
                                                        if (clicked_item_ID == '12') {
                                                            $("#formTitle").text(clicked_item);
                                                            $("#widget_box_main").show();
                                                            $("#courseWithdraw").show();
                                                            $("#widget_box_body").show();
                                                            $("#widget_footer").show();
                                                        }
                                                        else
                                                            if (clicked_item_ID == '13') {
                                                                $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#generalRequest").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                            }
                                                            else if (clicked_item_ID == '14') {
                                                                $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                                $("#demandForm").show();
                                                                FillItemdropdown();
                                                            }
                                                            else if (clicked_item_ID == '15') {
                                                                $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                                $("#hardwareForm").show();
                                                            }
                                                            else if (clicked_item_ID == '16') {
                                                                $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                                $("#demandvoucher").show();
                                                            }
                                                            else if (clicked_item_ID == '17') {
                                                                $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                                $("#storedemandvoucher").show();
                                                            }
                                 else if (clicked_item_ID == '18') {
                                                                $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                               $("#labReservationForm").show();
                                                            }
                                                            else if (clicked_item_ID == '19') {
                                                              $("#formTitle").text(clicked_item);
                                                                $("#widget_box_main").show();
                                                                $("#widget_box_body").show();
                                                                $("#widget_footer").show();
                                                              $("#roomReservation").show();
                                                            }

                                                           
        }
        //function for hiding all the fields..
        function hideAll() {
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
            $("#demandForm").hide();
            $("#demandvoucher").hide();
            $("#storedemandvoucher").hide();
            $("#hardwareForm").hide();
            $("#widget_box_body").hide();
            $("#widget_footer").hide();
            $("#labReservationForm").hide();
            $("#roomReservation").hide();
            cleanErrorFields();
            cleanFields();
        }
        //clear red fields
        function cleanErrorFields() {
            //clearnce
            $('#date_result').text("");
            $('#reason_result').text("");
            //leave
            $('#reason_result_leave').text("");
            $('#semester_result_leave').text("");
            $('#daterange_result_leave').text("");
            //$('#fnameLeave_result').text("");
            //finalAcad
            $('#PUreg_result_Acad').text("");
            $('#fyp_result_Acad').text("");
            //$('#finalAcademic_fname_result').text("");
            $('#Attachments_result_Acad').text("");
            //idCard
            $('#semester_result_ID').text("");
            $('#challan_result_ID').text("");
            $('#attach_result_ID').text("");
            $('#ID_result_date').text("");
            //$('#section_result_ID').text("");
            //bsc
            $('#bsc_semester_result').text("");
            $('#bsc_PUreg_result').text("");
            $('#bsc_cnic_result').text("");
            $('#bsc_Attach_result').text("");
            //$('#bsc_fname_result').text("");
            $('#bsc_date_result').text("");
            //vehical
            $('#v_photo').text("");
            $('#v_register').text("");
            $('#v_IDcard').text("");
            $('#v_semester').text("");
            $('#v_owner').text("");
            $('#v_manu').text("");
            $('#v_Reg').text("");
            $('#v_model').text("");
            //$('#v_section').text("");
            //receipt
            $("#d_attach").text("");
            $("#d_doc").text("");
            $("#d_semester").text("");
            //$("#d_fname").text("");
            //$("#d_section").text("");
            //bonafide
            $("#b_gpa").text("");
            $("#b_reg").text("");
            $("#b_sem").text("");
            $("#b_challan").text("");
            $("#b_attachC").text("");
            $("#b_fname").text("");
            //semesteracad
            $("#a_semester").text("");
            $("#a_challan").text("");
            $('#a_challanForm').text("");
            //$('#a_section').text("");
            $('#a_fname').text("");
            //rejoin
            $("#semester_rejoin").text("");
            //freeze
            $("#f_sem").text("");
            $("#f_with").text("");
            $("#F_rea").text("");
            //withdraw
            $('#course_result').text("");
            $('#course_semester_result').text("");
            //$('#course_section_result').text("");
            //general
            $('#general_semester_result').text("");
            //$('#general_section_result').text("");
            $('#general_Subject_result').text("");
            $('#general_reason_result').text("");
            $('#genera_A1').text("");
            $('#genera_A2').text("");

            //Item Demand
            $('#select_item_result').text("");
            $('#item_quantity').text("");
            $('#table_result').text("");
            $('#Itemtable_result').text("");
            $('#general_item_purpose_result').text("");

            //Hardaware Demand
            $('#select_hardware_result').text("");
            $('#hardware_quantity').text("");
            $('#hardware_table_result').text("");
            $('#hardwaretable_result').text("");
            $('#hardware_reason_result').text("");
            $('#reason_hw').text("");
            $('#replacement_reason_div').text("");
            $('#loss_reason_div').text("");

            //Demand Voucher
            $('#demand_item_result').text("");
            $('#demand_quantity_result').text("");
            $('#demand_reason_result').text("");
            $('#demand_table_result').text("");
            $('#demand_budget').text("");

            //Store Demand Vouchr
            $('#store_item_result').text("");
            $('#store_quantity').text("");
            $('#storevoucherTableResult').text("");
            $('#general_reason_result1').text("");
            $('#store_budget').text("");


            //Room Reservation Form
            $('#room_reservation_purpose_result').text("");
            $('#room_reservation_std_result').text("");
            $('#room_reservation_date_result').text("");
            $("#room_reservation_time_result").text("");


            //Lab Reservation
            $('#select_Lab_Type').text("");
            $('#course_title').text("");
            $('#no_computer').text("");
            $('#suggest_lab').text("");
                //Permanent
            $('#to_time').text("");
            $('#from_time').text("");
            $('#per_day').text("");
                //temporary
            $('#from_date_div').text("");
            $('#to_date_div').text("");
            $('#tempLab_from_div').text("");
            $('#tempLab_to_div').text("");
            
        }
        //clean fields
        function cleanFields() {
            //clearnce
            $("#clearance_finalResultDate").val("");
            $("#clearance_reason").val("");
            //leave
            document.getElementById("leave_semester").value = $('#leave_non').val();
            $("#startDate").val("");
            $("#endDate").val("");
            $("#leave_reason").val("");
            //$("#Leave_fname").val("");
            //finalAcad
            $("#finalAcademic_PU").val("");
            $("#finalAcademic_FYPTitle").val("");
            $("#finalAcademic_reason").val("");
            //$("#finalAcademic_fname").val("");
            //idCard
            //document.getElementById("collegeIdCard_section").value = $('#non').val();
            document.getElementById("collegeIdCard_semester").value = $('#college_non').val();
            $("#target_date_id").val("");
            $("#collegeIdCard_challan").val("");
            $("#collegeIdCard_reason").val("");
            //bsc
            document.getElementById("optionsForBsc_semester").value = $('#bsc_non').val();
            $("#optionsForBsc_CNIC").val("");
            $("#optionsForBsc_puReg").val("");
            $("#optionsForBsc_DOB").val("");
            $("#optionsForBsc_reason").val("");
            //$("#optionsForBsc_fname").val("");
            //vehical
            document.getElementById("vehicleToken_semester").value = $('#vehicle_non').val();
            //document.getElementById("vehicleToken_section").value = $('#non').val();
            $("#vehicle_model").val("");
            $("#vehicle_reason").val("");
            $("#vehicle_regNo").val("");
            $("#vehicle_manufacturer").val("");
            $("#vehicle_ownersName").val("");
            //receipt
            document.getElementById("receiptOfOriginal_semester").value = $('#original_non').val();
            $("#receiptOfOriginal_reason").val("");
            //$("#receiptOfOriginal_fname").val("");
            //document.getElementById("receiptOfOriginal_section").value = $('#non').val();
            //bonafide
            document.getElementById("bonafide_semester").value = $('#bonafied_non').val();
            $("#bonafide_CGPA").val("");
            $("#bonafide_reason").val("");
            $("#bonafide_PuRegistration").val("");
            $("#bonafideChallan").val("");
            //$("#bonafide_fname").val("");
            //semesteracad
            document.getElementById("semesterAcademic_semester").value = $('#academic_non').val();
            //document.getElementById("semesterAcademic_section").value = $('#non').val();
            $('input[name=acadsemester]').attr('checked', false);
            $("#semesterAcademic_reason").val("");
            $("#semesterAcademic_fname").val("");
            $("#semesterAcademic_challan").val("");
            //rejoin
            $("#semesterRejoin_reason").val("");
            $('input[name=choose]').attr('checked', false);
            //freeze
            document.getElementById("semesterFreeze_Withdrawal_semester").value = $('#freeze_non').val();
            $("#semesterFreeze_Withdrawal_reason").val("");
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
            $("#with_reason").val("");
            //document.getElementById("course_section").value = $('#non').val();
            document.getElementById("course_semester").value = $('#course_non').val();
            //general
            document.getElementById("general_semester").value = $('#general_non').val();
            //document.getElementById("general_section").value = $('#non').val();
            $('#general_Subject').val("");
            $('#general_reason').val("");
                     $('#general_Subject_result').val("");
            $('#general_reason_result').val("");
            $('#Attachment1').val("");
            $('#Attachment2').val("");
            debugger;
            //Item Demand
            $('#general_item option').remove();
            $('#general_quantity').val("");
            $('#general_item_purpose').val("");
            $('#selecteItemsTable tbody tr').remove();

            //Hardware Demand
           // $('#hardware_items option').remove();
            $('#Hardware_quantity').val("");
            $('#replacement_reason').val("");
            $('#loss_reason').val("");
            $('#hardwareTable tbody tr').remove();

            //Demand Voucher
            $('#voucher_items').val("");
            $('#demandQuantity').val("");
            $('#demand_reason').val("");
            $('#demandvoucherTable tbody tr').remove();

            //Store Demand Form
            //$('#Store_Voucher_items option').remove();
            $('#storedemandQuantity').val("");
            $('#general_reason1').val("");
            $('#storevoucherTable tbody tr').remove();

            //Lab Reservation
            $("#lab_courseTitle").val("");
            $("#lab_noComputer").val("");
            $("#lab_suggestLab").val("");
            $("#lab_perDay").val("");
            $("#lab_from").val("");
            $("#lab_to").val("");
            $("#lab_dateFrom").val("");
            $("#lab_dateTo").val("");
            $("#tempLab_from").val("");
            $("#tempLab_to").val("");
        }
        //function for saving forms
        function checkSavedForm(title) {
            if (title == 'Clearance Form') {
                debugger;
                if (ValidateClearanceForm()) {
                    SaveClearanceForm();
                }
            }
            else
                if (title == 'Leave Application Form') {
                    if (ValidateLeaveForm()) {
                        SaveLeaveForm();

                    }
                }
                else
                    if (title == 'Option for Bsc Degree Form') {
                        if (ValidateBscForm()) {
                            SaveBscForm();
                        }
                    }
                    else
                        if (title == 'Final Academic Transcript Form') {
                            if (ValidateFinalAcademicForm()) {
                                SaveFinalAcademicForm();
                            }
                        }
                        else
                            if (title == 'College ID Card Form') {
                                if (ValidateIdCardForm()) {
                                    SaveIdCardForm();
                                }
                            }
                            else
                                if (title == 'Vehical Token Form') {
                                    if (ValidateVehicalForm()) {
                                        SaveVehicalForm();
                                    }

                                }
                                else
                                    if (title == 'Reciept of Orignal Documents Form') {
                                        if (ValidateReceiptOfOrignalDocumentForm()) {
                                            SaveReceiptOfOrignalDocumentForm();
                                        }
                                    }
                                    else
                                        if (title == 'Bonafide Character Certificate Form') {
                                            if (ValidateBonafideForm()) {
                                                SaveBonafideForm();
                                            }
                                        }
                                        else
                                            if (title == 'Semester Freeze/Withdraw Form') {
                                                if (validateSemesterFreezeWithdrawForm()) {
                                                    SaveSemesterFreezeForm();
                                                }

                                            }
                                            else
                                                if (title == 'Semester Rejoin Form') {
                                                    if (validateSemesterRejoinForm()) {
                                                        SaveSemesterRejoinForm();
                                                    }
                                                }
                                                else
                                                    if (title == 'Semester Academic Transcript Form') {

                                                        if (validateSemesterAcadTranscriptForm()) {
                                                            SaveSemesterAcadTranscriptForm();

                                                        }
                                                    }
                                                    else if (title == 'Course Withdraw Form') {
                                                        if (validateWithDraw()) {
                                                            SaveCourseWithDrawal();
                                                        }
                                                    }
                                                    else if (title == 'General Request Form') {
                                                        if (validateGeneralRequest()) {
                                                            SaveGeneralRequest();
                                                        }
                                                    }
                                                    else if (title == 'Item Demand Requisition Form') {
                                                        debugger;
                                                        if (validateDemandForm()) {
                                                            SaveDemandForm();
                                                        }
                                                    }
                                                    else if (title == 'Hardware Request Form') {
                                                        if (validateHardwareForm()) {
                                                            SaveHardwareForm();
                                                        }
                                                    }
                                                    else if (title == 'Demand Voucher Form') {
                                                        if (validateVoucherForm()) {
                                                            SaveDemandVoucher();
                                                        }
                                                    }
                                                    else if (title == 'Store Demand Voucher Form') {
                                                        if (validateStoreForm()) {
                                                            SaveStoreDemandVoucher();
                                                        }
                                                    }

                                                    else if (title == 'Room Reservation Form') {
                                                        if (validateRoomReservationForm()) {
                                                            SaveRoomReservationForm();
                                                        }
                                                    }
                                                    else if (title == 'Lab Reservation Form') {
                                                        if (validateLabReservationForm()) {
                                                            SaveLabReservationForm();
                                                        }
                                                    }

        }
        //FormValidations
        function ValidateClearanceForm() {
            debugger;
            $('#date_result').text("");
            $('#reason_result').text("");
            $('#library_ID').text("");
            var TargetDate = $("#clearance_finalResultDate").val();
            var Reason = $("#clearance_reason").val();
            var pic = $("#uploadPicture").get(0).files;
            var libraryId = $("#clearance_libraryId").val();

            var isValid = true;
            if (!hasExtension('uploadPicture', ['.jpg', '.tif', '.png'])) {
                //alert("checked");
                clearAttachment('uploadPicture');
            }

            if (pic.length == 0) {
                $("#genera_A1").text("Please upload valid file");
                $('#genera_A1').css("color", "red");
                isValid = false;
            }
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

            if (libraryId == '') {
                $('#library_ID').text("Please enter Library ID");
                $('#library_ID').css("color", "red");
                isValid = false;
            }

            return isValid;
        }
        function ValidateLeaveForm() {
            debugger;
            $('#reason_result_leave').text("");
            $('#semester_result_leave').text("");
            $('#daterange_result_leave').text("");

            var startDate = $("#startDate").val();
            var endDate = $("#endDate").val();
            var TargetSemester = $('#leave_semester').find(":selected").text();
            var TargetSemester = $("#leave_semester").val();
            var Reason = $("#leave_reason").val();

            var isValid = true;

            if (Reason == '') {
                $('#reason_result_leave').text("Please enter reason");
                $('#reason_result_leave').css("color", "red");
                isValid = false;
            }

            if (TargetSemester == '') {
                $('#semester_result_leave').text("Please enter semester");
                $('#semester_result_leave').css("color", "red");
                isValid = false;
            } else
                if (TargetSemester > 8 || TargetSemester <= 0) {
                    $('#semester_result_leave').text("Please enter valid semester");
                    $('#semester_result_leave').css("color", "red");
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
            $('#semester_result_ID').text("");
            $('#challan_result_ID').text("");
            $('#attach_result_ID').text("");
            $('#ID_result_date').text("");
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

            var semesterNo = $("#collegeIdCard_semester").val();
            var ChallanNO = $("#collegeIdCard_challan").val();
            var TargetDate = $("#target_date_id").val();

            if (TargetDate == '') {
                $('#ID_result_date').text("Please enter Date");
                $('#ID_result_date').css("color", "red");
                isValid = false;
            }
            if (semesterNo > 8 || semesterNo <= 0) {
                $('#semester_result_ID').text("Please enter valid semester");
                $('#semester_result_ID').css("color", "red");
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
            $('#bsc_semester_result').text("");
            $('#bsc_PUreg_result').text("");
            $('#bsc_cnic_result').text("");
            $('#bsc_Attach_result').text("");
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

            var semesterNo = $("#optionsForBsc_semester").val();
            var cnic = $("#optionsForBsc_CNIC").val();
            var puReg = $("#optionsForBsc_puReg").val();
            var DOB = $("#optionsForBsc_DOB").val();
            debugger;
            var todayDate = new Date();
            //var dd = todayDate.getDate();
            //var mm = todayDate.getMonth() + 1;
            //var yyyy = todayDate.getFullYear();
            //if (dd < 10) {
            //    dd = '0' + dd
            //}
            //if (mm < 10) {
            //    mm = '0' + mm
            //}

            //todayDate = mm + '-' + dd + '-' + yyyy;
            //var a = Date.parse(DOB);
            //var b = Date.parse(todayDate);
            if (Date.parse(DOB) >=Date.parse(todayDate)) {
                $('#bsc_date_result').text("Please enter a valid Date");
                $('#bsc_date_result').css("color", "red");
                isValid = false;
            }
        
            if (semesterNo == '') {
                $('#bsc_semester_result').text("Please enter semester number");
                $('#bsc_semester_result').css("color", "red");
                isValid = false;
            }
            else if (semesterNo > 8 || semesterNo <= 0) {
                $('#bsc_semester_result').text("Please enter valid semester");
                $('#bsc_semester_result').css("color", "red");
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
            $('#v_semester').text("");
            $('#v_owner').text("");
            $('#v_manu').text("");
            $('#v_Reg').text("");
            $('#v_model').text("");
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
            var semesterNo = $("#vehicleToken_semester").val();

            if (semesterNo == '') {
                $('#v_semester').text("Please enter semester number");
                $('#v_semester').css("color", "red");
                isValid = false;
            }
            else if (semesterNo > 8 || semesterNo <= 0) {
                $('#v_semester').text("Please enter valid semester");
                $('#v_semester').css("color", "red");
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
            $("#d_semester").text("");
        
            var isValid = true;
            var semesterNo = $("#receiptOfOriginal_semester").val();
            var idCard = $("#collegeIdCard_attach").get(0).files;
            debugger;
            if ($('#clearance_check').is(":checked")) {
                var clearance = $("#clearanceForm_attach").get(0).files;
                if (!hasExtension('clearanceForm_attach', ['.jpg', '.pdf', '.png'])) {
                    clearAttachment('clearanceForm_attach');
                }
                if (clearance.length == 0) {
                    $("#d_clearanceForm_attach").text("Please upload a valid file");
                    $('#d_clearanceForm_attach').css("color", "red");
                    isValid = false;
                }
            }

          

            if (!hasExtension('collegeIdCard_attach', ['.jpg', '.gif', '.png'])) {
                clearAttachment('collegeIdCard_attach');
            }
      

            if (semesterNo == '') {
                $('#d_semester').text("Please enter semester number");
                $('#d_semester').css("color", "red");
                isValid = false;
            }
            else if (semesterNo > 8 || semesterNo <= 0) {
                $('#d_semester').text("Please enter valid semester");
                $('#d_semester').css("color", "red");
                isValid = false;
            }

            if (idCard.length == 0) {
                $("#d_collegeIdCard_attach").text("Please upload a valid file");
                $('#d_collegeIdCard_attach').css("color", "red");

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
            $("#b_sem").text("");
            $("#b_challan").text("");
            $("#b_attachC").text("");
            $("#b_fname").text("");
            var isValid = true;
            var ChallanCopy = $("#bonafideAttachment").get(0).files;

            //getting fields from Form
            var semesterNo = $("#bonafide_semester").val();
            var CGPA = $("#bonafide_CGPA").val();
            var PUreg = $("#bonafide_PuRegistration").val();
            var Challan = $("#bonafideChallan").val();
        
            if (semesterNo == '') {
                $('#b_sem').text("Please enter semester number");
                $('#b_sem').css("color", "red");
                isValid = false;
            }
            else if (semesterNo > 8 || semesterNo <= 0) {
                $('#b_sem').text("Please enter valid semester");
                $('#b_sem').css("color", "red");
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

       
            return isValid;
        }
        function validateSemesterAcadTranscriptForm() {
            $("#a_semester").text("");
            $("#a_challan").text("");
            $('#a_challanForm').text("");
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
            var semesterNo = $("#semesterAcademic_semester").val();
            //var section = $("#semesterAcademic_section").val();
            var Challan = $("#semesterAcademic_challan").val();
            var fname = $("#semesterAcademic_fname").val();
            if (fname == '') {
                $('#a_fname').text("Please enter father name");
                $('#a_fname').css("color", "red");
                isValid = false;
            }

            if (semesterNo > 8 || semesterNo <= 0) {
                $('#a_semester').text("Please enter valid semester");
                $('#a_semester').css("color", "red");
                isValid = false;
            } else if (semesterNo == '') {
                $('#a_semester').text("Please enter semester");
                $('#a_semester').css("color", "red");
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
            $("#f_sem").text("");
            $("#f_with").text("");
            $("#F_rea").text("");

            var isValid = true;
            debugger;

            //getting fields from Form
            var semesterNo = $("#semesterFreeze_Withdrawal_semester").val();

            if ($("#semesterFreeze_Withdrawal_1").is(':checked') == false && $("#semesterFreeze_Withdrawal_2").is(':checked') == false && $("#semesterFreeze_Withdrawal_3").is(':checked') == false && $("#semesterFreeze_Withdrawal_4").is(':checked') == false && $("#semesterFreeze_Withdrawal_5").is(':checked') == false && $("#semesterFreeze_Withdrawal_6").is(':checked') == false && $("#semesterFreeze_Withdrawal_7").is(':checked') == false && $("#semesterFreeze_Withdrawal_8").is(':checked') == false) {
                isValid = false;
                $('#f_with').text("Please choose semester");
                $('#f_with').css("color", "red");
            }
            var reason = $("#semesterFreeze_Withdrawal_reason").val();

            if (semesterNo > 8 || semesterNo <= 0) {
                $('#f_sem').text("Please enter valid semester");
                $('#f_sem').css("color", "red");
                isValid = false;
            } else if (semesterNo == '') {
                $('#f_sem').text("Please enter semester");
                $('#f_sem').css("color", "red");
                isValid = false;
            }
            if (reason == '') {
                $('#F_rea').text("Please enter reason");
                $('#F_rea').css("color", "red");
                isValid = false;
            }
            return isValid;
        }
        function validateWithDraw() {
            $('#course_result').text("");
            $('#course_semester_result').text("");
            var i = 0;
            var courseStatus = true;
            var coursesList = [];
            var isValid = true;

            if ($("#code1").val() != "" && $("#title1").val() != "" && $("#cr1").val() != "" && $("#tchr1").val() != "") {
                var course1 = {
                    CourseID: $("#code1").val(),
                    CourseTitle: $("#title1").val(),
                    CreditHours: $("#cr1").val(),
                    TeacherName: $("#tchr1").val()

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
                else if ($("#tchr1").val().length < 2 || $("#tchr1").val().length > 50) {
                    $('#course_result').text("Please Enter Valid Teacher Name");
                    $('#course_result').css("color", "red");
                    $("#tchr1").focus();
                    isValid = false;
                }
            }
            if ($("#code2").val() != "" && $("#title2").val() != "" && $("#cr2").val() != "" && $("#tchr2").val() != "") {
                var course1 = {
                    CourseID: $("#code2").val(),
                    CourseTitle: $("#title2").val(),
                    CreditHours: $("#cr2").val(),
                    TeacherName: $("#tchr2").val()
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
                else if ($("#tchr2").val().length < 2 || $("#tchr2").val().length > 50) {
                    $('#course_result').text("Please Enter Valid Teacher Name");
                    $('#course_result').css("color", "red");
                    $("#tchr2").focus();
                    isValid = false;
                }
            }
            if ($("#code3").val() != "" && $("#title3").val() != "" && $("#cr3").val() != "" && $("#tchr3").val() != "") {
                var course1 = {
                    CourseID: $("#code3").val(),
                    CourseTitle: $("#title3").val(),
                    CreditHours: $("#cr3").val(),
                    TeacherName: $("#tchr3").val()

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
                else if ($("#tchr3").val().length < 2 || $("#tchr3").val().length > 50) {
                    $('#course_result').text("Please Enter Valid Teacher Name");
                    $('#course_result').css("color", "red");
                    $("#tchr3").focus();
                    isValid = false;
                }
            }
            if (coursesList.length == 0) {
                $('#course_result').text("Please enter proper course information");
                $('#course_result').css("color", "red");
                isValid = false;
            }
            var CurrentSemester = $("#course_semester").val();
            //var Section = $("#course_section").val();
            if (CurrentSemester == "") {
                $('#course_semester_result').text("Please enter current semester");
                $('#course_semester_result').css("color", "red");
                isValid = false;
            }
            else if (CurrentSemester > 8 || CurrentSemester <= 0) {
                $('#course_semester_result').text("Please enter valid semester");
                $('#course_semester_result').css("color", "red");
                isValid = false;

            }
            var temp1 = $("#tchr1").val();
            var temp1_ID = null;
            for (var i = 0; i < name1.length; i++) {
                if (name1[i] == temp1) {
                    temp1_ID = ApproverID1[i];
                }
                else if (temp1_ID == null)
                    temp1_ID = 0;
            }
            var temp2 = $("#tchr2").val();
            var temp2_ID = null;
            for (var i = 0; i < name2.length; i++) {
                if (name2[i] == temp2) {
                    temp2_ID = ApproverID2[i];
                }
                else if (temp2_ID == null)
                    temp2_ID = 0;
            }
            var temp3 = $("#tchr3").val();
            var temp3_ID = null;
            for (var i = 0; i < name3.length; i++) {
                if (name3[i] == temp3) {
                    temp3_ID = ApproverID3[i];
                }
                else if (temp3_ID == null)
                    temp3_ID = 0;
            }
            if (temp1_ID == 0 || temp2_ID == 0 || temp3_ID == 0) {
                $('#course_result').text("Please Enter Valid Teacher Name");
                $('#course_result').css("color", "red");
                isValid = false;
            }
       
            return isValid;
        }
        function validateGeneralRequest() {
            cleanErrorFields();
            var isValid = true;
            var attach1_type = $("#Attachment1").val();
            var attach1 = $("#Attach1").get(0).files;
            var attach2_type = $("#Attachment2").val();
        
            var attach2 = $("#Attach2").get(0).files;

            if (!hasExtension('Attach1', ['.jpg', '.gif', '.png'])) {
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
            var semesterNo = $("#general_semester").val();
            var subject = $("#general_Subject").val();
            var reason = $("#general_reason").val();

            if (semesterNo == '') {
                $('#general_semester_result').text("Please enter semester number");
                $('#general_semester_result').css("color", "red");
                isValid = false;
            }
            else if (semesterNo > 8 || semesterNo <= 0) {
                $('#general_semester_result').text("Please enter valid semester");
                $('#general_semester_result').css("color", "red");
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
                $('#general_reason_result').text("Please enter reason");
                $('#general_reason_result').css("color", "red");
                isValid = false;
            }
            return isValid;
        }
        function validateStoreForm() {
            debugger;
            cleanErrorFields();
            var tab = $("#storevoucherTable tbody");
            var rb = $('#Regular1:checked').val() ? true : false;
            var ss = $('#Self1:checked').val() ? true : false;
            var cf = $('#CollegeFund1:checked').val() ? true : false;
            var isValid = true;
            if (tab.children().length == 0) {
                $('#storevoucherTableResult').text("Please select some items");
                $('#storevoucherTableResult').css("color", "red");
                isValid = false;
            }
            if (rb == false && ss == false && cf == false) {
                $('#store_budget').text("Please select some budget");
                $('#store_budget').css("color", "red");
                isValid = false;
            }

            $('#general_reason1').text("");
            var Reason = $("#general_reason1").val();
            if (Reason == '') {
                $('#general_reason_result1').text("Please Enter Purpose");
                $('#general_reason_result1').css("color", "red");
                isValid = false;
            }
            return isValid;
        }
        function validateVoucherForm() {
            debugger;
            cleanErrorFields();
            var tab = $("#demandvoucherTable tbody");
            var rb = $('#Regular:checked').val() ? true : false;
            var ss = $('#Self:checked').val() ? true : false;
            var cf = $('#CollegeFund:checked').val() ? true : false;
            var isValid = true;
            if (tab.children().length == 0) {
                $('#demand_table_result').text("Please select some items");
                $('#demand_table_result').css("color", "red");
                isValid = false;
            }
            if (rb == false && ss == false && cf == false) {
                $('#demand_budget').text("Please select some budget");
                $('#demand_budget').css("color", "red");
                isValid = false;
            }

            $('#demand_reason').text("");
            var Reason = $("#demand_reason").val();
            if (Reason == '') {
                $('#demand_reason_result').text("Please Enter Purpose");
                $('#demand_reason_result').css("color", "red");
                isValid = false;
            }
            return isValid;
        }

        function validateDemandForm() {
            cleanErrorFields();
            var tab = $("#selecteItemsTable tbody");
            var isValid = true;
            if (tab.children().length == 0) {
                $('#Itemtable_result').text("Please select some items");
                $('#Itemtable_result').css("color", "red");
                isValid = false;
            }
            var Reason = $("#general_item_purpose").val();       
            if (Reason == '') {
                $('#general_item_purpose_result').text("Please Enter Purpose");
                $('#general_item_purpose_result').css("color", "red");
                isValid = false;
            }
            return isValid;
        }

        function validateHardwareForm() {
            cleanErrorFields();
            var tab = $("#hardwareTable tbody");
            var isValid = true;
            if (tab.children().length == 0) {
                $('#hardwaretable_result').text("Please select some items");
                $('#hardwaretable_result').css("color", "red");
                isValid = false;
            }
            if ($("#hwInitial").is(':checked') == false && $("#hwReplacement").is(':checked') == false & $("#hwLoss").is(':checked') == false) {
                isValid = false;
                $('#reason_hw').text("Reason is required");
                $('#reason_hw').css("color", "red");
            }
            var Reason = $("#hw_reason").val();
            if (Reason == '') {
                 $('#reason_div').text("Please Enter Purpose");
                 $('#reason_div').css("color", "red");
                 isValid = false;
             }
            return isValid;
        }
        function validateRoomReservationForm()
        {
            cleanErrorFields();
            var isValid = true;
            //CheckEmpty Fields
            var Reason = $("#room_reservation_purpose").val();
            if (Reason == '') {
                $('#room_reservation_purpose_result').text("Please Enter Purpose");
                $('#room_reservation_purpose_result').css("color", "red");
                $("#room_reservation_purpose").focus();
                isValid = false;
            }
            var total_std = $("#roomRes_Stds").val();
            if (total_std == "")
            {
                $('#room_reservation_std_result').text("Please Enter Total Strength");
                $('#room_reservation_std_result').css("color", "red");
                $("#roomRes_Stds").focus();

                isValid = false;
            }
           
            //CheckDate
            var DOB = $("#roomRes_Date").val();
            if (DOB == "") {
                $('#room_reservation_date_result').text("Please Enter a Date");
                $('#room_reservation_date_result').css("color", "red");
                $("#roomRes_Date").focus();

                isValid = false;
            }
            var todayDate = new Date();
            var dd = todayDate.getDate();
            var mm = todayDate.getMonth() + 1;
            var yyyy = todayDate.getFullYear();
            if (dd < 10) {
                dd = '0' + dd
            }
            if (mm < 10) {
                mm = '0' + mm
            }
            todayDate = mm + '-' + dd + '-' + yyyy;
            if (DOB < todayDate) {
                $('#room_reservation_date_result').text("Please Enter a valid Date");
                $('#room_reservation_date_result').css("color", "red");
                $("#roomRes_Date").focus();
                isValid = false;
            }
            //CheckTime
            var perFrom = $("#roomRes_fromTime").val();
            var perTo = $("#roomRes_toTime").val();
            if (perFrom == '' || perTo == '')
            {
                $("#room_reservation_time_result").text("Select Time Properly");
                $("#room_reservation_time_result").css("color", "red");
                $("#roomRes_fromTime").focus();

                isValid = false;
            }
            if (Date.parse(perFrom) > Date.parse(perTo)) {
                $("#room_reservation_time_result").text("Start time can't be greater than end time");
                $("#room_reservation_time_result").css("color", "red");
                $("#roomRes_fromTime").focus();
                isValid = false;
            }

            return isValid;
        }

        function validateLabReservationForm() {
            cleanErrorFields();
            var isValid = true;
            var courseTitle = $("#lab_courseTitle").val();
            var noOfComp = $("#lab_noComputer").val();
            var suggustedLab = $("#lab_suggestLab").val();

            if (courseTitle == '') {
                $("#course_title").text('Enter Course title');
                $("#course_title").css("color", "red");
                isValid = false;
            }
            if (noOfComp == '') {
                $("#no_computer").text('Enter no. of Computers');
                $("#no_computer").css("color", "red");
                isValid = false;
            }
            if (suggustedLab == '') {
                $("#suggest_lab").text('Enter Lab Name');
                $("#suggest_lab").css("color", "red");
                isValid = false;
            }
            if ($("#permanentLab").is(':checked') == false && $("#temporaryLab").is(':checked') == false) {
                $("#select_Lab_Type").text("Select one type of lab");
                $("#select_Lab_Type").css("color", "red");
                isValid = false;
            }
            if ($("#permanentLab").is(':checked') == true) {
                var perDay = $("#lab_perDay").val();
                var perFrom = $("#lab_from").val();
                var perTo = $("#lab_to").val();

                if (Date.parse(perFrom) > Date.parse(perTo)) {
                    $("#from_time").text("Start time can't be greater than end time");
                    $("#from_time").css("color", "red");
                    isValid = false;
                }

                if (perDay == '') {
                    $("#per_day").text("Enter a Valid Day");
                    $("#per_day").css("color", "red");
                    isValid = false;
                }
                if (perFrom == '') {
                    $("#from_time").text("Select Time");
                    $("#from_time").css("color", "red");
                    isValid = false;
                }
                if (perTo == '') {
                    $("#to_time").text("Select Valid time");
                    $("#to_time").css("color", "red");
                    isValid = false;
                }
            }
            if ($("#temporaryLab").is(':checked') == true) {
              
                var tempDateFrom = $("#lab_dateFrom").val();
                var tempDateTo = $("#lab_dateTo").val();

                var tempTimeFrom = $("#tempLab_from").val();
                var tempTimeTo = $("#tempLab_to").val();
               
                if (Date.parse(tempDateFrom) > Date.parse(tempDateTo)) {
                    $("#from_date_div").text("Invalid Dates Selected");
                    $("#from_date_div").css("color", "red");
                    isValid = false;
                }

                if (Date.parse(tempTimeFrom) > Date.parse(tempTimeTo)) {
                    $("#tempLab_from_div").text("Start time can't be greater than end time");
                    $("#tempLab_from_div").css("color", "red");
                    isValid = false;
                }
                if (tempDateFrom == '') {
                    $("#from_date_div").text("Select Valid Date");
                    $("#from_date_div").css("color", "red");
                    isValid = false;
                }
                if (tempDateTo == '') {
                    $("#to_date_div").text("Select Valid Date");
                    $("#to_date_div").css("color", "red");
                    isValid = false;
                }
                if (tempTimeFrom == ''){
                    $("#tempLab_from_div").text("Select Valid time");
                    $("#tempLab_from_div").css("color", "red");
                    isValid = false;
                }
                if (tempTimeTo == '') {
                    $("#tempLab_to_div").text("Select Valid time");
                    $("#tempLab_to_div").css("color", "red");
                    isValid = false;
                }
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

            //var Section = $("#general_section").val();
            var semesterNo = $("#general_semester").val();
            var subject = $("#general_Subject").val();
            var reason = $("#general_reason").val();
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

            var url = "Forms/SaveGeneralRequest";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {

                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }
            }, function (xhr, ajaxoptions, thrownerror) {

                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            });

        }
        function SaveClearanceForm() {
            debugger;

            var data = new FormData();
            var stdPic = $("#uploadPicture").get(0).files;
            if (stdPic.length > 0) {
                data.append("Photograph", stdPic[0]);
            }
            data.append( "RollNo", $("#rollNo").text());
            data.append( "TargetDate", $("#clearance_finalResultDate").val());
            data.append("Reason", $("#clearance_reason").val());
            data.append("CategoryID", 1);
            data.append("libraryID", $("#clearance_libraryId").val());

            var url = "Forms/SaveClearanceForm";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (result) {

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
            var reason = $("#finalAcademic_reason").val();
            //var fname = $("#finalAcademic_fname").val();
            var rollno = $("#rollNo").text();

            data.append("PUreg", puReg);
            data.append("FYPTitle", FYPTitle);
            data.append("Reason", reason);
            //data.append("fname", fname);
            data.append("roll", rollno);


            var url = "Forms/SaveFinalAcadTrans";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);

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
                Reason: $("#semesterRejoin_reason").val(),
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
                CurrentSemester: $("#semesterFreeze_Withdrawal_semester").find(":selected").text(),
                RollNo: $("#rollNo").text(),
                TargetSemester: semesterToFreeze,
                Reason: $("#semesterFreeze_Withdrawal_reason").val(),
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
            var semesterNo = $("#bonafide_semester").find(":selected").text();
            var CGPA = $("#bonafide_CGPA").val();
            var reason = $("#bonafide_reason").val();
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

            var url = "Forms/SaveBonafideForm";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            });

        }
        //function ClearanceFormCreatedOrNot() {
        //    var url = "UserInfoData/ClearanceFormCreatedOrNot";
        //    MyWebApp.Globals.MakeAjaxCall("POST", url, [], function (response) {
        //        console.log(response);
        //        if (response.success == true && response.data == 3) {
        //            SaveReceiptOfOrignalDocumentForm();
        //        }
        //        else {
        //            MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
        //            hideAll();
        //       }
        //    }, function (xhr, ajaxoptions, thrownerror) {
        //        hideAll();
        //        MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
        //    });
        //}
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
            var idCard = $("#collegeIdCard_attach").get(0).files;
            var data = new FormData();
            // Add the uploaded image content to the form data collection
            if (idCard.length > 0) {
                data.append("idCard", idCard[0]);
            }
            if ($('#clearance_check').is(":checked")) {
                var clearance = $("#clearanceForm_attach").get(0).files;
                if (clearance.length > 0) {
                    data.append("clearanceForm", clearance[0]);
                }
            }
            var semester = $("#receiptOfOriginal_semester").find(":selected").text();
            var reason = $("#receiptOfOriginal_reason").val();
            var rollno = $("#rollNo").text();
       
            data.append("SemesterNo", semester);
            data.append("Reason", reason);
            data.append("roll", rollno);
            data.append("document", documents);


            var url = "Forms/receiptOfOriginal";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else if (response.success == false && response.data == true) {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Warning);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
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
            var semesterNo = $("#vehicleToken_semester").find(":selected").text();
            var Model = $("#vehicle_model").val();
            var reason = $("#vehicle_reason").val();
            var rollno = $("#rollNo").text();
            var regNum = $("#vehicle_regNo").val();
            var Manufacturer = $("#vehicle_manufacturer").val();
            var owner = $("#vehicle_ownersName").val();
            data.append("SemesterNo", semesterNo);
            data.append("Model", Model);
            data.append("Reason", reason);
            data.append("roll", rollno);
            data.append("regNum", regNum);
            data.append("Manufacturer", Manufacturer);
            data.append("owner", owner);
            //data.append("section", Section);

            var url = "Forms/SaveVehicalTokenForm";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
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
            var semesterNo = $("#collegeIdCard_semester").find(":selected").text();
            var ChallanNO = $("#collegeIdCard_challan").val();
            var reason = $("#collegeIdCard_reason").val();
            var rollno = $("#rollNo").text();

            data.append("SemesterNo", semesterNo);
            data.append("ChallanNO", ChallanNO);
            //data.append("section", section);
            data.append("Reason", reason);
            data.append("roll", rollno);

            var url = "Forms/SaveIdCardForm";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
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
            var CurrentSemester = $("#semesterAcademic_semester").find(":selected").text();
            var reason = $("#semesterAcademic_reason").val();
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

            var url = "Forms/SaveSemesterAcadTranscriptForm";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
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

            var semesterNo = $("#optionsForBsc_semester").find(":selected").text();
            var cnic = $("#optionsForBsc_CNIC").val();
            var puReg = $("#optionsForBsc_puReg").val();
            var DOB = $("#optionsForBsc_DOB").val();
            var reason = $("#optionsForBsc_reason").val();
            var rollno = $("#rollNo").text();
            //var fname = $("#optionsForBsc_fname").val();

            data.append("SemesterNo", semesterNo);
            data.append("CNIC", cnic);
            data.append("PUreg", puReg);
            data.append("DOB", DOB);
            data.append("Reason", reason);
            data.append("roll", rollno);
            //data.append("fname", fname);

            var url = "Forms/SaveBScForm";
            MyWebApp.Globals.MakeAjaxCall2("POST", url, data, function (response) {
                if (response.success == true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Form has been submitted', Enums.MessageType.Success);
                    showSuccessMsg(response.data);
                }
                else {
                    MyWebApp.UI.showRoasterMessage(response.error, Enums.MessageType.Error);
                    hideAll();
                }

            }, function (xhr, ajaxoptions, thrownerror) {
                hideAll();
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
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
                    CurrentSemester: $('#leave_semester').find(":selected").text(),
                    Reason: $("#leave_reason").val(),
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
            debugger;
            var j = 0;
            var coursesList = [];
            var temp1 = $("#tchr1").val();
            var temp1_ID = null;
            for (var i = 0; i < name1.length; i++) {
                if (name1[i] == temp1) {
                    temp1_ID = ApproverID1[i];
                }
            }
        var temp2 = $("#tchr2").val();
        var temp2_ID = null;
            for (var i = 0; i < name2.length; i++) {
                if (name2[i] == temp2) {
                    temp2_ID = ApproverID2[i];
                }
            }
            var temp3 = $("#tchr3").val();
            var temp3_ID = null;
            for (var i = 0; i < name3.length; i++) {
                if (name3[i] == temp3) {
                    temp3_ID = ApproverID3[i];
                }
        }
        if ($("#code1").val() != "" && $("#title1").val() != "" && $("#cr1").val() != "" && $("#tchr1").val() != "") {       
                var course1 = {
                    CourseID: $("#code1").val(),
                    CourseTitle: $("#title1").val(),
                    CreditHours: $("#cr1").val(),
                    TeacherName: $("#tchr1").val(),
                    ApproverID: temp1_ID
                }
                coursesList[j] = course1;
                j++;
            }
            if ($("#code2").val() != "" && $("#title2").val() != "" && $("#cr2").val() != "" && $("#tchr2").val() != "") {
                var course1 = {
                    CourseID: $("#code2").val(),
                    CourseTitle: $("#title2").val(),
                    CreditHours: $("#cr2").val(),
                    TeacherName: $("#tchr2").val(),
                    ApproverID: temp2_ID

                }
                coursesList[j] = course1;
                j++;
            }
            if ($("#code3").val() != "" && $("#title3").val() != "" && $("#cr3").val() != "" && $("#tchr3").val() != "") {
                var course1 = {
                    CourseID: $("#code3").val(),
                    CourseTitle: $("#title3").val(),
                    CreditHours: $("#cr3").val(),
                    TeacherName: $("#tchr3").val(),
                    ApproverID: temp3_ID

                }
                coursesList[j] = course1;
                j++;
            }

            var courseWithdraw = {
                course: coursesList,
                request: {
                    RollNo: $("#rollNo").text(),
                    CurrentSemester: $("#course_semester").find(":selected").text(),
                    Reason: $("#with_reason").val(),
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

        function SaveDemandVoucher() {
            debugger;
            var rb = $('#Regular:checked').val() ? true : false;
            var ss = $('#Self:checked').val() ? true : false;
            var cf = $('#CollegeFund:checked').val() ? true : false;
            var budget;
            if (rb == true) {
                budget = "Regular Budget";
            }
            else if (ss == true) {
                budget = "Self-Support";
            }
            else {
                budget = "College Fund";
            }

            debugger;
            var res = $("#demand_reason").val();
            var ItemList = [];
            $("#demandvoucherTable tbody tr").each(function () {
                var item_Id = $(this).attr('itemid');
                var item_name = $(this).find('.name').text();
                var quantity = $(this).find('.qty').text();
                ItemList.push({ ItemId: item_Id, ItemName: item_name, Quantity: quantity, Budget: budget });
                //ItemList.push({ ItemId: item_Id, Quantity: quantity });

            });
            var objItem = {

                Items: ItemList,
                request: {
                    Reason: res,
                    CategoryID: 16

                }
            }
            debugger;
            var dataToSend = JSON.stringify(objItem);
            var url = "Forms/SaveDemandVoucher";
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
                debugger;
                if (result.success === true) {
                    debugger;
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Successfully Submitted Form', Enums.MessageType.Success);
                    showSuccessMsg(result.data);
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                    hideAll();
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this form: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
            });
        }
        function SaveStoreDemandVoucher() {
            debugger;
            var res = $("#general_reason1").val();
            var budget;
            var ItemList = [];

            var rb = $('#Regular1:checked').val() ? true : false;
            var ss = $('#Self1:checked').val() ? true : false;
            var cf = $('#CollegeFund1:checked').val() ? true : false;

            if (rb == true) {
                budget = "Regular Budget";
            }
            else if (ss == true) {
                budget = "Self-Support";
            }
            else {
                budget = "College Fund";
            }

            $("#storevoucherTable tbody tr").each(function () {
                var item_Id = $(this).attr('itemid');
                var item_name = $(this).find('.name').text();
                var quantity = $(this).find('.qty').text();
                ItemList.push({ ItemId: item_Id, ItemName: item_name, Quantity: quantity, Budget: budget });
            });
            var objItem = {

                Items: ItemList,
                request: {
                    Reason: res,
                    CategoryID: 17

                }
            }
            debugger;
            var dataToSend = JSON.stringify(objItem);
            var url = "Forms/SaveStoreDemandVoucher";
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
                debugger;
                if (result.success === true) {
                    debugger;
                    MyWebApp.UI.showRoasterMessage('Successfully Submitted Form', Enums.MessageType.Success);
                    showSuccessMsg(result.data);
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                    hideAll();
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this form: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
            });
        }
        function SaveHardwareForm() {
            var reason = $("#hw_reason").val();
            var res;
            var purpose;
            if ($("#hwReplacement").is(':checked') == true) {
                purpose = "Replace demand: "
            }
            else if ($("#hwLoss").is(':checked') == true) {
                purpose = "Loss demand: "
            }
            else if ($("#hwInitial").is(':checked') == true) {
                purpose = "Initial demand: "
            }
            debugger;
            if (reason != "") {
                res = purpose.bold().concat(reason);

            }
            var ItemList = [];
            $("#hardwareTable tbody tr").each(function () {
                var item_Id = $(this).attr('itemid');
                var item_name = $(this).find('.name').text();
                var quantity = $(this).find('.qty').text();
                ItemList.push({ ItemId: item_Id, ItemName: item_name, Quantity: quantity });
            });
            var objItem = {

                Items: ItemList,
                request: {
                    Reason: res,
                    CategoryID: 15

                }
            }
            var dataToSend = JSON.stringify(objItem);
            debugger;
            var url = "Forms/SaveHardwareForm";
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

                if (result.success === true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Successfully Submitted Form', Enums.MessageType.Success);
                    showSuccessMsg(result.data);
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                    hideAll();
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
            });
        }
        function SaveRoomReservationForm() {
            var totalStd = $("#roomRes_Stds").val();
            var isMultimediaReq;
            var date = $("#roomRes_Date").val();
            var timeFrom = $("#roomRes_fromTime").val();
            var timeTo = $("#roomRes_toTime").val();
            var Reason = $("#room_reservation_purpose").val();
            if ($("#multimediaReqYes").is(':checked') == true)
            {
                isMultimediaReq=true;
            }
            else {
                isMultimediaReq = false;
            }
            var obj = {
                request: {
                    CategoryID : 19
                },
                roomReservationData: {
                    TotalStudents: totalStd,
                    Date: date,
                    TimeFrom: timeFrom,
                    TimeTo: timeTo,            
                    isMultimediaRequired: isMultimediaReq,
                    Purpose:Reason
                }
            }
            debugger;
            var dataToSend = JSON.stringify(obj);
            var url = "Forms/SaveRoomReservationForm";
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
                if (result.success === true) {
                    hideAll();
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success);
                    showSuccessMsg(result.data);

                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                    hideAll();
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
            });
        }
        function SaveDemandForm() {
            var res = $("#general_item_purpose").val();
            var ItemList = [];
            $("#selecteItemsTable tbody tr").each(function () {
                var item_Id = $(this).attr('itemid');
                var item_name = $(this).find('.name').text();
                var quantity = $(this).find('.qty').text();
                ItemList.push({ ItemId: item_Id, ItemName: item_name, Quantity: quantity,IssuedQty: "" });        
            });
            var objItem = {

                Items: ItemList,
                request: {
                    Reason:res,
                    CategoryID: 14

                }
            }
            debugger;
            var dataToSend = JSON.stringify(objItem);
            var url = "Forms/SaveDemandForm";
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

                if (result.success === true) {
                    debugger;
                    hideAll();
                    MyWebApp.UI.showRoasterMessage('Successfully Submitted Form', Enums.MessageType.Success);
                    showSuccessMsg(result.data);

                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                    hideAll();
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this Student: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
            });
        }

        function SaveLabReservationForm() {
            var courseTitle = $("#lab_courseTitle").val();
            var noOfComp = $("#lab_noComputer").val();
            var suggustedLab = $("#lab_suggestLab").val();
            var isPermanent = false;
            var isTemporary = false;

            var tempDateFrom = '';
            var tempDateTo = '';

            var tempTimeFrom = '';
            var tempTimeTo = '';

            var perDay = '';
            var perFrom = '';
            var perTo = '';

            if ($("#temporaryLab").is(':checked') == true)
            {
               tempDateFrom = $("#lab_dateFrom").val();
               tempDateTo = $("#lab_dateTo").val();

               tempTimeFrom = $("#tempLab_from").val();
               tempTimeTo = $("#tempLab_to").val();
               isTemporary = true;
            }
            else if ($("#permanentLab").is(':checked') == true) {
                perDay = $("#lab_perDay").val();
                perFrom = $("#lab_from").val();
                perTo = $("#lab_to").val();
                isPermanent = true;
            }


            var obj = {
                request: {
                    CategoryID : 18
                },
                labReservationData: {
                    CourseTitle  :courseTitle,
                    noOfComputer :noOfComp,
                    SuggestedLab :suggustedLab,
                    Day :perDay,
                    PerTimeFrom :perFrom,
                    PerTimeTo:perTo,
                    TempDateFrom:tempDateFrom,
                    TempDateTo :tempDateTo,
                    TempTimeFrom :tempTimeFrom,
                    TempTimeTo :tempTimeTo,  
                    IsPermanent :isPermanent,
                    IsTemporary: isTemporary
                }
            }
            var dataToSend = JSON.stringify(obj);
            var url = "Forms/SaveLabReservationForm";
            MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {
                if (result.success === true) {
                    debugger;
                    hideAll();
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success);
                    showSuccessMsg(result.data);

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