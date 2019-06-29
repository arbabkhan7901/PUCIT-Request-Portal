MyWebApp.namespace("UI.Header");

MyWebApp.UI.Header = (function () {
    "use strict";
    var _isInitialized = false;
    
    function initialisePage() {
        if (_isInitialized == false) {
            _isInitialized = true;
            BindEvents();
        }
    }
    function BindEvents() {

        $("#lnkProfileModal").unbind('click').bind('click', function (e) {
            e.preventDefault();

            $('#profileModal').modal('show');
            //$.bsmodal.show("#profileModal", { top: "5%", left: "25%", closeid: "#btnCloseProfileModal,#btnCloseProfileModal2" });

            return false;
        });

        $("#self").unbind('click').bind('click', function (e) {
            e.preventDefault();
            debugger;
            var data = "self";
            changeAccessType(data);
            return false;
          
        });


        $("#assigned").unbind('click').bind('click', function (e) {
            e.preventDefault();
            var data = "assigned";
            changeAccessType(data);
            return false;

        });


        $("#SearchDiary").bind('keypress', function (e) {
            var code = (e.keyCode ? e.keyCode : e.which);
            if (code == 13) {
                $("#SearchButton").click();              
                e.preventDefault();
                return false;
            }
        });
        $("#lnkLoginAs").unbind('click').bind('click', function (e) {
            e.preventDefault();
            $('#divLoginAs').modal('show');

            return false;
        });

        $("#uploadsignature").unbind('click').bind('click', function (e) {
            debugger
            var sign = $("#signImage").get(0).files;
            // Add the uploaded image content to the form data collection
            if (sign.length == 0) {
                $('#_result_ID').text("Please upload image of your signature");
                $('#_result_ID').css("color", "red");
            }
            else if (sign.length > 0) {
                if (!hasExtension('signImage', ['.jpg', '.png', '.jpeg'])) {
                    $('#_result_ID').text("Invalid signature extension");
                    $('#_result_ID').css("color", "red");
                }


                else {
                    var data = new FormData();
                    // Add the uploaded image content to the form data collection
                    if (sign.length > 0) {
                        data.append("Signature", sign[0]);
                    }

                    var ajaxRequest = $.ajax({
                        type: "POST",
                        url: window.MyWebAppBasePath + "aapi/Forms/UploadSignature",
                        contentType: false,
                        processData: false,
                        data: data,
                        success: function (response) {
                            MyWebApp.UI.showRoasterMessage('Signature Uploaded', Enums.MessageType.Success);
                            setTimeout(function () {
                                location.reload();
                            }, 1000);
                        },
                        error: function (response) {
                            // hideAll();
                            MyWebApp.UI.showRoasterMessage('Some error', Enums.MessageType.Error);
                        }
                    });
                }
            }
        });
        
        $("#SearchButton").click(function (e) {
            debugger;
            var number = $("#SearchDiary").val();
            window.location = window.MyWebAppBasePath + "Home/ApplicationView/" + number;
        });
       

        $(".user-menu .designation a").click(function (e) {
            e.preventDefault();

            if ($(this).hasClass("selected"))
                return false;

            var aid = $(this).attr("aid");

            var url = "UserInfoData/ChangeDesig?aid=" + aid;

            MyWebApp.Globals.MakeAjaxCall("GET", url, {}, function (result) {
                
                if (result.success == true) {
                    MyWebApp.UI.ShowLastMsgAndRefresh("Changed successfully.");
                } else {
                    MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
                }
            }, function (xhr, ajaxoptions, thrownerror) {
                MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
            });

            return false;
        });
    }
    function hasExtension(inputID, exts) {
        var fileName = (document.getElementById(inputID).value).toLowerCase();
        return (new RegExp('(' + exts.join('|').replace(/\./g, '\\.') + ')$')).test(fileName);
    }
    function changeAccessType(data) {
       
        debugger;
        var url = "Dashboard/changeAccessType?access="+data;


        MyWebApp.Globals.MakeAjaxCall("GET", url, {}, function (result) {

            if (result.success === true) {
                //MyWebApp.UI.ShowLastMsgAndRefresh(result.error);
                MyWebApp.UI.ShowLastMsgAndRedirect(result.error, MyWebApp.Resources.Views.HomeURL);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxoptions, thrownerror) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred."' + thrownerror + '". please try again.', Enums.MessageType.Error);
        });

    }
    return {

        readyMain: function () {
            initialisePage();
        }
    };
}
    ());