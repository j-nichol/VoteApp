$(document).ready(function(){
  $('copyVerificationCode').click(function(){
    $('verificationCode').select();
    document.execCommand("copy");
    toastr.options = {
    "closeButton": true,"progressBar": true,"preventDuplicates": true};
    toastr.success("has been copied to your clipboard.", "Verification Code");
    });
  });
