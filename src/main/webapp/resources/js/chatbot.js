$(function(){

$('#chat-inq-container').hide();
    let user_id = null; // 함수 스코프 또는 전역 스코프에 선언

  
    const userIdFromBodyData = document.body.dataset.currentUserId;
    if (userIdFromBodyData && !isNaN(parseInt(userIdFromBodyData, 10))) {
        user_id = parseInt(userIdFromBodyData, 10);
    }
//alert('USER_ID='+user_id)
allRecChatListByUser(user_id);
$('#chat-inq-container').hide();

$('.icon-button').click(function(){
location.href='mypage.do';
})

// //테스트
// $('.main_title').click(function(){
// alert(user_id);
// allRecChatListByUser(user_id);
// })


// 여행계획, 고객문의 클릭시 색바꾸고, container 변경
$('#travelTab').click(function(){
$('#supportTab').attr('class', 'tab-inactive');
$(this).attr('class', 'tab-active');

$('#chat-inq-container').hide();
$('#chat-reco-container').show();

allRecChatListByUser(user_id);
$('.message-input-wrapper').show();
})

$('#supportTab').click(function(){
$('#travelTab').attr('class', 'tab-inactive');
$(this).attr('class', 'tab-active');
$('#chat-reco-container').hide();
$('#chat-inq-container').show();

//고객문의 전체 기록 불러오기
allInqChatListByUser(user_id);
$('.message-input-wrapper').hide();
//$('#chat-inq-container').append(newButtons());
})

// 테마(가족, 커플, 혼자, 친구) 클릭 시 챗봇 요청 및 응답
$('.option-button').click(function(){
let clickMsg = $(this).text().trim()
let requestThemes = clickMsg+"갈 여행지를 추천해주세요. 100자 이내로 추천해주세요.";
userMsgRow(clickMsg);

$.ajax({
type:"get"
, data:{question:requestThemes}
, url: "http://127.0.0.1:5000"
, contentType: "application/x-www-form-urlencoded; charset=UTF-8"
, dataType: "text"
, success: function(result){
// gemini에서 받아오는 메세지
botMsgRow(result);
// 서버에 저장하기
let chatbot_resp = $('.chat-bubble:last').find('p').text();
insertRecoServer(user_id, clickMsg, chatbot_resp)
}
, error: function(err){
alert('실패');
console.log(err);
}

})

})

// '보내기' 클릭 시 메세지 입력으로 챗봇 요청 및 응답(엔터 키 눌렀을 때도 구현 해야함)
$('#send_btn').click(function(){
// 메세지 보내고 받는 함수 호출
conversation();
});

// 메세지 입력 후 엔터 입력으로 챗봇 요청 및 응답
$('.message-input').on('keydown', function(e){
if(e.key==='Enter' && !e.shiftKey) {
conversation();
}
})




$('#chat-inq-container').on('click', '.option-inq-button', function(){
let inqBtnStr = $(this).text().trim();

let keyOfInqTab = 1;
//////////인덱스가 아닌 text값으로 insert
if(inqBtnStr == '이용 문의') keyOfInqTab = 1;
else if(inqBtnStr == '신고 문의') keyOfInqTab = 2;
else if(inqBtnStr == '추천 문의') keyOfInqTab = 3;
else if(inqBtnStr == '관리자 문의') keyOfInqTab = 4;
else if(inqBtnStr == '결제 문의') keyOfInqTab = 5;
else if(inqBtnStr == '수정 문의') keyOfInqTab = 6;
else if(inqBtnStr == '탈퇴 문의') keyOfInqTab = 7;

//alert(keyOfInqTab)

// 고객이 클릭한 버튼 채팅창에 띄우기
let selectedBtn =$(`<div class="forEmpty chat-row chat-row-right">
<div class="chat-bubble-right">
<p class="chat-text-white">${inqBtnStr}</p>
</div>
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
</div>`);

$('#chat-inq-container').append(selectedBtn);


// 버튼에 대한 답변 가져와서 챗봇창에 띄우기
$.ajax({
type:"get"
, data:{inquiry_id:keyOfInqTab}
, url: 'inquiry'
, contentType: "application/x-www-form-urlencoded; charset=UTF-8"
, dataType: "json"
, success: function(result){
// 저장된 문의 답변 가져오기
let responseMsg = $(`<div class="forEmpty chat-row chat-row-left">
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
<div class="chat-bubble">
<p class="chat-text">${result['response']}</p>
</div>
</div>`);

$('#chat-inq-container').append(responseMsg);

//고객문의 시 대화내용 서버에 insert
insertInqServer(user_id, inqBtnStr, result['response'])

if(keyOfInqTab==4) {
$('#chat-inq-container').append(newButtons());


// *********관리자에 전달 구현해야함************
// 푸시알림,,되는지 확인해야함
if(Notification.permission === "granted") {
new Notification("새 1:1 문의 도착",{
body:"문의 확인"
,icon:""
});
}
// 또는 ajax이용,,되는지확인해야됨
// setInterval(function(){
// $.get('관리자가 받을 경로', function(newInqs){
// if(newInqs.length>0) {
// alert(`새 1:1문의가 ${newInqs.length}건 도착했습니다.`)
// }
// });
// }, 10000); //10초마다 확인
}
$('#chat-inq-container').scrollTop($('#chat-inq-container')[0].scrollHeight);
}
, error: function(err){
alert('실패');
console.log(err);
}

})
});



//*********functions**********
// gemini에서 받아오는 메세지 컨테이너에 띄우는 함수<div class="chat-content"></div>
function botMsgRow(msg) {
let responseMsg = $(`<div class="forEmpty chat-row chat-row-left">
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
<div class="chat-bubble">
<p class="chat-text">${msg}</p>
</div>
</div>`);

$('#chat-reco-container').append(responseMsg);
$('#chat-reco-container').scrollTop($('#chat-reco-container')[0].scrollHeight);
};

// 사용자가 보내는 함수 // 사용자 발송 메세지 변수(chat-avatar는 사용자 프로필사진으로 바꿔야함)
function userMsgRow(msg) {
let realsendMsg=$(`<div class="forEmpty chat-row chat-row-right">
<div class="chat-bubble-right">
<p class="chat-text-white">${msg}</p>
</div>
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
</div>`);

$('#chat-reco-container').append(realsendMsg);
$('#chat-reco-container').scrollTop($('#chat-reco-container')[0].scrollHeight);
$('.message-input').val('');
};

// (추천컨테이너)대화기록 전체 불러오기 함수
function allRecChatListByUser(id) {

$.ajax({
type:'get'
,url:`selectByUser`
,data:{user_id:id}
,dataType:'json'
,success: function(result){

$('#chat-reco-container .forEmpty').remove();
for(row of result) {
let record_conv=$(`<div class="forEmpty chat-row chat-row-right">
<div class="chat-bubble-right">
<p class="chat-text-white">${row['user_query']}</p>
</div>
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
</div>
<div class="forEmpty chat-row chat-row-left">
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
<div class="chat-bubble">
<p class="chat-text">${row['chatbot_resp']}</p>
</div>
</div>`);
$('#chat-reco-container').append(record_conv);
}

// 시작시 대화컨테이너 스크롤 제일 아래로
$('#chat-reco-container').scrollTop($('#chat-reco-container')[0].scrollHeight);

}
,error: function(err){
alert('대화내용 불러오기 실패');
console.log(err);
}
})

}

// (고객문의)대화기록 전체 불러오기 함수
function allInqChatListByUser(id) {

$.ajax({
type:'get'
,url:`inquiries`
,data:{user_id:id}
,dataType:'json'
,success: function(result){
console.log(result);

$('#chat-inq-container .forEmpty').remove();
for(row of result) {
let record_conv=$(`<div class="forEmpty chat-row chat-row-right">
<div class="chat-bubble-right">
<p class="chat-text-white">${row['user_query']}</p>
</div>
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
</div>
<div class="forEmpty chat-row chat-row-left">
<div class="chat-avatar">
<i class="ri-robot-line text-white"></i>
</div>
<div class="chat-bubble">
<p class="chat-text">${row['chatbot_resp']}</p>
</div>
</div>`);
$('#chat-inq-container').append(record_conv);
}

// 시작시 대화컨테이너 스크롤 제일 아래로
//$('#chat-inq-container').scrollTop($('#chat-inq-container')[0].scrollHeight);

}
,error: function(err){
alert('대화내용 불러오기 실패');
console.log(err);
}
})

}

// (추천컨테이너)메세지보내고 답변 주고 받는 함수
function conversation() {
//보낸 메세지 먼저 채팅창에 띄우기
let sendMsg = $('.message-input').val();
userMsgRow(sendMsg);

// jemini에 메세지 보내고 답변 받기(ajax)
let sendParam = { question : sendMsg+'. 100자 이내로 답변해주세요.'};

if(sendMsg != '') {
$.ajax({
type:'get'
,data: sendParam
,url: "http://127.0.0.1:5000"
,contentType: "application/x-www-form-urlencoded; charset=UTF-8"
,dataType:"text"
,success: function(result){
// gemini에서 받아오는 메세지
botMsgRow(result);
// 서버에 저장
let chatbot_resp = $('#chat-reco-container .chat-bubble:last').find('p').text();
insertRecoServer(user_id, sendMsg, chatbot_resp);
}
, error: function(err){
alert('실패');
console.log(err);
}
})
}else {
botMsgRow('구체적으로 답변해주세요!');
}

}

// (추천컨테이너)user_id, user_query, chatbot_resp -> INSERT
function insertRecoServer(userId, userReq, chatResp) {

    let user_id = null; // 함수 스코프 또는 전역 스코프에 선언

  
    const userIdFromBodyData = document.body.dataset.currentUserId;
    if (userIdFromBodyData && !isNaN(parseInt(userIdFromBodyData, 10))) {
        user_id = parseInt(userIdFromBodyData, 10);
    }

let param = {user_id:user_id , user_query: userReq , chatbot_resp:chatResp };

$.ajax({
type:'post'
,data: param
,url: `insertChat`
,contentType: "application/x-www-form-urlencoded; charset=UTF-8"
,success: function(){

}
,error: function(){
console.log(err);
}
})
};

// (고객문의) 관리자문의 클릭 시 새버튼들 띄우기
function newButtons() {
 let inqAdmin = $(`
   <div class="chat-row chat-row-left">
     <div class="chat-avatar">
       <i class="ri-robot-line text-white"></i>
     </div>
     <div class="chat-content">
       <div class="chat-options">
         <button class="option-inq-button">
           <i class="ri-group-line mr-2"></i>결제 문의
         </button>
         <button class="option-inq-button">
           <i class="ri-heart-line mr-2"></i>수정 문의
         </button>
         <button class="option-inq-button">
           <i class="ri-user-line mr-2"></i>탈퇴 문의
         </button>
         <button class="option-inq-button">
           <i class="ri-user-line mr-2"></i>관리자 문의
         </button>
       </div>
     </div>
   </div>
 `);
return inqAdmin;
}

// (고객문의) 서버에 INSERT
function insertInqServer(userId, userReq, chatResp) {

    let user_id = null; // 함수 스코프 또는 전역 스코프에 선언
    const userIdFromBodyData = document.body.dataset.currentUserId;
    if (userIdFromBodyData && !isNaN(parseInt(userIdFromBodyData, 10))) {
        user_id = parseInt(userIdFromBodyData, 10);
    }
let param = {user_id:user_id , user_query: userReq , chatbot_resp:chatResp };

$.ajax({
type:'post'
,data: param
,url: `insertInqChat`
,contentType: "application/x-www-form-urlencoded; charset=UTF-8"
,success: function(){

}
,error: function(){
console.log(err);
}
});
};
})