// place_list.js 전체 복붙

$(function(){

var loadMoreBtn = $('.load-more-wrapper');
var maxloaded = 6;
var currentLoaded = 0;
let userId = null; 
const userIdFromBodyData = document.body.dataset.currentUserId;
if (userIdFromBodyData && !isNaN(parseInt(userIdFromBodyData, 10))) {
        userId = parseInt(userIdFromBodyData, 10);
 }

//alert(userId);

// const contextPath = '${pageContext.request.contextPath}';

//카드 수 6개 제한 함수
function showNextCards(){
var cards = $('.place-card');
var nextLoaded = maxloaded + currentLoaded;

cards.slice(currentLoaded, nextLoaded).fadeIn();
currentLoaded = nextLoaded;

//모두 보이면 더보기 버튼 숨기기
if(currentLoaded >= cards.length) {
$('.load-more-wrapper').hide();
} else {
$('.load-more-wrapper').show();
}
};

showNextCards();

//여행지 카드 수 제한 (페이지 로딩 시)
var initialCards = $('.place-card');
initialCards.each(function(index){
if(index >= maxloaded){
$(this).hide();
}
});
currentLoaded = Math.min(initialCards.length, maxloaded);




//테마버튼 클릭시 음영
$('.theme-button').on('click', function(){
$('.theme-button').removeClass('active');
$(this).addClass('active');



//선택한 테마 텍스트
var theme = $(this).children('span').text().trim();
//alert(theme);

//선택한 테마의 data-value 값
var selectedTheme = $(this).children('span').attr('data-value');
console.log(selectedTheme);



$('#theme_id').val(selectedTheme); //theme_id value값 설정

//현재 선택된 필터값 유지
var selectedSort = $('#selectedSort').text().trim();
$('#sort').val(selectedSort);

// $('#filter-form').submit(); //submit

//테마 클릭시 조회수 증가
$.ajax({
type : 'post'
, url : 'place_list/updateViewCnt'
, data : {theme_id : parseInt(selectedTheme)}
, success : function(){
//console.log("조회수증가성공");
}
, error : function(err){
console.log(err);
//console.log("조회수증가실패");
}

});//end of ajax count view

// //url 파라미터 숨기기
// history.replaceState({},'',location.pathname);

//클릭한 테마에 맞는 db값 출력
$.ajax({
type : 'get'
, url : 'place_list/json'
, data : {theme_id : parseInt(selectedTheme)}
, success : function(result){
//console.log(result);
//여행지 카드 기존 목록 제거
$('.result-bar').empty();
//카드 수 초기화
currentLoaded = 0;

//받아온 여행지 데이터 카드 형태로 추가
$.each(result, function(index, place){
//result : ajax응답으로 받은 여행지 배열
// index : 배열 내 현재 반복 순서
// place : 배열 안 각 여행지 객체
const imgHtml = place.repr_img_url
       ? `<img class="place-img" src="${place.repr_img_url}" alt="${place.dest_name}">`
       : `<div class="skeleton-img shimmer"></div>`;

   const html = `
       <div class="place-card" style="display: none;"
    data-dest-id="${place.dest_id}">
           ${imgHtml}
           <button class="bookmark" type="button">
               <i class="ri-heart-line"></i>
           </button>
           <div class="place-content">
               <h3 class="place-title">${place.dest_name}</h3>
               <p class="place-text">${place.rel_keywords || ''}</p>
           </div>
           <div class="place-info">
               <div class="place-info-left">
                   <div class="map-pin">
                       <i class="ri-map-pin-line"></i>
                   </div>
                   <span>${place.full_address}</span>
               </div>
               <div class="place-info-right">
                   <div class="star">
                       <i class="ri-star-fill"></i>
                   </div>
                   <span class="place-rate">4.8</span>
                   <span class="place-review-cnt">(256)</span>
               </div>
           </div>
       </div>
   `;
   
   $('.result-bar').append(html);
}); //end of each

const cardCount = $('.place-card').length;
//카드 수 제한 적용
if(cardCount <= maxloaded) {
$('.place-card').fadeIn();
$('.load-more-wrapper').hide();
currentLoaded = cardCount;
}else {
showNextCards();
}
}
, error : function(err){
console.log(err);
}

}); //end of ajax

});


//더보기 버튼 클릭시 6개 추가 로딩
loadMoreBtn.on('click', function(){
showNextCards();
});



//정렬기준 선택
$('#sort-button').on('click', function(){
//alert("ok");
$('#dropdown-menu').toggle();
});

$('.dropdown-item').on('click', function(){
var selectedSort = $(this).data('value'); //data-value값 얻어오기
//alert(selected);
$('#selectedSort').text(selectedSort).data('value', selectedSort); //선택한 값으로 text, value 변경
$('#dropdown-menu').hide(); //선택 후 드롭다운메뉴 숨기기

$('#sort').val(selectedSort); //sort value값 설정

//현재 선택된 테마값 유지
var selectedTheme = $('.theme-button.active').find('span').text().trim();
$('#theme').val(selectedTheme);

//url 파라미터 숨기기
// history.replaceState({},'',location.pathname);

// $('#filter-form').submit(); //submit

//정렬 기준 db값
$.ajax({
type : 'get'
, url : 'place_list/json'
, data :  {sort : selectedSort}
, success : function(result){
$('.result-bar').empty();
currentLoaded = 0;
//받아온 여행지 데이터 카드 형태로 추가
$.each(result, function(index, place){
//result : ajax응답으로 받은 여행지 배열
// index : 배열 내 현재 반복 순서
// place : 배열 안 각 여행지 객체
const imgHtml = place.repr_img_url
       ? `<img class="place-img" src="${place.repr_img_url}" alt="${place.dest_name}">`
       : `<div class="skeleton-img shimmer"></div>`;

   const html = `
       <div class="place-card" style="display: none;"
    data-dest-id="${place.dest_id}">
           ${imgHtml}
           <button class="bookmark" type="button">
               <i class="ri-heart-line"></i>
           </button>
           <div class="place-content">
               <h3 class="place-title">${place.dest_name}</h3>
               <p class="place-text">${place.rel_keywords || ''}</p>
           </div>
           <div class="place-info">
               <div class="place-info-left">
                   <div class="map-pin">
                       <i class="ri-map-pin-line"></i>
                   </div>
                   <span>${place.full_address}</span>
               </div>
               <div class="place-info-right">
                   <div class="star">
                       <i class="ri-star-fill"></i>
                   </div>
                   <span class="place-rate">4.8</span>
                   <span class="place-review-cnt">(256)</span>
               </div>
           </div>
       </div>
   `;
   
   $('.result-bar').append(html);
}); //end of each

const cardCount = $('.place-card').length;
//카드 수 제한 적용
if(cardCount <= maxloaded) {
$('.place-card').fadeIn();
$('.load-more-wrapper').hide();
currentLoaded = cardCount;
}else {
showNextCards();
}
}
, error : function(err){
console.log(err);
}
});
})


//필터 초기화 누르면 테마 삭제 / 정렬기준 초기화 -> db결과 초기화
$('.reset-button').on('click', function(){
$('.filter-tag').hide();
$('.theme-button').removeClass('active');
$('#selectedSort').text('인기순').data('value', '인기순');


})

//여행지 결과 좋아요버튼 토글
$('.result-bar').on('click', '.bookmark i', function(event) {
   event.stopPropagation(); // 카드 클릭 이벤트 차단
   var dest_id = $(this).parents(".place-card").data('dest-id');
    //alert(dest_id);
   let currThis = $(this);
   
   if ($(this).hasClass('ri-heart-line')) {
       let param = {user_id : userId , dest_id : dest_id};
       console.log(param);
       //북마트 버튼 클릭시 user당 북마크값 저장
       $.ajax({
        type : 'get'
        , url : 'bookmarkPlace'
        , data : param
        , success : function(){
        currThis.removeClass('ri-heart-line').addClass('ri-heart-fill text-red-500');
       
        }
        , error : function(err){
        console.log(err);
        }
       });
   } else {
    //북마크 해제할 경우
    $.ajax({
    type : 'get'
    , url : 'deleteBookmark'
    , data : {user_id : userId , dest_id : dest_id}
    , success  : function(){
    currThis.removeClass('ri-heart-fill text-red-500').addClass('ri-heart-line');    
    }
    , error : function(err){
    console.log(err);
    }
    })
       
   }
});

$(".result-bar").on('click','.bookmark',function(event){
event.stopPropagation();
})

// 카드 클릭 시 상세 페이지로 이동 (북마크 클릭은 예외 처리)
$('.result-bar').on('click', '.place-card', function(event) {
   if ($(event.target).closest('.bookmark').length > 0) return; // 북마크 클릭이면 무시

   const destId = $(this).data('dest-id');
   location.href = 'destinationdetail.do?dest_id=' + destId;
});



});