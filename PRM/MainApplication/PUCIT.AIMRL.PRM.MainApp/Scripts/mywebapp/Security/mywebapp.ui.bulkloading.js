MyWebApp.namespace("UI.Security.UserBulk");

MyWebApp.UI.Security.UserBulk = (function () {
    "use strict";
    var _isInitialized = false;
    var Students;
    var flag;
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
         
        }
    }

    function BindEvents() {
       
        $("#uploadfile").unbind('click').bind('click', function (e) {
            Students = { StudentList: "" };
            Students.StudentList = new Array();
            var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.csv|.txt)$/;
            if (regex.test($("#datafile").val().toLowerCase())) {
                if (typeof (FileReader) != "undefined") {
                    var reader = new FileReader();
                    reader.onload = function (e) {


                        var rows = e.target.result.split("\n");
                        var headers = rows[0].split(',');
                        for (var i = 0; i < rows.length; i++) {
                            var cells = rows[i].split(",");
                            var onerow = {};
                            for (var j = 0; j < cells.length; j++) {
                                if (i != 0) {
                                    if (j == cells.length - 1) {
                                        onerow['IsOldCampus'] = cells[j];
                                    }
             
                                    else {
                                        onerow[headers[j]] = cells[j];
                                    }
                                }
                            }
            
                            if (i != 0) {
                              
                                Students.StudentList[i - 1] = onerow;
                            }
                           
                        }
                        displayAllStudents(Students);
                    }
                    reader.readAsText($("#datafile")[0].files[0]);
                    $("#SaveBtnDiv").show();
                } else {
                    alert("This browser does not support HTML5.");
                }
            } else {
                alert("Please upload a valid CSV file.");
            }
            $('#error_div').text("");

        });
        $("#SaveBtn").unbind('click').bind('click', function (e) {
            flag = true;
            console.log(Students);
            debugger
            $("#simple-table2 tbody tr").each(function (j) {
              
                var y = $(this);
                var cells =y.find('td');
                $(cells).each(function (i) {
                    var x = $(this).text();
                    if (i == 0) {
                        if (validateLogin(x)) {
                            Students.StudentList[j].Login = x;
                        }
                        else {
                            flag = false;
                            $(this).focus();
                            return false ; 
                        }
                    }
                    else if (i == 1) {
                        if (validateName(x)) {
                            Students.StudentList[j].Name = x;
                        }
                        else {
                            flag = false;

                            $(this).focus();
                            return false;

                        }
                    }
                    else if (i == 2) {
                        if (validateFatherName(x)) {
                            Students.StudentList[j].StdFatherName = x;

                        }
                        else {
                            flag = false;
                            $(this).focus();
                            return false;

                        }
                    }
                    else if (i == 3) {
                        if (validateSection(x)) {
                            Students.StudentList[j].Section = x;

                        }
                        else {
                            flag = false;
                            $(this).focus();
                            return false;

                        }
                    }
                    else if (i == 4) {
                        if (validateEmail(x)) {
                            Students.StudentList[j].Email = x;
                        }
                        else {
                            flag = false;
                            $(this).focus();
                            return false;

                        }
                    }
                    else if (i == 5) {
                        if ($(this).attr('id')=='0') {
                            Students.StudentList[j].IsOldCampus = false;
                        }
                        else if ($(this).attr('id')=='1') {

                            Students.StudentList[j].IsOldCampus =true;
                        }

                    }
                });
                if (flag == false) {
                    return false;
                    }

            });
            if (flag == false) {
                e.stopImmediatePropagation();
            }
            else {
                console.log(Students.StudentList);
                MyWebApp.Globals.ShowYesNoPopup({
                    headerText: "Save",
                    bodyText: 'Do you want to Save these record?',
                    dataToPass: {
                        
                    },
                    fnYesCallBack: function ($modalObj, dataToPass) 
                    {
                        SaveUsers();
                        $modalObj.hideMe()
                    }
                });
            }

        });
        $('#simple-table2').on('click', 'input', function () {
            debugger
            if ($(this).val().trim()=='0') {
                $(this).closest('td').attr('id', '1');
            }
            else {
                $(this).closest('td').attr('id', '0');

            }
        });
    }
    function validateLogin(login) {
        if (login.trim() == "") {
            $('#error_div').text("Empty Login field");
            $('#error_div').css("color", "red");
            return false;
        }
        return true;
    }
    function validateName(name) {
        if (name.trim() == "") {
            $('#error_div').text("Empty Name field");
            $('#error_div').css("color", "red");
            return false;
        }
        return true;
    }
    function validateFatherName(fathername) {
        if (fathername.trim() == "") {
            $('#error_div').text("Empty FatherName field");
            $('#error_div').css("color", "red");
            return false;
        }
        return true;
    }
    function validateSection(section) {
        if (section.trim() == "") {
            $('#error_div').text("Empty Section field");
            $('#error_div').css("color", "red");
            return false;
        }
        return true;
    }

    function validateEmail(email) {      
        var pattern = new RegExp(/^[+a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i);             
        if (email.trim() == "") {
            $('#error_div').text("Empty Email field");
            $('#error_div').css("color", "red");
            return false;
        }
        else if (pattern.test(email) == false) {
            $('#error_div').text("Invalid Email");
            $('#error_div').css("color", "red");
            return false;
        }
        return true;
    }
   
    function displayAllStudents(StudentList) {
       

        $("#simple-table2").html("");

        if (!StudentList)
            return;

        try {
            var source = $("#StudentTemplate").html();
            var template = Handlebars.compile(source);
            var html = template(StudentList);
        } catch (e) {
            debugger;
        }

        $("#simple-table2").append(html);

    }
    function SaveUsers() {
        console.log(Students.StudentList);
        var dataToSend = JSON.stringify(Students.StudentList);
        var url = "Security/SaveUsersBulk";
        MyWebApp.Globals.MakeAjaxCall("POST", url, dataToSend, function (result) {

            if (result.success === true) {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Success, 2000);
                window.location.href = MyWebApp.Globals.baseURL + '/Security/Users';

            } else {
                MyWebApp.UI.showRoasterMessage('some error has occurred', Enums.MessageType.Error);
            }
            $('#modal-form').modal('hide');
         
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showMessage("#spstatus", 'A problem has occurred while saving this User: "' + thrownerror + '". Please try again.', Enums.MessageType.Error);
        });

    }

    return {
        readyMain: function () {
            initialisePage();
        }
    };
}
());