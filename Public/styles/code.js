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
                  
                  $('#orangeHelp').on('swipedown',function (e,data){
                                      $("#orangeHelp").slideUp("slow");
                                      });
                  
                  $('#orangeHelpButton').click(function(){
                                               $("#orangeHelp").slideDown("slow");
                                               $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" });
                                               });
                  
                  $('#orangeHelp .helpDismiss').click(function(){
                                                      $("#orangeHelp").slideUp("slow");
                                                      });
                  
                  $('.helpWindow').on('touchmove', function(e) {
                                      e.preventDefault();
                                      e.stopPropagation();
                                      return false;
                                      });
});

