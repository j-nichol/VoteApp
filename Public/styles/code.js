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
                  
                  var containerElement = document.getElementById('orangeHelp');
                  var activeRegion = ZingTouch.Region(containerElement);
                  
                  activeRegion.bind(containerElement, 'swipe', function(event){
                                    console.log(event);
                                    if (event.direction > 225 && event.direction < 315) {
                                      $("#orangeHelp").slideUp("slow");
                                      $('html').css({ "position": "relative"})
                                      $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" });
                                    }
                                    });
                  
                  
//                  $('#orangeHelp').on('swipedown',function (e,data){
//                                      console.log(e);
//                                      $("#orangeHelp").slideUp("slow");
//                                      $('html').css({ "position": "relative"})
//                                      $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" });
//                                      });
                  
                  $('#orangeHelpButton').click(function(){
                                               $("#orangeHelp").slideDown("slow");
                                               $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(31px)" });
                                               $('html').css({ "position": "fixed"})
                                               });
                  
                  $('#orangeHelp .helpDismiss').click(function(){
                                                      $("#orangeHelp").slideUp("slow");
                                                      $(".helpWindow").css({ "-webkit-backdrop-filter": "blur(30px)" });
                                                      $('html').css({ "position": "relative"})
                                                      });
                  
});
