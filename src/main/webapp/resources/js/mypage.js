$(function(){

let user_id = $('#user_id').val();
$('.trivy').click(function(){
location.href='/tripin/chatbot.do'
});

// 페이지 첫 화면
$('#place-saved').addClass("tab-active");
$('#content-inquiries').removeClass("tab-active");
$('#review-written').removeClass("tab-active");

$('#content-inquiries').hide();
$('#content-reviews').hide();

$('#content-places').show();


// 프로필 편집 눌렀을 때(프로필 편집 모달(팝업)띄우기)
$('#edit-profile-btn').click(function(){
$('#user_name').val($('#profile-name').text());
$('#password-input').val('');
$('#edit-password-btn').hide();
$('#update_pass_group').hide();

$('#profile-modal').fadeIn();
});

$('.close-btn').click(function () {
   $('#profile-modal').fadeOut();
});
// 모달 외부 클릭 시 모달 닫기
$(window).click(function (e) {
   if ($(e.target).is('#profile-modal')) {
     $('#profile-modal').fadeOut();
   }
});

// 프로필편집에서 비밀번호 유효성검사
$('#password-input').on('input', function(){
let password = $('#beforePass').val();
$('#edit-password-btn').hide();
$('#password').val(password);
$('#update_pass_group').hide();
$('#password-message').show();
if($(this).val() == $('#beforePass').val().trim()) {
$('#password-message').hide();
$('.submit-btn').prop('disabled', false);
$('#edit-password-btn').show();

$('#edit-password-btn').on('click', function(){
$(this).hide();
$('.submit-btn').prop('disabled', true);
$('#update_pass_group').show();
// 초기화
   $('#update_pass').val('');
   $('#update_pass_confirm').val('');

});

// 실시간 비밀번호 수정 확인 검사
$('#update_pass, #update_pass_confirm').on('input', function(){
const newPass = $('#update_pass').val();
   const confirmPass = $('#update_pass_confirm').val();
   
   if(newPass && confirmPass && newPass === confirmPass) {
    $('#password').val(newPass);
    $('.submit-btn').prop('disabled', false);
   }else {
    $('.submit-btn').prop('disabled', true);
   }
   if (newPass !== confirmPass) {
       $('#password-message').text('비밀번호가 일치하지 않습니다.').show();
   } else {
       $('#password-message').hide();
   }
});

}
})


// 저장한 여행지, 저장한 테마, 내가 작성한 리뷰 버튼 클릭 이벤트(탭팬)
$('#place-saved').click(function(){
$(this).addClass("tab-active");
$('#my-inquiries').removeClass("tab-active");
$('#review-written').removeClass("tab-active");

$('#content-inquiries').hide();
$('#content-reviews').hide();



$('#content-places').show();

})

$('#my-inquiries').click(function(){
$(this).addClass("tab-active");
$('#place-saved').removeClass("tab-active");
$('#review-written').removeClass("tab-active");

$('#content-reviews').hide();
$('#content-places').hide();

$('#content-inquiries').show();
})

$('#review-written').click(function(){
$(this).addClass("tab-active");
$('#place-saved').removeClass("tab-active");
$('#my-inquiries').removeClass("tab-active");

$('#content-places').hide();
$('#content-inquiries').hide();

$('#content-reviews').show();
})


// 저장한 여행지에서 '상세정보' 클릭 시(여행지 정보 페이지로 이동)
$('#content-saved').on('click', '.detail-button', function(){

let dest_id = $(this).parents('.place-card').find('.dest_id').val();
//alert(dest_id);
// 상세정보 이동
location.href = `destinationdetail.do?dest_id=${dest_id}`;

})


// 저장한 여행지에서 하트 눌렀을 시 (true/false로 설정) user_id까지 같이 보내서 즐겨찾기에서 삭제
$('#content-saved').on('click', '.heart-button', function(){

const heartIcon = $(this).find('i');
   const isFilled = heartIcon.hasClass('ri-heart-fill');

   heartIcon
       .removeClass(isFilled ? 'ri-heart-fill' : 'ri-heart-line')
       .addClass(isFilled ? 'ri-heart-line' : 'ri-heart-fill');
   
   if(heartIcon.hasClass('ri-heart-line')) {
    let dest_id_tag = $(this).parents('.place-card').find('.dest_id');
    let param = {user_id :user_id ,dest_id:dest_id_tag.val()};
    console.log(param)
$.ajax({
type:'get'
, data: param
, url: 'deleteBookmark'
, success: function(){
dest_id_tag.parents('.place-card').remove();
// 또는 로케이션 자기 자신으로=>jsp의 forEach문 다시 실행되나 확인해야됨
//location.href="mypage.do";
}
, error: function(err){
alert('저장한 여행지 삭제 실패')
}
})
   }
   

})

// 내가 작성한 리뷰에서 수정 눌렀을 시(동적요소 클릭이벤트 활용)
$('#content-reviews').on('click', '.update', function(){
let beforeUpdateText = $(this).parents('.review-card').find('p').text();
$(this).parents('.review-card').find('p').text('');
let updateText = $('<textarea class="updateText"/>');

$(this).parents('.review-card').find('p').append(updateText);
updateText.text(beforeUpdateText);

$(this).text('수정하기')
$(this).removeClass('update').addClass('modify');
})


// 수정 누른 후 수정하기 눌렀을 시
$('#content-reviews').on('click', '.modify', function(){

$(this).html('<i class="ri-edit-line mr-1"></i> 수정');
$(this).removeClass('modify').addClass('update');

let afterUpdateText = $('.updateText').val();
$(this).parents('.review-card').find('p').text(afterUpdateText);


// 나중에 ajax로 보내야되는 데이터: review_id, updateText.val()
//let param = { review_id : ??, contents: updateText.val() };
})


// 내가 작성한 리뷰에서 삭제 눌렀을 시(동적요소 클릭이벤트 활용)
$('#content-reviews').on('click', '.delete', function(){

let review_id=$(this).parents('.review-card').find('input[class="review_id"]');
//alert(review_id.val())
let param = { review_id : review_id.val()};
// ajax로 보내야되는 데이터: review_id
$.ajax({
type:'post'
,data: param
,url:'deletereview'
,success: function(){
review_id.parents('.review-card').remove();
}
,error: function(err){
alert('리뷰 삭제 실패');
console.log(err);
}
})

})

// 문의 사항 삭제 버튼
$('#content-inquiries').on('click', '.delete_inquiry', function(){
let chat_inq_id = $(this).parents('.inquiry-card').find('input[class="chat_inq_id"]').val();
alert(chat_inq_id)
$.ajax({
type:"get"
, data: {chat_inq_id:chat_inq_id}
, url: "deleteinquiry"
, success:function(){
$(this).parents('.inquiry-card').remove();
}
, error:function(err){
alert('문의 삭제 실패');
console.log(err);
}
})

})

})
