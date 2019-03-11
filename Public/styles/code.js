$(document).ready(function(){
                  $('#copyVerificationCode').click(function(){
                                                   $('#verificationCode').select();
                                                   document.execCommand("copy");
                                                   toastr.options = {"closeButton": true,"preventDuplicates": true};
                                                   toastr.success("has been copied to your clipboard.", "Verification Code");
                                                   });
                  $('#emailVerificationCode').click(function(){
                                                    //send email
                                                    toastr.options = {"closeButton": true,"preventDuplicates": true};
                                                    toastr.success("has been sent to your Email Inbox.", "Verification Code");
                                                    });
                  $('.backButton').click(function(){
                                         window.history.back();
                                         });
                  
                  var orange = document.getElementById('orangeHelp');
                  var userpass = document.getElementById('userpassHelp');
                  var login = document.getElementById('loginHelp');
                  var securely = document.getElementById('securelyHelp');
                  var verificationCode = document.getElementById('verificationCodeHelp');
                  var spoilBallot = document.getElementById('spoilBallotHelp');
                  var checkVerificationCode = document.getElementById('checkVerificationCodeHelp');
                  
                  
                  if (orange) {
                    var orangeRegion = ZingTouch.Region(orange, false, false);
                    orangeRegion.bind(orange, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#orangeHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                    $('#orangeHelpButton').click(function(){ $("#orangeHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                    $('#orangeHelp .helpDismiss').click(function(){ $("#orangeHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  
                  if (userpass) {
                    var userpassRegion = ZingTouch.Region(userpass, false, false);
                    userpassRegion.bind(userpass, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#userpassHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                    $('#userpassHelpButton').click(function(){ $("#userpassHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                    $('#userpassHelp .helpDismiss').click(function(){ $("#userpassHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  
                  if (login) {
                  var loginRegion = ZingTouch.Region(login, false, false);
                  loginRegion.bind(login, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#loginHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                  $('#loginHelpButton').click(function(){ $("#loginHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                  $('#loginHelp .helpDismiss').click(function(){ $("#loginHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  
                  if (securely) {
                  var securelyRegion = ZingTouch.Region(securely, false, false);
                  securelyRegion.bind(securely, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#securelyHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                  $('#securelyHelpButton').click(function(){ $("#securelyHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                  $('#securelyHelp .helpDismiss').click(function(){ $("#securelyHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  
                  if (verificationCode) {
                  var verificationCodeRegion = ZingTouch.Region(verificationCode, false, false);
                  verificationCodeRegion.bind(verificationCode, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#verificationCodeHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                  $('#verificationCodeHelpButton').click(function(){ $("#verificationCodeHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                  $('#whatIsVerificationCodeHelpButton').click(function(){ $("#verificationCodeHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                  $('#verificationCodeHelp .helpDismiss').click(function(){ $("#verificationCodeHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  if (spoilBallot) {
                  var spoilBallotRegion = ZingTouch.Region(spoilBallot, false, false);
                  spoilBallotRegion.bind(spoilBallot, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#spoilBallotHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                  $('#spoilBallotHelpButton').click(function(){ $("#spoilBallotHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                  $('#spoilBallotHelp .helpDismiss').click(function(){ $("#spoilBallotHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  
                  if (checkVerificationCode) {
                  var checkVerificationCodeRegion = ZingTouch.Region(checkVerificationCode, false, false);
                  checkVerificationCodeRegion.bind(checkVerificationCode, 'swipe', function(event){ var direction = event.detail.data[0].currentDirection; if (direction > 225 && direction < 315) { $("#checkVerificationCodeHelp").slideUp("slow"); $('html').css({ "position": "relative"}); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)"}); } }, true);
                  $('#checkVerificationCodeHelpButton').click(function(){ $("#checkVerificationCodeHelp").slideDown("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" }); $('html').css({ "position": "fixed"}); });
                  $('#checkVerificationCodeHelp .helpDismiss').click(function(){ $("#checkVerificationCodeHelp").slideUp("slow"); $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" }); $('html').css({ "position": "relative"}); });
                  }
                  
                  });

