MyWebApp.namespace("UI.Users");


MyWebApp.UI.Users = (function () {
    "use strict";
    var _isInitialized = false;
    var id = null;
    var isAciveUser1 = false;
    var isValid1;
    var create_pages = false;

    var usersData;
    var temp_roleData;
    var current_page = 0;
    var designations_list ;

    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
            create_pages =true;
            SearchUsers();
            getActiveRoles();
            getActiveDesignations();
        }
    }

    function BindEvents() {
        
        $("#Status").change(function(){
            debugger;
            if($(this).val() == 1)
                $("#divDesigArea").show();
            else
                $("#divDesigArea").hide();

            $("#cmbDesignations").val("0");
            $("#lstAddedDeisgn").html("");
        });

        $("#btnAddDesign").unbind('click').bind('click',function(e){
            e.preventDefault();
            var desigID = $("#cmbDesignations").val();

            if(desigID <= 0){
                MyWebApp.UI.showRoasterMessage("Select a designation to add", Enums.MessageType.Warning, 1500);
                return false;
            }

            var desigText = $("#cmbDesignations option:selected").text().trim();

            var obj = {};
            obj.ContributorList = [];
            var id = 0;
             $("#lstAddedDeisgn li").each(function(){
                var did = $(this).attr("did");
                if (did == desigID) {
                    id = 1;
                }
            });
             if (id == 0)
                 obj.ContributorList.push({ ApproverID: 0, DesignationID: desigID, Designation: desigText });
             else {
                MyWebApp.UI.showRoasterMessage("Designation already existed.", Enums.MessageType.Warning, 1500);
                return false;
             }
             MyWebApp.UI.Common.setHandlebarTemplate("#changeContributors1", "#lstAddedDeisgn", obj, true, function () {
                 $("#lstAddedDeisgn .removeContributor").unbind('click').bind('click', function () {
                     $(this).closest('li').remove();
                 });
             });

            return false;
        });

        $("#cmbPageSizeSearch").change(function(e){
            e.preventDefault();
            create_pages =true;
            current_page == 0;
            SearchUsers();
            return false;
        });

        $("#newuser").click(function (e) {
            e.preventDefault();
            //debugger;
            clearFields();
            $('#modal-form').modal('show');
            //$.bsmodal.show("#modal-form",{top: "5%", left: "15%",width:"600px"});
        });

        $("#Save").unbind('click').bind('click', function (e) {
            e.preventDefault();
            //debugger;
            var Name = $("#txtName").val().trim();
            var Username = $("#txtUsername").val().trim();
            var FatherName = $("#txtFatherName").val().trim();
            var Section = $("#txtSection").val().trim();
            var Title = $("#txtTitle").val().trim();
            var Email = $('#txtEmail').val().trim();
            var IsContributor = $("#Status").val();
            var IsOldCampus = $("#IsOldCampus").val();

            if (Name == '' || Username == '' || FatherName == '' || Section == '' || Title == '' || Email == '') {
                MyWebApp.UI.showRoasterMessage("Empty Field(s)", Enums.MessageType.Error, 2000);
                return;
            }
            if (isValidEmailAddress(Email) == false) {
                MyWebApp.UI.showRoasterMessage("Please enter a valid email.", Enums.MessageType.Warning);
                return;
            }

            IsContributor = Boolean(Number(IsContributor));
            IsOldCampus = Boolean(Number(IsOldCampus));
            debugger;
            var designations = [];
            if(IsContributor){
                $("#lstAddedDeisgn li").each(function(){
                    var pid = $(this).attr("pid");
                    var did = $(this).attr("did");
                    
                    designations.push({ApproverID: pid, DesignationID:did});
                });
            }

            $('#modal-form').modal('hide');
            //$.bsmodal.hide("#modal-form");

            MyWebApp.Globals.ShowYesNoPopup({
                headerText: "Save",
                bodyText: 'Do you want to Save this record?',
                dataToPass: {
                    UserId: $("#hiddenid").val(),
                    Name: Name,
                    Login: Username,
                    StdFatherName: FatherName,
                    Section: Section,
                    IsOldCampus: IsOldCampus,
                    IsContributor: IsContributor,
                    Title: Title,
                    Email: Email,
                    ApprDesignations: designations
                },
                fnYesCallBack: function ($modalObj, dataToPass) {
                    saveUser(dataToPass);
                    $modalObj.hideMe()
                }
            });
            return false;
        });

        $("#ModalClose, #Cancel").click(function (e) {
            e.preventDefault();
            $('#modal-form').modal('hide');
            //$.bsmodal.hide("#modal-form");
            return false;
        });
        

        $("#SaveMappings").unbind('click').bind('click', function () {
            SaveRoleMapping();
            return false;
        });
        
        $("#search").unbind("click").bind("click", function (e) {
            //debugger
            e.preventDefault();
            current_page = 0;
            create_pages =true;

            SearchUsers();
            return false;
        });
        
    }//End of Bind Events

    function FindUser(pUserId){
        return usersData.UserList.find(p => p.UserId == pUserId);
    }

    function SearchUsers(){
        if(current_page == 0)
            current_page = 1;

        var searchObject = {
            TextToSearch: $("#txtTextToSearch").val().trim(),
            IsContributor: $("#cmbContributorSearch").val(),
            IsOldCampus:  $("#cmbCampusSearch").val(),
            IsActive:  $("#cmbIsActiveSearch").val(),
            PageSize: $("#cmbPageSizeSearch").val(),
            PageIndex: current_page - 1
        };

        var url = "Security/SearchUsers";
        var Data = JSON.stringify(searchObject);

        MyWebApp.Globals.MakeAjaxCall("POST", url, Data, function (result) {
            if (result.success === true) {
                usersData = result.data;
                $("#spResultsFound").text("(" + result.data.Count + " Users are found)");
                CreatePages(result.data.Count);
                displayAllUsers(result.data);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting applications: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function CreatePages(recordCount){
        var pageSize = Number($("#cmbPageSizeSearch").val());

        if(create_pages == true){
            MyWebApp.UI.Common.ApplyPagination("ul.pagination",recordCount,pageSize,function(pageNumber){
                current_page = pageNumber;
                SearchUsers();
            });
            create_pages = false;
        }
    }
    function saveUser(dataToPass) {
        
        var userObjToSend = {
            UserId: dataToPass.UserId,
            Name: dataToPass.Name,
            Email: dataToPass.Email,
            Login: dataToPass.Login,
            StdFatherName: dataToPass.StdFatherName,
            Section: dataToPass.Section,
            IsOldCampus: dataToPass.IsOldCampus,
            IsContributor: dataToPass.IsContributor,
            Title: dataToPass.Title,
            ApprDesignations: dataToPass.ApprDesignations
        };

        var dataToSend = JSON.stringify(userObjToSend);
        var url = "Security/SaveUsers";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success, 2000);
                
                var userObj = FindUser(userObjToSend.UserId);   //usersData.UserList.find(p => p.UserId == userObjToSend.UserId);
                
                if(userObj){
                    userObj.Name = userObjToSend.Name;
                    userObj.Email = userObjToSend.Email;
                    userObj.Login = userObjToSend.Login;
                    userObj.StdFatherName = userObjToSend.StdFatherName;
                    userObj.Section = userObjToSend.Section;
                    userObj.IsOldCampus = userObjToSend.IsOldCampus;
                    userObj.IsContributor = userObjToSend.IsContributor;
                    userObj.Title = userObjToSend.Title;
                }

                displayAllUsers(usersData);

            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
            $('#modal-form').modal('hide');
            //$.bsmodal.hide("#modal-form");
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this User: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }
    function clearFields() {

        $('#txtName').val("");
        $('#txtUsername').val("");
        $('#txtFatherName').val("");
        $('#txtSection').val("");
        $('#IsOldCampus').val("");
        $('#txtTitle').val("");
        $('#txtEmail').val("");
        $("#hiddenid").val("");
        $("#Status").val("");
        $("#Status").removeAttr("disabled");
        $("#cmbDesignations").val("0");
        $("#lstAddedDeisgn").html("");
        $("#divDesigArea").hide();

    }
    function EnableDisableUser(dataObj) {
        var userData = {
            UserId: dataObj.UserId,
            IsActive: !dataObj.IsActive
        }

        var dataToSend = JSON.stringify(userData);
        var   url = "Security/EnableDisableUser";

        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {

                var userObj = FindUser(userData.UserId);    //usersData.UserList.find(p => p.UserId == userData.UserId);
                userObj.IsActive = userData.IsActive;

                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success, 2000);

                displayAllUsers(usersData);

            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this User: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function displayAllUsers(UserList) {

        MyWebApp.UI.Common.setHandlebarTemplate("#UserTemplate","#simple-table",UserList,false,BindGridEvents);
    }
    function BindGridEvents() {
        
        $("#simple-table .lnkEdit").unbind('click').bind('click', function () {
            var id = $(this).closest('tr').attr('id');
            HandleEditUser(id);
            return false;
        });
        $("#simple-table .lnkDelete").unbind('click').bind('click', function () {
            //debugger;
            var id = $(this).closest('tr').attr('id');
            HandleEnableDisableUser(id);
            return false;
        });
        $("#simple-table .lnkEditMapping").unbind('click').bind('click', function () {
            var id = $(this).closest('tr').attr('id');
            GenerateRolesHTML(temp_roleData);
            GetRolesByUserID(id);

            return false;
        });
    }
    function HandleEditUser(UserId) {

        if (usersData) {
            var userObj =FindUser(UserId);     //usersData.UserList.find(p => p.UserId == UserId);
            if (userObj) {
                if (userObj.IsActive == false) {
                    MyWebApp.UI.showRoasterMessage("Editing is not allowed as record is disabled", Enums.MessageType.Error);
                    return false;
                }
                
                $("#txtFatherName").val(userObj.StdFatherName);
                $("#txtSection").val(userObj.Section);
                $("#txtTitle").val(userObj.Title);
                $('#txtEmail').val(userObj.Email);
                if(userObj.IsContributor)
                    $("#Status").val("1");
                else
                    $("#Status").val("0");
                
                $("#Status").trigger("change");

                if(userObj.IsOldCampus)
                    $("#IsOldCampus").val("1");
                else 
                    $("#IsOldCampus").val("0");

                $("#Status").attr("disabled",true);

                $("#hiddenid").val(userObj.UserId);
                $("#txtName").val(userObj.Name);
                $("#txtEmail").val(userObj.Email);
                $("#txtUsername").val(userObj.Login);

                if(userObj.IsContributor)
                    GetDesignationsByUserID(userObj.UserId);

                $('#modal-form').modal('show');
                //$.bsmodal.show("#modal-form",{top: "5%", left: "15%"});
            }//end of userObj
        }//end of usersData
    }
    function HandleEnableDisableUser(UserId) {

        if (usersData) {
            var userObj =FindUser(UserId); //usersData.UserList.find(p => p.UserId == UserId);
            if (userObj) {

                var header = (userObj.IsActive == false ? "Enable" : "Disable");

                MyWebApp.Globals.ShowYesNoPopup({
                    headerText: header,
                    bodyText: 'Do you want to ' + header + ' this record?',
                    dataToPass: { "UserId": userObj.UserId, "IsActive": userObj.IsActive },
                    fnYesCallBack: function ($modalObj, dataObj) {
                        EnableDisableUser(dataObj);
                        $modalObj.hideMe();
                    }
                });
            }//end of userObj
        }//end of usersData
    }
    
    function GetDesignationsByUserID(userId) {
        var url = "Security/GetDesignationsByUserID?pUserID=" + userId;
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                
                for(var i=0;i<result.data.ContributorList.length;i++){
                    var obj = result.data.ContributorList[i];
                    var desigObj = designations_list.find(p => p.DesignationID == obj.DesignationID);
                    if(desigObj)
                        obj.Designation = desigObj.Designation;
                }
                
                MyWebApp.UI.Common.setHandlebarTemplate("#changeContributors1","#lstAddedDeisgn",result.data,false,function(){
                    $("#lstAddedDeisgn .removeContributor").unbind('click').bind('click',function () {
                        $(this).closest('li').remove();
                    });
                });
                
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Users: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });

    }
    
    

    function isValidEmailAddress(emailAddress) {
        var pattern = new RegExp(/^[+a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i);
        return pattern.test(emailAddress);
    }
    
    function getActiveRoles() {

        var url = "Security/getActiveRoles";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                temp_roleData = result.data;
                GenerateRolesHTML(temp_roleData);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Roles: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        }, false);
    }
    function GenerateRolesHTML(Roles) {

        MyWebApp.UI.Common.setHandlebarTemplate("#RoleTemplate","#sortable1",Roles);
    }
    function GetRolesByUserID(pUserID) {

        var url = "Security/GetRolesByUserID?pUserID=" + pUserID;
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                SelectRolesInPopupForCurrentUser(result.data.Roles, pUserID);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Roles: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        }, false);
    }
    function SelectRolesInPopupForCurrentUser(permissionIds, pUserID) {

        $("#sortable1 li").each(function () {
            var id = parseInt($(this).attr("id"));
            if (permissionIds.indexOf(id) >= 0)
                $(this).find("input[type=checkbox]").attr("checked", true);
        });

        $("#EditRolesModal").data('UserID', pUserID);

        $('#EditRolesModal').modal('show');
        //$.bsmodal.show("#EditRolesModal", { top: "5%", left: "25%", closeid: "#closeedit,#CancelPermModal" });
    }

    function SaveRoleMapping() {
        var permList = [];
        $("#sortable1 li :checked").each(function () {
            var permId = $(this).closest('li').attr("id");
            permList.push(parseInt(permId));
        });

        var userID = $("#EditRolesModal").data('UserID');
        var dataToSend = {};
        dataToSend.UserID = userID;
        dataToSend.Roles = permList;

        dataToSend = JSON.stringify(dataToSend);
        var url = "Security/SaveUserRoleMapping";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success, 2000);
                //debugger;
                $('#EditRolesModal').modal('hide');
                //$.bsmodal.hide("#EditRolesModal");
            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }

    //-----------------Designations Handling
    function getActiveDesignations() {
        var url = "Security/GetDesignations";
        MyWebApp.Globals.MakeAjaxCall("GET", url, "{}", function (result) {
            if (result.success === true) {
                debugger;
                designations_list = result.data.Designations;
                Utilities.LoadDropDown($("#cmbDesignations"),result.data.Designations,"DesignationID","Designation");
            } else {
                //MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            //MyWebApp.UI.showRoasterMessage('A problem has occurred while getting Roles: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        }, false);
    }


    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
());