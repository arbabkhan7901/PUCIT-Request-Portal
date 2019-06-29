MyWebApp.namespace("UI.GoogleUsers");


MyWebApp.UI.GoogleUsers = (function () {
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
            
        }
    }

    function BindEvents() {
        

        $("#cmbPageSizeSearch").change(function(e){
            e.preventDefault();
            create_pages =true;
            current_page == 0
            SearchUsers();
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

    function SearchUsers(){
        if(current_page == 0)
            current_page = 1;

        var searchObject = {
            TextToSearch: $("#txtTextToSearch").val().trim(),
            IsActive:  $("#cmbIsActiveSearch").val(),
            PageSize: $("#cmbPageSizeSearch").val(),
            PageIndex: current_page - 1
        };

        var url = "Security/SearchGoogleLoginRequests";
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
    
    function clearFields() {

        

    }
    
    function displayAllUsers(UserList) {

        MyWebApp.UI.Common.setHandlebarTemplate("#UserTemplate","#simple-table",UserList,false,BindGridEvents);
    }
    function BindGridEvents() {
        
        $("#simple-table .lnkEditMapping").unbind('click').bind('click', function () {
            var email = $(this).closest('tr').attr('id');
            GenerateRolesHTML(temp_roleData);
            $("#EditRolesModal").data('Email', email);
            $('#EditRolesModal').modal('show');
            return false;
        });
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

    function SaveRoleMapping() {
        var permList = [];
        var roleId = Number($("#sortable1 li input:checked").closest('li').attr("id"));
        var emailId = $("#EditRolesModal").data('Email');
        
        if(isNaN(roleId))
        {
            MyWebApp.UI.showRoasterMessage('Please Select Role', Enums.MessageType.Warning);
            return;
        }
        if(emailId == "")
        {
            MyWebApp.UI.showRoasterMessage('Invalid Request', Enums.MessageType.Warning);
            return;
        }
        
        var dataToSend = {};
        dataToSend.EmailID = emailId;
        dataToSend.RoleID = roleId;

        dataToSend = JSON.stringify(dataToSend);
        var url = "Security/CreateUserFromGoogleRequest";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success, 2000);
                $('#EditRolesModal').modal('hide');
                $("#search").trigger("click");
            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }


    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
());