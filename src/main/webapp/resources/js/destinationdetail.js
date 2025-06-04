// ------------------------------------------------------------------
// 전역 변수 및 상수
// ------------------------------------------------------------------



let map; // 카카오 지도 인스턴스
let ps; // 카카오 장소 검색 서비스 객체
let currentMarkers = []; // 현재 메인 지도에 표시된 마커들
let mapCenter = null; // 메인 지도의 중심 좌표
let isMapSdkReady = false; // 카카오 맵 SDK 로드 완료 여부 플래그
let activeInfowindow = null; // 현재 메인 지도에 열려있는 인포윈도우

// JSP에서 가져온 상수들 (DOMContentLoaded에서 초기화)
let contextPath = '';
let loginUserId = null;
let userIdFromBodyData = document.body.dataset.loginUserId;
if (userIdFromBodyData) {
    loginUserId = parseInt(userIdFromBodyData, 10); // 재선언 없이 값 할당
} else {
    loginUserId = null;
}
let destId = ''; // 현재 여행지 ID

// 리뷰 이미지 모달용 변수
let reviewImageIndex = 0;
let reviewImageList = [];
let reviewData = null; // 현재 리뷰 이미지 모달의 {userId, created} 정보 저장

// 메인 여행지 이미지 모달용 변수
let mainImageIndex = 0;
let mainImageList = [];

// 모달의 보류 중인 액션용 변수
let pendingDeleteReviewId = null;
let pendingReportReviewId = null;

//------------------------------------------------------------------
//카카오 맵 SDK 로드 및 초기화
//------------------------------------------------------------------
if (typeof kakao !== 'undefined' && kakao.maps && typeof kakao.maps.load === 'function') {
console.log('kakao.maps.load 함수 감지. 지도 초기화 시도.');
kakao.maps.load(function () {
 console.log('카카오 맵 SDK 로드 완료.');
 isMapSdkReady = true;
 document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = false; }); // SDK 로드 후 카테고리 버튼 활성화

 function attemptInitMap() {
   const detailSectionElement = document.getElementById('detailSection'); // 원본 id 유지
   const placeName = document.body.dataset.name; // body 태그의 data-name 속성에서 여행지 이름 가져오기

   // 상세 섹션이 표시되어 있고, 여행지 이름이 있을 때만 지도 초기화
   if (detailSectionElement && !detailSectionElement.classList.contains('hidden')) {
     if (placeName && placeName.trim() !== "") {
       console.log("detailSection 활성화 및 여행지 이름 존재. initMap 호출.");
       initMap(); // 지도 초기화 함수 호출
     } else {
       console.warn("detailSection은 활성화되었으나 여행지 이름(data-name)이 없어 initMap을 호출하지 않습니다.");
       const mapContainer = document.getElementById('map'); // 원본 id 유지
       if (mapContainer) {
         mapContainer.innerHTML = '<p class="text-center text-gray-500 p-8">표시할 여행지 정보가 없습니다.</p>';
       }
       document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = true; }); // 중심 좌표 없으면 카테고리 버튼 비활성화
     }
   } else {
     console.log("detailSection이 숨겨져 있어 initMap을 호출하지 않습니다.");
   }
 }

 // DOM이 로딩 중이면 DOMContentLoaded 이벤트 발생 후 지도 초기화 시도
 if (document.readyState === 'loading') {
   document.addEventListener('DOMContentLoaded', attemptInitMap);
 } else {
   attemptInitMap(); // 이미 DOM이 준비되었으면 바로 시도
 }
});
} else {
console.error('카카오 맵 SDK가 제대로 로드되지 않았거나 kakao.maps.load 함수를 찾을 수 없습니다. HTML의 SDK 스크립트 태그를 확인하세요.');
const mapElement = document.getElementById('map'); // 원본 id 유지
if (mapElement) {
 mapElement.innerHTML = '<p class="text-center text-red-500 p-8">지도 서비스 로드 실패.</p>';
}
if (typeof showToast === 'function') { // 원본 함수명 유지
 showToast("지도 서비스를 사용할 수 없습니다. SDK 로드 오류.", 5000); // showToast 함수는 전역에 있다고 가정
} else {
 console.error("showToast is not defined. 지도 서비스 로드 오류 알림 불가.");
}
document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = true; }); // SDK 로드 실패 시 카테고리 버튼 비활성화
}

//------------------------------------------------------------------
//지도 관련 함수 (메인 상세 지도)
//------------------------------------------------------------------
function initMap() { // 원본 함수명 유지
const placeName = document.body.dataset.name;
const mapContainer = document.getElementById('map'); // 원본 id 유지

if (!mapContainer) {
 console.error("지도 컨테이너(id='map')를 찾을 수 없습니다.");
 return;
}
if (!placeName || placeName.trim() === "") {
 console.error("여행지 이름(data-name)이 body에 없거나 비어있습니다.");
 mapContainer.innerHTML = '<p class="text-center text-red-500 p-4">표시할 여행지 정보가 없습니다.</p>';
 document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = true; });
 return;
}
// 카카오 맵 서비스 API 로드 확인
if (typeof kakao === 'undefined' || !kakao.maps || !kakao.maps.services) {
 console.error("카카오 맵 서비스 API가 로드되지 않았습니다. (initMap 내부)");
 if (typeof showToast === 'function') {
     showToast("지도 서비스 초기화에 실패했습니다. 페이지를 새로고침 해주세요.");
 }
 mapContainer.innerHTML = '<p class="text-center text-red-500 p-4">지도 서비스 초기화 실패.</p>';
 document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = true; });
 return;
}

ps = new kakao.maps.services.Places(); // 장소 검색 객체 생성
mapContainer.innerHTML = '<p class="text-center text-gray-500 p-8">지도 로딩 중...</p>'; // 로딩 메시지 표시

// 키워드로 장소 검색
ps.keywordSearch(placeName, function (data, status) {
 if (status === kakao.maps.services.Status.OK) {
   if (data.length === 0) {
     console.warn(`'${placeName}'에 대한 지도 정보를 찾을 수 없습니다.`);
     if (typeof showToast === 'function') {
         showToast(`'${placeName}' 지도 정보 없음.`);
     }
     if (mapContainer) {
         mapContainer.innerHTML = `<p class="text-center text-gray-500 p-4">'${placeName}'에 대한 지도 정보가 없습니다.</p>`;
     }
     mapCenter = null;
     document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = true; });
     return;
   }
   const firstResult = data[0];
   mapCenter = new kakao.maps.LatLng(parseFloat(firstResult.y), parseFloat(firstResult.x)); // 검색 결과의 첫 번째 장소로 중심 좌표 설정

   mapContainer.innerHTML = ''; // 로딩 메시지 제거
   map = new kakao.maps.Map(mapContainer, { // 지도 생성
     center: mapCenter,
     level: 5 // 기본 확대 레벨
   });
   
   // 메인 장소 자체에 마커 추가
   new kakao.maps.Marker({
     map: map,
     position: mapCenter,
     title: placeName
   });

   // 카테고리 버튼 활성화 및 이벤트 핸들러 설정
   document.querySelectorAll('.category-btn').forEach(btn => {
     btn.disabled = false;
     btn.onclick = function() { 
       if (!isMapSdkReady || !mapCenter) {
           if (typeof showToast === 'function') {
             showToast("지도가 아직 준비되지 않았습니다.");
           }
           return;
       }
       const category = this.getAttribute('data-category');
       searchNearbyPlaces(category); 
     };
   });
 } else { // 장소 검색 실패 시
   mapCenter = null;
   if (typeof showToast === 'function') {
     showToast("지도 중심 설정 실패: " + status);
   }
   if (mapContainer) {
     mapContainer.innerHTML = `<p class="text-center text-red-500 p-4">장소 검색 실패: ${status}</p>`;
   }
   document.querySelectorAll('.category-btn').forEach(btn => { btn.disabled = true; });
 }
});
}

//주변 장소 검색 (음식점, 숙소, 관광지 등)
function searchNearbyPlaces(category) { // 원본 함수명 유지
if (!isMapSdkReady) { if (typeof showToast === 'function') { showToast("지도 서비스 미준비."); } return; }
if (!mapCenter) { if (typeof showToast === 'function') { showToast("지도 중심 정보 없음."); } return; }
if (!ps) { if (typeof showToast === 'function') { showToast("장소 검색 서비스 미준비."); } return; }

clearMarkersAndInfowindow(); 
const placeListContainer = document.getElementById('placeList'); // 원본 id 유지
if (placeListContainer) {
 placeListContainer.innerHTML = '<p class="text-center text-gray-400 py-4">주변 장소 검색 중...</p>';
}

// 카테고리로 장소 검색 (반경 1km)
ps.categorySearch(category, function (data, status) {
 if (status === kakao.maps.services.Status.OK) {
   displayNearbyPlaces(data); 
 } else {
   console.warn("카테고리 검색 실패, 상태:", status);
   if (typeof showToast === 'function') {
     showToast("주변 장소 검색 실패: " + status);
   }
   if (placeListContainer) {
     placeListContainer.innerHTML = `<p class="text-center text-red-500 p-4">검색 실패: ${status}</p>`;
   }
 }
}, { location: mapCenter, radius: 1000 });
}

//검색된 주변 장소들을 지도와 목록에 표시
function displayNearbyPlaces(places) { // 원본 함수명 유지
const placeListContainer = document.getElementById('placeList'); // 원본 id 유지
if (!placeListContainer) { console.error("id='placeList' 요소 없음."); return; }
placeListContainer.innerHTML = ''; 

if (!places || places.length === 0) {
 placeListContainer.innerHTML = '<p class="text-center text-gray-500 p-4">주변에 해당 카테고리의 장소가 없습니다.</p>';
 return;
}

places.forEach((place) => { // place는 카카오 API 응답 객체 (camelCase 필드 사용)
 const placeItem = document.createElement('div');
 placeItem.className = "px-3 py-2.5 bg-gray-50 border border-gray-200 rounded-md shadow-sm hover:bg-indigo-50 hover:border-indigo-300 cursor-pointer transition-all duration-150 ease-in-out";
 
 let contentHTML = `<strong class="text-indigo-600 font-semibold">${place.place_name}</strong>`;
 if (place.category_name) {
     const categories = place.category_name.split('>').map(c => c.trim());
     contentHTML += `<span class="block text-xs text-gray-500 mt-0.5">${categories[categories.length - 1]}</span>`; 
 }
 if (place.road_address_name || place.address_name) {
     contentHTML += `<span class="block text-xs text-gray-600 mt-1">${place.road_address_name || place.address_name}</span>`; 
 }
 placeItem.innerHTML = contentHTML;

 // 지도에 마커 생성
 const marker = new kakao.maps.Marker({
   map: map,
   position: new kakao.maps.LatLng(place.y, place.x),
   title: place.place_name
 });
 currentMarkers.push(marker); 

 // 목록 아이템 클릭 시 해당 장소로 지도 이동 및 인포윈도우 표시
 placeItem.addEventListener('click', () => {
   if (map && marker) {
     const moveLatLon = new kakao.maps.LatLng(place.y, place.x);
     map.panTo(moveLatLon); 
     map.setLevel(3, {animate: true}); 

     if (activeInfowindow) { 
       activeInfowindow.close();
     }
     // 새 인포윈도우 생성 및 표시
     const infowindow = new kakao.maps.InfoWindow({
         content: `<div style="padding:5px;font-size:12px;min-width:150px;text-align:center;">${place.place_name}</div>`,
         removable: true 
     });
     infowindow.open(map, marker);
     activeInfowindow = infowindow; 
   }
 });
 placeListContainer.appendChild(placeItem); 
});
}

//지도에서 마커와 인포윈도우 제거
function clearMarkersAndInfowindow() { // 원본 함수명 유지
currentMarkers.forEach(marker => { marker.setMap(null); }); 
currentMarkers = []; 
if (activeInfowindow) { 
   activeInfowindow.close();
   activeInfowindow = null;
}
}

//------------------------------------------------------------------
//메인 검색 섹션 함수 (상단 검색창 및 해시태그)
//------------------------------------------------------------------
//키워드로 장소 검색 (메인 검색창에서 사용)
function searchPlaceByKeyword(keyword) { // 원본 함수명 유지
if (!keyword) {
 showToast("검색어를 입력하세요.");
 return;
}
$.ajax({
 url: `${contextPath}/searchPlace`,
 type: 'GET',
 data: { keyword: keyword }, // Controller: @RequestParam("keyword")
 success: function(data) { // data는 서버 응답 PlaceVO[] (snake_case 필드)
   if (!data || data.length === 0) {
     showToast("해당 여행지가 없습니다.");
     return;
   }
   showSearchModal(data, keyword);
 },
 error: function() {
   showToast("서버 오류로 검색 실패");
 }
});
}


//검색 결과 모달 표시
function showSearchModal(data, keyword) { // data는 PlaceVO[] (snake_case 필드)
const modal = document.getElementById('searchModal'); // 원본 id 유지
const listContainer = document.getElementById('searchList'); 
const mapContainer = document.getElementById('modalMap');   
const keywordDisplay = document.getElementById('searchKeywordDisplay'); 

if (!modal || !listContainer || !mapContainer || !keywordDisplay) { return; } 

keywordDisplay.textContent = keyword; 
listContainer.innerHTML = ''; 
mapContainer.innerHTML = ''; 

modal.classList.remove('hidden'); 

// 모달 내 지도 초기화
const modalMapInstance = new kakao.maps.Map(mapContainer, {
 center: new kakao.maps.LatLng(37.5665, 126.9780), 
 level: 7 
});
const modalPs = new kakao.maps.services.Places(); 
const bounds = new kakao.maps.LatLngBounds(); 
const modalMarkers = []; 
const modalInfowindows = []; 

data.forEach((item, idx) => { // item은 PlaceVO (snake_case 필드)
 const destName = item.dest_name; // 서버 응답 PlaceVO의 필드명 사용
 if (!destName) { return; } 

 // 각 아이템에 대해 다시 키워드 검색하여 정확한 좌표 얻기 (데이터에 좌표가 없을 경우)
 modalPs.keywordSearch(destName, function(result, status) {
   if (status === kakao.maps.services.Status.OK && result.length > 0) {
     const firstResult = result[0];
     const pos = new kakao.maps.LatLng(firstResult.y, firstResult.x);
     bounds.extend(pos); 

     // 모달 지도에 마커 생성
     const marker = new kakao.maps.Marker({
       map: modalMapInstance,
       position: pos,
       title: destName
     });
     modalMarkers[idx] = marker;

     // 모달 지도에 인포윈도우 생성
     const infowindow = new kakao.maps.InfoWindow({
       content: `<div style="font-size:13px; padding:5px; min-width:150px; text-align:center;">${destName}</div>`
     });
     modalInfowindows[idx] = infowindow;

     // 마커 클릭 시 인포윈도우 표시
     kakao.maps.event.addListener(marker, 'click', function() {
       modalInfowindows.forEach(iw => { iw.close(); }); 
       infowindow.open(modalMapInstance, marker);
     });

     // 모달 목록에 아이템 생성
     createSearchModalListItem(idx, destName, marker, infowindow, pos, item, listContainer, modalMapInstance, modalInfowindows);
   }
   // 모든 검색이 완료된 후 지도 범위 조정 (비동기 호출이므로 타이밍 주의)
   if (idx === data.length - 1) {
     setTimeout(() => { 
         if (!bounds.isEmpty()) { 
              modalMapInstance.setBounds(bounds);
         }
     }, 300); 
   }
 });
});
}

//검색 결과 모달의 각 목록 아이템 생성
function createSearchModalListItem(idx, destName, marker, infowindow, pos, item, listContainer, modalMapInstance, modalInfowindows) { // item은 PlaceVO
const el = document.createElement('div');
el.className = "flex items-center justify-between px-4 py-3 bg-gray-100 hover:bg-primary/10 rounded cursor-pointer transition mb-2";

// 장소명 (클릭 시 지도 이동)
const nameDiv = document.createElement('div');
nameDiv.textContent = destName;
nameDiv.className = "font-semibold flex-1 text-center cursor-pointer";
nameDiv.onclick = function() {
 modalInfowindows.forEach(iw => { iw.close(); }); 
 modalMapInstance.panTo(pos); 
 modalMapInstance.setLevel(5); 
 infowindow.open(modalMapInstance, marker); 
};

// 상세 보기 버튼
const detailBtn = document.createElement('button');
detailBtn.className = "ml-2 px-3 py-1 text-sm bg-primary text-white rounded shadow hover:bg-primary/80";
detailBtn.textContent = "상세";
detailBtn.onclick = function(e) {
 e.stopPropagation(); 
 // Controller는 URL 파라미터로 "dest_id"를 기대 (ReviewController.destinationDetail @RequestParam("dest_id"))
 window.location.href = `${contextPath}/destinationdetail?dest_id=${encodeURIComponent(item.dest_id)}`; 
};

el.appendChild(nameDiv);
el.appendChild(detailBtn);
listContainer.appendChild(el); 
}

//검색 모달 닫기
window.closeModal = function() { // 원본 함수명 유지
const modal = document.getElementById('searchModal'); // 원본 id 유지
if (modal) {
 modal.classList.add('hidden');
}
};

//랜덤 해시태그 로드 (메인 검색 페이지용)
function loadRandomHashtags() { // 원본 함수명 유지
const container = document.getElementById('hashtagContainer'); // 원본 id 유지
if (!container) { return; } 

$.get(`${contextPath}/randomDestNames`, function(data) { 
 container.innerHTML = ''; 
 data.forEach(tag => {
   const a = document.createElement('a');
   a.href = '#';
   a.textContent = `#${tag}`; 
   a.className = 'hashtag px-5 py-2 bg-primary text-white rounded-full hover:bg-primary/90'; 
   a.addEventListener('click', function (e) { 
     e.preventDefault();
     $('#mainSearch').val(tag); // 원본 id 유지 (jQuery selector)
     searchPlaceByKeyword(tag); 
   });
   container.appendChild(a); 
 });
});
}

//------------------------------------------------------------------
//상세 정보 섹션 함수
//------------------------------------------------------------------
//좋아요 버튼 클릭 처리
function handleLikeButtonClick() { // 원본 함수명 유지
const likeBtn = document.getElementById("likeBtn"); // 원본 id 유지
const likeIcon = document.getElementById("likeIcon"); // 원본 id 유지

if (likeBtn && likeIcon && destId && loginUserId) { 
 $.ajax({
   url: `${contextPath}/toggleLike`, 
   method: "POST",
   data: { // Controller: @RequestParam("user_id"), @RequestParam("dest_id")
     user_id: loginUserId, 
     dest_id: destId      
   },
   success: function (res) { 
     if (res === "liked") {
       likeIcon.classList.remove("ri-heart-line"); 
       likeIcon.classList.add("ri-heart-fill");
     } else if (res === "unliked") {
       likeIcon.classList.remove("ri-heart-fill"); 
       likeIcon.classList.add("ri-heart-line");
     } else {
       showToast("예상치 못한 응답: " + res);
     }
   },
   error: function () {
     showToast("좋아요 처리 중 오류 발생");
   }
 });
} else if (!loginUserId) { 
 showToast("로그인이 필요합니다.");
}
}

//정보 탭 (기본정보, 이용안내, 상세정보) 설정
function setupInformationTabs() { // 원본 함수명 유지
document.querySelectorAll('.tab-btn[data-tab]').forEach(btn => {
 btn.addEventListener('click', () => {
   const targetTabId = btn.dataset.tab; 
   document.querySelectorAll('.tab-btn[data-tab]').forEach(b => { b.classList.remove('active', 'text-primary', 'border-primary'); });
   btn.classList.add('active', 'text-primary', 'border-primary');
   document.querySelectorAll('.tab-content').forEach(tc => { tc.classList.add('hidden'); });
   const targetContent = document.getElementById(`tab-${targetTabId}`); // 원본 id (tab-info 등) 유지
   if (targetContent) {
     targetContent.classList.remove('hidden');
   }
 });
});
const firstInfoTab = document.querySelector('.tab-btn[data-tab="info"]');
if (firstInfoTab) {
 firstInfoTab.click(); 
}
}

//스크롤 이동 탭 (여행지 위치, 여행지 후기, 리뷰작성 - 상단 네비게이션형 탭)
window.scrollToSection = function(sectionId) { // 원본 함수명 유지
 const targetElement = document.getElementById(sectionId); // 원본 id 유지 (infoSection 등)
 if (!targetElement) { return; }

 targetElement.scrollIntoView({ behavior: 'smooth', block: 'start' }); 

 // 해당 탭 버튼 스타일 업데이트
 document.querySelectorAll('.tab-btn-style').forEach(btn => {
     btn.classList.remove('text-black', 'font-bold', 'border-b-2', 'border-black'); 
     btn.classList.add('text-gray-600', 'hover:text-primary'); 
 });

 let activeTabButton; 
 if (sectionId === 'infoSection') {
     activeTabButton = document.getElementById('tab-info'); // 원본 id 유지
 } else if (sectionId === 'reviewList') {
     activeTabButton = document.getElementById('tab-review'); // 원본 id 유지
 } else if (sectionId === 'revwriteSection') {
     activeTabButton = document.getElementById('tab-revwrite'); // 원본 id 유지
 }
 
 if (activeTabButton) { 
     activeTabButton.classList.add('text-black', 'font-bold', 'border-b-2', 'border-black');
     activeTabButton.classList.remove('text-gray-600', 'hover:text-primary'); 
 }
};

//메인 이미지 모달 설정
function setupMainImageModal() { // 원본 함수명 유지
 const mainPhotos = document.querySelectorAll('.main-photo'); 
 const mainModal = document.getElementById('mainImageModal'); // 원본 id 유지
 const mainModalImage = document.getElementById('mainModalImage'); // 원본 id 유지

 if (!mainModal || !mainModalImage) { return; } 

 mainPhotos.forEach((photo, idx, list) => { 
     photo.addEventListener('click', function () {
         mainImageList = Array.from(list).map(img => img.src); 
         mainImageIndex = idx; 
         mainModalImage.src = mainImageList[mainImageIndex]; 
         mainModal.classList.remove('hidden'); 
     });
 });

 // 모달 내 이전 버튼 클릭 시
 const mainPrevBtn = document.getElementById('mainPrevBtn'); // 원본 id 유지
 if (mainPrevBtn) {
     mainPrevBtn.addEventListener('click', () => {
         if (mainImageList.length === 0) { return; }
         mainImageIndex = (mainImageIndex - 1 + mainImageList.length) % mainImageList.length; 
         mainModalImage.src = mainImageList[mainImageIndex]; 
     });
 }

 // 모달 내 다음 버튼 클릭 시
 const mainNextBtn = document.getElementById('mainNextBtn'); // 원본 id 유지
 if (mainNextBtn) {
     mainNextBtn.addEventListener('click', () => {
         if (mainImageList.length === 0) { return; }
         mainImageIndex = (mainImageIndex + 1) % mainImageList.length; 
         mainModalImage.src = mainImageList[mainImageIndex]; 
     });
 }
}
//메인 이미지 모달 닫기
window.closeMainImageModal = function () { // 원본 함수명 유지
 const mainModal = document.getElementById('mainImageModal'); // 원본 id 유지
 if (mainModal) {
     mainModal.classList.add('hidden'); 
 }
 mainImageList = []; 
};


//------------------------------------------------------------------
//리뷰 시스템 함수
//------------------------------------------------------------------
//리뷰 작성 폼의 별점 입력 UI 설정
function setupStarRatingInput() { // 원본 함수명 유지
const ratingInput = document.getElementById('ratingInput'); // 원본 id 유지
const starOverlay = document.getElementById('starOverlay'); // 원본 id 유지

function updateStars(score) { 
 if (!starOverlay || !ratingInput) { return; }
 const clampedScore = Math.max(0, Math.min(5, score)); 
 const starWidthPx = 24; 
 const overlayWidth = clampedScore * starWidthPx; 
 starOverlay.style.width = `${overlayWidth}px`; 
 ratingInput.value = clampedScore.toFixed(1); 
}

if (ratingInput) { 
 ratingInput.addEventListener('input', () => {
   const value = parseFloat(ratingInput.value) || 0;
   updateStars(value);
 });
 updateStars(parseFloat(ratingInput.value) || 0); 
}

// 별 아이콘 직접 클릭/마우스오버로 별점 입력 (#starRating 영역)
const starRatingContainer = document.getElementById('starRating'); // 원본 id 유지
if (starRatingContainer && starOverlay) {
   starRatingContainer.addEventListener('mousemove', function(e) { 
       const rect = starRatingContainer.getBoundingClientRect(); 
       const offsetX = e.clientX - rect.left; 
       const totalWidth = rect.width; 
       let score = (offsetX / totalWidth) * 5; 
       score = Math.round(score * 2) / 2; 
       updateStars(score); 
   });
   starRatingContainer.addEventListener('click', function() { 
   });
   starRatingContainer.addEventListener('mouseleave', function() { 
       updateStars(parseFloat(ratingInput.value) || 0);
   });
}
}

//리뷰 작성 폼 제출 처리 (리뷰 추가)
function handleReviewFormSubmit(event) { // 원본 함수명 유지
event.preventDefault(); 
const formData = new FormData(event.target); 
// formData의 키는 JSP <input name="..."> 에 의해 결정됨 (이전 JSP 수정에서 user_id, dest_id, imageFiles 등으로 변경됨)

if (!loginUserId) { 
 showToast("리뷰를 작성하려면 로그인이 필요합니다.");
 return;
}

$.ajax({
 url: `${contextPath}/addReview`, 
 method: 'POST',
 data: formData, // FormData는 name 속성을 키로 사용 (JSP에서 name="user_id" 등으로 수정했음)
 processData: false, 
 contentType: false, 
 success: function () {
   showToast('리뷰 등록 완료');
   const reviewFormElement = document.getElementById('reviewForm'); // 원본 id 유지
   if (reviewFormElement) {
     reviewFormElement.reset(); 
   }
   if (document.getElementById('ratingInput')) { // 원본 id 유지
     document.getElementById('ratingInput').value = "0"; 
   }
   if (document.getElementById('starOverlay')) { // 원본 id 유지
     document.getElementById('starOverlay').style.width = '0px'; 
   }
   if (document.getElementById('previewContainer')) { // 원본 id 유지
     document.getElementById('previewContainer').innerHTML = ''; 
   }
   fetchAndRenderReviews(destId, contextPath, getCurrentSortOrder()); 
 },
 error: function () {
   showToast('리뷰 등록 실패!');
 }
});
}

//------------------------------------------------------------------
//리뷰 시스템 함수 (fetchAndRenderReviews 및 formatRelativeDate 수정)
//------------------------------------------------------------------

//서버에서 리뷰 목록 가져와서 화면에 렌더링
function fetchAndRenderReviews(currentDestId, currentContextPath, sort = 'latest') { // 원본 함수명 유지
if (!currentDestId) { 
 console.warn("fetchAndRenderReviews: currentDestId is missing.");
 return; 
} 
console.log("fetchAndRenderReviews 호출됨 - destId:", currentDestId, "sort:", sort);

$.ajax({
 url: `${currentContextPath}/getReviewsByDestId`, 
 method: "GET",
 data: { 
     dest_id: currentDestId, // Controller: @RequestParam("dest_id")
     sort: sort              // Controller: @RequestParam("sort")
 }, 
 success: function (reviewListFromServer) { // reviewListFromServer는 ReviewVO[] (snake_case 필드)
   console.log("서버로부터 받은 리뷰 목록:", reviewListFromServer);
   const reviewListContainer = $('#reviewList'); // 원본 ID 유지 (jQuery selector)
   reviewListContainer.empty(); 

   if (!reviewListFromServer || reviewListFromServer.length === 0) {
     reviewListContainer.html('<p class="text-center text-gray-500 p-4">등록된 후기가 없습니다.</p>');
     return;
   }

   reviewListFromServer.forEach(review => { // review는 ReviewVO (snake_case 필드)
     // Controller에서 이미 full_stars, half_star, empty_stars를 계산해서 보내준다고 가정
     const fullStars = review.full_stars; 
     const halfStar = review.half_star;
     const emptyStars = review.empty_stars;
     
     let starsHTML = '';
     for(let i=0; i<fullStars; i++) { starsHTML += '<i class="ri-star-fill"></i>'; }
     if(halfStar) { starsHTML += '<i class="ri-star-half-fill"></i>'; }
     for(let i=0; i<emptyStars; i++) { starsHTML += '<i class="ri-star-line"></i>'; }

     // *** 날짜 처리 핵심 ***
     // 서버에서 온 review.created_at_str (ISO 8601 형식 문자열)을 formatRelativeDate 함수에 전달
     const dateStringToFormat = review.created_at_str; 
     const formattedDisplayDate = formatRelativeDate(dateStringToFormat); // formatRelativeDate 호출

     let imageHTML = '';
     if (review.image_path) { // ReviewVO.image_path
       const rawPaths = review.image_path.split(',').map(p => p.trim()).filter(p => p); 
       const allPathsJson = JSON.stringify(rawPaths); 

       if (rawPaths.length > 0) { 
         imageHTML = `
           <div class="grid grid-cols-2 gap-4 mt-2" data-all-images='${allPathsJson}'>
             ${rawPaths.slice(0, 2).map(path => `
               <img src="${currentContextPath}${path}?v=${Date.now()}"
                    alt="리뷰 이미지"
                    class="w-full h-[250px] object-cover rounded-xl shadow cursor-pointer review-image" />
             `).join('')}
           </div>`; 
       }
     }
     
     // JSP의 loginUserId는 camelCase, 서버에서 온 review.user_id는 snake_case
     const isAuthor = (String(review.user_id) === String(loginUserId)); 

     // HTML 생성 시 JSP의 EL 표현식과 동일하게 snake_case 필드명 사용
     const reviewHtml = `
             <div class="review-card bg-white shadow rounded-xl p-6 space-y-4 relative" id="review-${review.review_id}">
               <div class="view-mode space-y-4"> 
                 <div class="flex justify-between items-start"> 
                   <div class="text-sm font-semibold text-gray-800">${review.user_name}</div>
                   <div class="relative"> 
                     <button onclick="toggleReviewMenu(${review.review_id})" class="p-1 rounded hover:bg-gray-100">
                       <img src="${currentContextPath}/resources/img/menu_button.png" alt="메뉴 버튼" class="w-6 h-6" />
                     </button>
                     <div id="menu-${review.review_id}" class="hidden absolute right-0 mt-2 w-32 bg-white border rounded shadow-lg z-10"> 
                       ${isAuthor ? ` 
                         <button onclick="editReview(${review.review_id})" class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100">수정</button>
                         <button onclick="deleteReview(${review.review_id})" class="block w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-red-50">삭제</button>
                       ` : ''}
                       <button onclick="reportReview(${review.review_id})" class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100">신고</button>
                       <button onclick="shareReview(${review.review_id})" class="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-100">공유하기</button>
                     </div>
                   </div>
                 </div>
                 ${imageHTML} 
                 <div class="flex text-yellow-400 text-base mt-2">${starsHTML}</div> 
                 <p class="text-sm text-gray-900 whitespace-pre-line">${(review.content || '').replace(/\n/g, '<br>')}</p> 
                    <div class="absolute right-4 bottom-4">
           <p class="text-xs text-gray-600"> -${formattedDisplayDate}-</p>
         </div>
               </div>
               <div class="edit-mode hidden"> 
                 <label class="block text-sm font-medium text-gray-700">별점</label>
                 <input type="number" class="mt-1 border rounded px-2 py-1 text-sm w-full" name="rating" value="${review.rating}" min="0" max="5" step="0.5" />
                 <label class="block text-sm font-medium text-gray-700 mt-2">내용</label>
                 <textarea name="content" class="w-full mt-1 border p-2 rounded text-sm h-24">${review.content}</textarea>
                 <div class="mt-2"> 
                   <label class="text-sm text-gray-600">기존 이미지 (클릭하여 삭제)</label>
                   <div id="edit-images-${review.review_id}" class="grid grid-cols-3 gap-2 mt-1">
                     ${(review.image_path || '').split(',').filter(p=>p.trim()).map(p => `
                       <div class="relative existing-image-edit">
                         <img src="${currentContextPath}${p.trim()}?v=${Date.now()}" data-path="${p.trim()}" class="w-full h-20 object-cover rounded shadow" />
                         <button type="button" onclick="this.closest('.existing-image-edit').remove();"
                           class="absolute top-1 right-1 bg-red-500 text-white w-5 h-5 rounded-full text-xs flex items-center justify-center leading-none">×</button>
                       </div>`).join('')}
                   </div>
                 </div>
                 <div class="mt-2"> 
                   <label class="text-sm text-gray-600">새 이미지 추가:</label>
                   <input type="file" name="newImageFiles" multiple accept="image/*" id="editFileInput-${review.review_id}" class="mt-1 block w-full text-sm border rounded p-1" />
                   <div id="editPreviewContainer-${review.user_id}" class="mt-4 grid grid-cols-2 gap-4"></div>
                 </div>
                 <div class="mt-4 flex gap-2"> 
                   <button class="bg-primary text-white px-4 py-2 rounded text-sm" onclick="submitReviewEdit(${review.review_id})">저장</button>
                   <button class="bg-gray-300 text-gray-700 px-4 py-2 rounded text-sm" onclick="cancelReviewEdit(${review.review_id})">취소</button>
                 </div>
               </div>
             </div>`;
           reviewListContainer.append(reviewHtml); 
         });
       },

 error: function (xhr, status, error) { // 에러 콜백 상세화
   console.error("리뷰 목록 조회 실패:", status, error, xhr.responseText);
   $('#reviewList').html('<p class="text-red-500 text-center">리뷰를 불러오는데 실패했습니다.</p>'); 
 }
});
}

//날짜를 상대 시간으로 포맷팅 (예: "방금 전")
function formatRelativeDate(createdAtStr) { // 원본 함수명 유지
console.log("formatRelativeDate input:", createdAtStr); // 디버깅 로그
if (!createdAtStr || createdAtStr === "날짜 정보 없음" || String(createdAtStr).toLowerCase() === "invalid date") {
   console.log("formatRelativeDate: 유효하지 않은 입력값으로 '날짜 정보 없음' 반환:", createdAtStr);
   return "날짜 정보 없음";
}
const created = new Date(createdAtStr); 
if (isNaN(created.getTime())) { 
   console.error("formatRelativeDate: Invalid date string for new Date():", createdAtStr, "Parsed as:", created);
   return "날짜 형식 오류"; // 또는 createdAtStr을 그대로 반환하거나 다른 기본값
}

const now = new Date();
const diff = now.getTime() - created.getTime(); 

const minute = 60 * 1000;
const hour = 60 * minute;
const day = 24 * hour;
const week = 7 * day;

if (diff < minute) { return '방금 전'; }
if (diff < hour) { return `${Math.floor(diff / minute)}분 전`; }
if (diff < day) { return `${Math.floor(diff / hour)}시간 전`; }
if (diff < week) { return `${Math.floor(diff / day)}일 전`; }

// 일주일 이상 지난 경우 "YYYY. MM. DD." 형식으로 반환
return created.toLocaleDateString('ko-KR', { year: 'numeric', month: '2-digit', day: '2-digit' });
}
window.toggleReviewMenu = function(reviewId) { // 원본 함수명 유지
document.querySelectorAll('[id^="menu-"]').forEach(menu => {
 if (menu.id !== `menu-${reviewId}`) {
   menu.classList.add('hidden');
 }
});
const menu = document.getElementById(`menu-${reviewId}`); // 원본 id 유지
if (menu) {
 menu.classList.toggle('hidden');
}
};

window.shareReview = function(reviewId) { // 원본 함수명 유지
const url = `${window.location.origin}${window.location.pathname}#review-${reviewId}`; 
navigator.clipboard.writeText(url) 
 .then(() => { showToast("리뷰 링크가 복사되었습니다."); })
 .catch(() => { showToast("클립보드 복사 실패"); });
};

window.editReview = function(reviewId) { // 원본 함수명 유지
const card = document.getElementById(`review-${reviewId}`); // 원본 id 유지
if (card) {
 const viewMode = card.querySelector('.view-mode');
 const editMode = card.querySelector('.edit-mode');
 if (viewMode) { viewMode.classList.add('hidden'); } 
 if (editMode) { editMode.classList.remove('hidden'); } 
}
};

window.cancelReviewEdit = function(reviewId) { // 원본 함수명 유지
const card = document.getElementById(`review-${reviewId}`); // 원본 id 유지
if (card) {
 const viewMode = card.querySelector('.view-mode');
 const editMode = card.querySelector('.edit-mode');
 if (editMode) { editMode.classList.add('hidden'); } 
 if (viewMode) { viewMode.classList.remove('hidden'); } 
}
};

window.submitReviewEdit = function(reviewId) { // 원본 함수명 유지
const card = document.getElementById(`review-${reviewId}`); // 원본 id 유지
if (!card) { return; }

const contentTextArea = card.querySelector('textarea[name="content"]');
const ratingInput = card.querySelector('input[name="rating"]'); 

if (!contentTextArea || !ratingInput) { return; }

const content = contentTextArea.value; 
const rating = ratingInput.value; 

const existingImagePaths = Array.from(card.querySelectorAll('.existing-image-edit img[data-path]'))
                             .map(img => img.dataset.path); 

const formData = new FormData();
// Controller: @RequestParam("review_id"), @RequestParam("user_id"), ...
formData.append("review_id", reviewId); 
formData.append("user_id", loginUserId); 
formData.append("content", content);
formData.append("rating", rating);
formData.append("image_path", existingImagePaths.join(',')); 

const fileInput = card.querySelector('input[name="newImageFiles"]');
if (fileInput && fileInput.files.length > 0) {
 Array.from(fileInput.files).forEach(file => {
   formData.append("newImageFiles", file); // Controller: @RequestParam("newImageFiles")
 });
}

$.ajax({
 url: `${contextPath}/updateReview`, 
 method: "POST",
 data: formData,
 processData: false,
 contentType: false,
 success: () => {
   showToast("리뷰가 수정되었습니다.");
   fetchAndRenderReviews(destId, contextPath, getCurrentSortOrder()); 
 },
 error: (xhr) => { 
   if (xhr.status === 403) { 
     showToast("리뷰 수정 권한이 없습니다.");
   } else {
     showToast("리뷰 수정 실패");
   }
 }
});
};

window.deleteReview = function(reviewId) { // 원본 함수명 유지
pendingDeleteReviewId = reviewId; 
const deleteModal = document.getElementById('deleteModal'); // 원본 id 유지
if (deleteModal) {
 deleteModal.classList.remove('hidden'); 
}
};

window.reportReview = function(reviewId) { // 원본 함수명 유지
if (!loginUserId) { 
 showToast("신고하려면 로그인이 필요합니다.");
 return;
}
pendingReportReviewId = reviewId; 
const reportModal = document.getElementById('reportModal'); // 원본 id 유지
if (reportModal) {
 reportModal.classList.remove('hidden'); 
}
};

function setupReviewImageModal() { // 원본 함수명 유지
 const reviewListContainer = document.getElementById('reviewList'); // 원본 id 유지
 const imageModal = document.getElementById('imageModal'); // 원본 id 유지
 const modalImage = document.getElementById('modalImage'); // 원본 id 유지

 if (!reviewListContainer || !imageModal || !modalImage) { return; } 

 reviewListContainer.addEventListener('click', function (e) { 
     const target = e.target;
     if (target.classList.contains('review-image')) { 
         const imageWrapper = target.closest('[data-all-images]'); 
         if (!imageWrapper) { return; }

         const allImagesJson = imageWrapper.getAttribute('data-all-images'); 
         const rawList = JSON.parse(allImagesJson); 
         
         reviewImageList = rawList.map(p => `${contextPath}${p.trim()}`);
         const clickedSrcWithoutQuery = target.src.split('?')[0]; 
         
         reviewImageIndex = reviewImageList.findIndex(src => {
             const fullSrcPath = (location.origin + src).split('?')[0]; 
             return fullSrcPath === clickedSrcWithoutQuery;
         });
         if(reviewImageIndex === -1) {
             reviewImageIndex = 0; 
         }

         const reviewCard = target.closest('.review-card');
         if (reviewCard) {
             const userIdElement = reviewCard.querySelector('.text-sm.font-semibold');
             const createdElement = reviewCard.querySelector('.text-xs.text-gray-400');
             reviewData = { // 이 객체의 키는 JS 내부에서만 사용되므로 원본 유지
                 userId: userIdElement ? userIdElement.textContent.replace('작성자 : ','').trim() : '정보 없음',
                 created: createdElement ? createdElement.textContent.trim() : '날짜 정보 없음'
             };
         }
         updateReviewModalImage(); 
         imageModal.classList.remove('hidden'); 
     }
 });

 const prevBtn = document.getElementById('prevBtn'); // 원본 id 유지
 if(prevBtn) {
     prevBtn.addEventListener('click', () => {
         if (reviewImageList.length === 0) { return; }
         reviewImageIndex = (reviewImageIndex - 1 + reviewImageList.length) % reviewImageList.length;
         updateReviewModalImage();
     });
 }

 const nextBtn = document.getElementById('nextBtn'); // 원본 id 유지
 if(nextBtn) {
     nextBtn.addEventListener('click', () => {
         if (reviewImageList.length === 0) { return; }
         reviewImageIndex = (reviewImageIndex + 1) % reviewImageList.length;
         updateReviewModalImage();
     });
 }
}

function updateReviewModalImage() { // 원본 함수명 유지
const modalImage = document.getElementById('modalImage'); // 원본 id 유지
if (!modalImage || reviewImageList.length === 0) { return; }

modalImage.src = reviewImageList[reviewImageIndex] + `?v=${Date.now()}`; 

const modalUser = document.getElementById('modalUser'); // 원본 id 유지
const modalCreated = document.getElementById('modalCreated'); // 원본 id 유지
if (modalUser) { modalUser.textContent = reviewData?.userId || ''; } // reviewData 내부 키는 원본 유지
if (modalCreated) { modalCreated.textContent = reviewData?.created || ''; } // reviewData 내부 키는 원본 유지
}

window.closeImageModal = function () { // 원본 함수명 유지
const imageModal = document.getElementById('imageModal'); // 원본 id 유지
if (imageModal) {
 imageModal.classList.add('hidden');
}
reviewImageList = []; 
reviewData = null; 
};


//------------------------------------------------------------------
//모달 관리 (일반 확인 모달)
//------------------------------------------------------------------
window.closeDeleteModal = function() { // 원본 함수명 유지
const deleteModal = document.getElementById('deleteModal'); // 원본 id 유지
if (deleteModal) {
 deleteModal.classList.add('hidden');
 const userIdInput = document.getElementById('deleteUserIdInput'); // 원본 id 유지
 if (userIdInput) {
     userIdInput.value = ''; 
 }
}
pendingDeleteReviewId = null; 
};

function handleConfirmDelete() { // 원본 함수명 유지
const userIdInputElement = document.getElementById('deleteUserIdInput'); // 원본 id 유지
const inputUserId = userIdInputElement ? userIdInputElement.value.trim() : ''; 

if (!inputUserId) {
 showToast("회원 ID를 입력하세요.");
 return;
}
if (String(inputUserId) !== String(loginUserId)) { 
  showToast("입력하신 ID가 로그인된 사용자 ID와 일치하지 않습니다.");
  return;
}

if (!pendingDeleteReviewId) { return; } 

$.post(`${contextPath}/deleteReview`, { 
 // Controller: @RequestParam("review_id"), @RequestParam("user_id")
 review_id: pendingDeleteReviewId,
 user_id: loginUserId 
})
.done(() => { 
 showToast("리뷰가 삭제되었습니다.");
 closeDeleteModal(); 
 fetchAndRenderReviews(destId, contextPath, getCurrentSortOrder()); 
})
.fail((xhr) => { 
 if (xhr.status === 403) { 
   showToast("리뷰 삭제 권한이 없습니다.");
 } else {
   showToast("리뷰 삭제 실패");
 }
});
}

window.closeReportModal = function() { // 원본 함수명 유지
const reportModal = document.getElementById('reportModal'); // 원본 id 유지
if (reportModal) {
 reportModal.classList.add('hidden');
}
pendingReportReviewId = null; 
};

function handleConfirmReport() { // 원본 함수명 유지
if (!pendingReportReviewId || !loginUserId) { return; } 

fetch(`${contextPath}/reportReview`, { 
 method: "POST",
 headers: { "Content-Type": "application/x-www-form-urlencoded" },
 credentials: "same-origin", 
 // Controller: @RequestParam("review_id"), @RequestParam("user_id")
 body: new URLSearchParams({ review_id: pendingReportReviewId, user_id: loginUserId }) 
})
.then(res => { 
 if (res.status === 409) { return "already_reported"; } 
 if (!res.ok) { throw new Error(`서버 오류: ${res.status}`); } 
 return res.text();
})
.then(result => { 
 if (result === "reported") { showToast("신고가 접수되었습니다."); }
 else if (result === "already_reported") { showToast("이미 신고한 리뷰입니다."); }
 else { showToast("신고 처리 중 오류가 발생했습니다: " + result); }
 closeReportModal(); 
})
.catch((error) => { 
 showToast("서버 오류로 신고 실패: " + error.message);
 closeReportModal(); 
});
}

//------------------------------------------------------------------
//유틸리티 함수
//------------------------------------------------------------------
window.showToast = function(message, duration = 2000) { // 원본 함수명 유지
const toast = document.getElementById('toast'); // 원본 id 유지
if (!toast) { return; }

toast.textContent = message;
toast.classList.remove('hidden', 'opacity-0'); 
toast.classList.add('opacity-100'); 

if (toast._timeout) { clearTimeout(toast._timeout); } 

toast._timeout = setTimeout(() => {
 toast.classList.remove('opacity-100');
 toast.classList.add('opacity-0'); 
 setTimeout(() => { toast.classList.add('hidden'); }, 300); 
}, duration);
};

function setupScrollToTopButton() { // 원본 함수명 유지
const scrollToTopBtn = document.getElementById('scrollToTopBtn'); // 원본 id 유지
if (!scrollToTopBtn) { return; }

window.addEventListener('scroll', function () { 
 if (window.pageYOffset > 200) { 
   scrollToTopBtn.classList.remove('hidden', 'opacity-0');
   scrollToTopBtn.classList.add('opacity-100');
 } else { 
   scrollToTopBtn.classList.remove('opacity-100');
   scrollToTopBtn.classList.add('opacity-0');
   setTimeout(() => { 
     if (window.pageYOffset <= 200) {
       scrollToTopBtn.classList.add('hidden');
     }
   }, 300);
 }
});

scrollToTopBtn.addEventListener('click', function () { 
 window.scrollTo({ top: 0, behavior: 'smooth' }); 
});

if (window.pageYOffset <= 200) {
 scrollToTopBtn.classList.add('hidden', 'opacity-0');
} else {
 scrollToTopBtn.classList.remove('hidden', 'opacity-0');
 scrollToTopBtn.classList.add('opacity-100');
}
}

function getCurrentSortOrder() { // 원본 함수명 유지
 const activeButton = document.querySelector('.sort-btn.bg-primary'); 
 return activeButton ? activeButton.dataset.sort : 'latest'; 
}

function setupNewReviewImagePreview() { // 원본 함수명 유지
 const previewInput = document.getElementById('previewInput'); // 원본 id 유지
 const previewContainer = document.getElementById('previewContainer'); // 원본 id 유지

 if (previewInput && previewContainer) {
     previewInput.addEventListener('change', function () { 
         const files = Array.from(previewInput.files); 
         previewContainer.innerHTML = ''; 

         if (files.length > 5) { 
             showToast("이미지는 최대 5장까지 업로드할 수 있습니다.");
             previewInput.value = ""; 
             return;
         }

         files.forEach(file => { 
             const reader = new FileReader();
             reader.onload = function (e) { 
                 const img = document.createElement('img');
                 img.src = e.target.result; 
                 img.className = "w-20 h-20 object-cover rounded border"; 
                 previewContainer.appendChild(img); 
             };
             reader.readAsDataURL(file); 
         });
     });
 }
}


//------------------------------------------------------------------
//DOMContentLoaded - 메인 실행 블록
//------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', function () {
console.log("JS 시작");

contextPath = document.body.dataset.contextPath || '';
loginUserId = document.body.dataset.loginUserId || ""; // JSP: data-login-user-id (camelCase로 읽힘)
console.log("loginUserId:", loginUserId);

const urlParams = new URLSearchParams(window.location.search);
// Controller는 @RequestParam("dest_id") 또는 @RequestParam(value="destId") 로 받을 수 있음.
// 일관성을 위해 Controller에서 @RequestParam("dest_id")로 받고, JS도 URL 파라미터 생성 및 읽기 시 "dest_id" 사용 권장.
// 여기서는 JSP에서 생성된 URL이 'destId' 또는 'dest_id'일 수 있음을 가정하고 둘 다 확인.
let destIdFromUrl = urlParams.get('dest_id'); 
if (!destIdFromUrl) {
 destIdFromUrl = urlParams.get('destId'); // 이전 JSP에서 camelCase URL 파라미터를 사용했을 경우 대비
}
// JSP에서 <input name="dest_id" ...> 로 수정했으므로, name="dest_id"로 찾음
const destIdFromInput = document.querySelector('input[name="dest_id"]')?.value; 
destId = destIdFromUrl || destIdFromInput || ''; // JS 전역 변수 destId (camelCase)에 할당
console.log("destId (전역 변수):", destId);
console.log("data-name 값:", document.body.dataset.name);


const searchSection = document.getElementById('searchSection'); // 원본 id 유지
const detailSection = document.getElementById('detailSection'); // 원본 id 유지
if (destId && destId.trim() !== "") { 
 if (searchSection) { searchSection.classList.add('hidden'); } 
 if (detailSection) { detailSection.classList.remove('hidden'); } 
 fetchAndRenderReviews(destId, contextPath, 'latest'); 
} else { 
 if (searchSection) { searchSection.classList.remove('hidden'); } 
 if (detailSection) { detailSection.classList.add('hidden'); } 
 loadRandomHashtags(); 
}

const mainSearchInput = document.getElementById('mainSearch'); // 원본 id 유지
if (mainSearchInput) {
 mainSearchInput.addEventListener('keypress', function (e) { 
     if (e.key === 'Enter') { 
         searchPlaceByKeyword(this.value.trim());
     }
 });
}
const searchBtn = document.getElementById('searchBtn'); // 원본 id 유지
if (searchBtn) {
 searchBtn.addEventListener('click', function () { 
     if (mainSearchInput) {
         searchPlaceByKeyword(mainSearchInput.value.trim());
     }
 });
}

if (destId) {
 const likeButton = document.getElementById("likeBtn"); // 원본 id 유지
 if (likeButton) {
     likeButton.addEventListener("click", handleLikeButtonClick); 
 }
 
 setupInformationTabs(); 
 setupMainImageModal(); 

 document.querySelectorAll('.sort-btn').forEach(btn => {
   btn.addEventListener('click', function () {
     const newSortOrder = this.dataset.sort; 
     document.querySelectorAll('.sort-btn').forEach(b => { b.classList.remove('bg-primary', 'text-white'); }); 
     this.classList.add('bg-primary', 'text-white'); 
     fetchAndRenderReviews(destId, contextPath, newSortOrder); 
   });
 });
 // JSP data-sort="lastest" -> "latest"로 수정 권장 (오타 수정)
 const defaultSortBtn = document.querySelector('.sort-btn[data-sort="lastest"]'); 
 if (defaultSortBtn) {
     defaultSortBtn.classList.add('bg-primary', 'text-white');
 }
}

const reviewForm = document.getElementById('reviewForm'); // 원본 id 유지
if (reviewForm) {
 reviewForm.addEventListener('submit', handleReviewFormSubmit);
}
setupStarRatingInput(); 
setupNewReviewImagePreview(); 

const confirmDeleteButton = document.getElementById('confirmDeleteBtn'); // 원본 id 유지
if (confirmDeleteButton) {
 confirmDeleteButton.addEventListener('click', handleConfirmDelete);
}

const confirmReportButton = document.getElementById('confirmReportBtn'); // 원본 id 유지
if (confirmReportButton) {
 confirmReportButton.addEventListener('click', handleConfirmReport);
}

setupScrollToTopButton(); 
setupReviewImageModal(); 

document.addEventListener('click', function (e) {
 const targetElement = e.target;
 const isMenuButton = targetElement.closest('button[onclick^="toggleReviewMenu"]'); 
 const isInsideMenu = targetElement.closest('[id^="menu-"]'); 
 if (!isMenuButton && !isInsideMenu) { 
   document.querySelectorAll('[id^="menu-"]').forEach(menu => { menu.classList.add('hidden'); }); 
 }
});
});

