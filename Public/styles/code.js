$(document).ready(function(){
    $('#copyVerificationCode').click(function(){
    console.log("called");
    $('#verificationCode').select();
    document.execCommand("copy");
    toastr.options = {"closeButton": true,"progressBar": true,"preventDuplicates": true};
    toastr.success("has been copied to your clipboard.", "Verification Code");
  });
});
