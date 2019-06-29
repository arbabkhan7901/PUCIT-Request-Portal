/// <reference path="../../_references.js" />

/*** 
* Exposes UI functions for the logon page
* @module Logon
* @namespace MyWebApp.UI
*/
var loginRecaptchaWidget = "";
var onloadCallback = function () {
    loginRecaptchaWidget = grecaptcha.render($(".g-recaptcha").get(0), {
        'sitekey': $(".g-recaptcha").attr('data-sitekey')
    });
};

MyWebApp.namespace("UI.Logon");

MyWebApp.UI.Logon = (function () {
    "use strict";
    var _isInitialized = false;

    function initialisePage() {

        if (_isInitialized == false) {
            _isInitialized = true;
            ClearFields();
            BindEvents();
            LoadExistingInfo();

            if (localStorage) {
                var at = localStorage.getItem('AT');
                if (at) {
                    LogonWithToken(at);
                }
            }
        }
    }//End of initialisePage
    function LogonWithToken(at) {
        var url = "UserInfoData/LoginWithAcToken";
        var data = JSON.stringify({ AccessToken: at });
        MyWebApp.Globals.MakeAjaxCall("POST", url, data, function (result) {
            if (result.success == true) {
                MyWebApp.UI.showRoasterMessage("Login is successful, entering into the application...", Enums.MessageType.Success);
                var returnUrl = MyWebApp.UI.getURLParameterByName("ReturnURL");
                if (returnUrl != "")
                    window.location.href = returnUrl;
                else
                    window.location.href = MyWebApp.Globals.baseURL + result.data.redirect;
            } else {

            }
        }, function (xhr, ajaxOptions, thrownError) {

        });
    }
    function BindEvents() {

        $("#txtUserName").watermark('User Name');
        $("#txtPassword").watermark('Password');

        $('#lnkLogin').click(function () {
            Logon();
            return false;
        });
        $('#lnkGoogle').click(function () {
            //Logon();
            if (GoogleApiHelper) {
                GoogleApiHelper.Open();
            }
            return false;
        });
        $('#contactus').click(function () {
            $('#ContactUsModal').show();
            return false;
        });
        $('#CancelMsg').click(function () {
            $('#ContactUsModal').hide();
            return false;
        });


        $('#txtUserName,#txtPassword').bind('keypress', function (e) {
            var code = (e.keyCode ? e.keyCode : e.which);
            if (code == 13) {
                Logon();
                e.preventDefault();
                return false;
            }
        });
        $('#emailID').bind('keypress', function (e) {
            var code = (e.keyCode ? e.keyCode : e.which);
            if (code == 13) {
                sendEmail();
                e.preventDefault();
                return false;
            }
        });
        $("#resend_password_link").bind("click", function () {
            window.location = $(this).attr("href");
        });

        $("#lnkHelp").bind("click", function () {
            window.location = $(this).attr("href");
        });

        $('#lnkLogin, ul#icons li').hover(
            function () { $(this).addClass('ui-state-hover'); },
            function () { $(this).removeClass('ui-state-hover'); }
        );

        $('#SendButton').click(function (e) {
            //  e.preventDefault();
            sendEmail();
            return false;
        });//end of click


        $('#saveContactus').click(function (e) {
            //  e.preventDefault();
            saveContactUs();

            return false;
        });//end of click

    }//End of BindEvents

    function isValidEmailAddress(emailAddress) {
        var pattern = new RegExp(/^[+a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/i);
        return pattern.test(emailAddress);
    }
    function ClearFields() {
        $('').val();
        $('').val();
        $('').val();
        $('#ContactUsModal').hide();

    }//End of ClearFields

    function sendEmail() {
        var Email = $('#emailID').val().trim();
        var url = "UserInfoData/sendEmail";
        var data = JSON.stringify({ emailAddress: Email });
        MyWebApp.Globals.MakeAjaxCall("POST", url, data, function (result) {
            debugger;
            if (result.success == true) {

                MyWebApp.UI.showRoasterMessage('An email has been sent to your email address!', Enums.MessageType.Success);
            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting students: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function saveContactUs() {

        var url = "UserInfoData/SaveContactUs";
        var obj = {};
        obj.Name = $("#contactus_name").val();
        obj.Email = $("#contactus_email").val();
        obj.Description = $("#contactus_desc").val();
        if ($.trim(obj.Name) === '') {
            MyWebApp.UI.showRoasterMessage("You must enter your name.", Enums.MessageType.Error);
            $('#contactus_name').focus();
            return;
        }
        if ($.trim(obj.Email) === '') {
            MyWebApp.UI.showRoasterMessage("You must enter your email.", Enums.MessageType.Error);
            $('#contactus_email').focus();
            return;
        }
        if (isValidEmailAddress(obj.Email) == false) {
            MyWebApp.UI.showRoasterMessage("Please enter valid email.", Enums.MessageType.Error);
            $('#contactus_email').focus();
            return;
        }
        if ($.trim(obj.Description) === '') {
            MyWebApp.UI.showRoasterMessage("You must enter your message.", Enums.MessageType.Error);
            $('#contactus_desc').focus();
            return;
        }

        var data = JSON.stringify(obj);
        MyWebApp.Globals.MakeAjaxCall("POST", url, data, function (result) {

            if (result.success == true) {
                MyWebApp.UI.showRoasterMessage('Your response has been recorded', Enums.MessageType.Success);
                ClearFields();

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error);
            }
        }, function (xhr, ajaxOptions, thrownError) {
            MyWebApp.UI.showRoasterMessage('A problem has occurred while getting students: "' + thrownError + '". Please try again.', Enums.MessageType.Error);
        });
    }
    function LoadExistingInfo() {

        var uName = $.cookie("UserName");
        var pasd = $.cookie("Password");

        if (uName != null && uName != "") {

            $('#txtUserName').val(uName);
            $('#txtPassword').val(pasd);
            $("#chkKeepMeLoggedIn").attr("checked", true);
        }
    }

    function Logon() {

        var userName = $('#txtUserName').val();
        var password = $('#txtPassword').val();

        if ($.trim(userName) === '') {
            MyWebApp.UI.showRoasterMessage("You must enter a user name.", Enums.MessageType.Error);
            $('#txtUserName').focus();
            return;
        }
        if ($.trim(password) === '') {
            MyWebApp.UI.showRoasterMessage("You must enter a password.", Enums.MessageType.Error);
            $('#txtPassword').focus();
            return;
        }

        //Check if recaptcha is enabled in application & relevant DIV is part of page
        var captcharesponse = "";
        if ($(".g-recaptcha").length > 0 && grecaptcha) {
            captcharesponse = grecaptcha.getResponse();
            if (!captcharesponse) {
                MyWebApp.UI.showRoasterMessage("Invalid reCapatcha", Enums.MessageType.Error);
                return;
            }
        }

        var login = {
            UserName: userName,
            Password: password,
            reCaptcha_Response: captcharesponse
        }
        var data = JSON.stringify(login);

        var url = "UserInfoData/ValidateUser";

        MyWebApp.Globals.MakeAjaxCall("POST", url, data, function (result) {
            console.log(result);
            if (result.success === true) {

                MyWebApp.UI.showRoasterMessage("Login is successful, entering into the application...", Enums.MessageType.Success);
                var returnUrl = MyWebApp.UI.getURLParameterByName("ReturnURL");

                if (returnUrl != "")
                    window.location.href = returnUrl;
                else
                    window.location.href = MyWebApp.Globals.baseURL + result.data.redirect;

            } else {
                MyWebApp.UI.showRoasterMessage(result.error, Enums.MessageType.Error, 5000);
                
                if ($(".g-recaptcha").length > 0 && grecaptcha) {
                    try {
                        grecaptcha.reset(loginRecaptchaWidget);
                    } catch (e) {
                        
                    }
                }
                
            }
        }, function (xhr, ajaxOptions, thrownError) {
            //debugger;
            MyWebApp.UI.showRoasterMessage('There was a problem authenticating your credentials: "' + xhr.responseText + '". Please try again.', Enums.MessageType.Error);
        });
    }//End of Logon function

    return {

        readyMain: function () {
            initialisePage();
        },
        onloadCallback: function () {
            alert('testing');
        }
    };
}());