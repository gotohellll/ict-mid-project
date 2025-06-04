<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 로그인 사용자 ID 설정 -->
<c:set var="loginUserId" value="${sessionScope.user.user_id}" />

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>Tripin - 여행지 상세</title>

  <!-- 공통 CSS -->
  <link href="${pageContext.request.contextPath}/resources/css/destinationdetail.css" rel="stylesheet" type="text/css">
  <script src="https://cdn.tailwindcss.com/3.4.16"></script>

  <!-- 구글 폰트 -->
  <link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

  <!-- 아이콘 -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">

  <!-- jQuery -->
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>

  <!-- Kakao Maps API -->
  <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=cb27ec3c7fd6a6bb779d2d6d68ef4d6b&autoload=false&libraries=services,clusterer,drawing"></script>

  <!-- 외부 JS -->
  <script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/destinationdetail.js" defer></script>

  <!-- Tailwind CSS 설정 -->
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            primary: '#4F46E5',
            secondary: '#10B981'
          },
          borderRadius: {
            'none': '0px',
            'sm': '4px',
            DEFAULT: '8px',
            'md': '12px',
            'lg': '16px',
            'xl': '20px',
            '2xl': '24px',
            '3xl': '32px',
            'full': '9999px',
            'button': '8px'
          }
        }
      }
    }
  </script>
</head>
<body class="bg-white font-['Noto Sans KR']"
      data-name="${fn:escapeXml(name)}" data-context-path="${pageContext.request.contextPath}" data-login-user-id="${sessionScope.user.user_id}">

  <body data-current-user-id="${not empty user ? user.user_id : ''}">
    <!-- 헤더 -->
	<header class="place_list_header">
		<div class="container">
			<!-- 타이틀 -->
			<div class="left-header">
				<a href="mainpage">
				<img class="logo" src="/tripin2/resources/img/logo.png">
				</a>
				<nav class="main-nav">
					<a href="mainpage" class="home">홈</a> <a href="chatbot.do" class="trivy">트리비와
						대화하기</a> <a href="place_list.do" class="theme">테마여행</a>
						<a href="${pageContext.request.contextPath}/destinationdetail" class="detail">여행지 상세</a>
				</nav>
			</div>
			<div class="icon-group">
			
    <c:set var="userNotificationTitle" value="내 문의"/>
    <c:if test="${uncheckedInquiryCount > 0}">
        <c:set var="userNotificationTitle" value="새로운 답변 (${uncheckedInquiryCount}건)"/>
    </c:if>

    <a href="<c:url value='mypage'/>" "내 문의" 페이지 경로
       title="${fn:escapeXml(userNotificationTitle)}"
       class="p-2 rounded-full text-gray-500 hover:text-gray-700 hover:bg-gray-100 relative flex items-center justify-center w-10 h-10">
        <i class="ri-notification-3-line ri-lg"></i>

       
        <c:if test="${uncheckedInquiryCount > 0}">
            <span class="absolute top-1 right-1 flex h-4 w-4">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                <span class="relative inline-flex rounded-full h-4 w-4 bg-red-500 items-center justify-center">
                    <c:choose>
                        <c:when test="${uncheckedInquiryCount < 10}">
                            <span class="text-xs font-bold text-white">${uncheckedInquiryCount}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="text-xs font-bold text-white">9+</span>
                        </c:otherwise>
                    </c:choose>
                </span>
            </span>
        </c:if>
    </a>
<a href="<c:url value='mypage'/>">
					<i class="ri-user-line"></i>
				</a>
			</div>
		</div>
	</header> 
	

   <!-- 메인 검색 화면 -->
  <section id="searchSection" class="relative z-10 flex flex-col items-center justify-center h-screen">
    <img src="${pageContext.request.contextPath}/resources/img/sky1.jpg" alt="배경 이미지" class="absolute inset-0 w-full h-full object-cover z-0" />
    <div class="absolute inset-0 bg-white/40 backdrop-blur-sm z-0"></div>
    <img src="${pageContext.request.contextPath}/resources/img/tripin_logo.png" alt="Tripin 로고" class="w-[300px] mb-10 z-10" />
    <div class="relative w-full max-w-[900px] z-10">
      <input id="mainSearch" type="text" placeholder="상세 여행지를 입력하세요." class="w-full px-8 py-5 text-xl border border-gray-300 rounded-full shadow text-center focus:outline-none focus:ring-2 focus:ring-primary pr-16" />
      <button id="searchBtn" class="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-primary">
        <i class="ri-search-line text-2xl"></i>
      </button>
    </div>
    <div id="hashtagContainer" class="mt-8 flex flex-wrap justify-center gap-4 z-10"></div>
  </section>

  <!-- 여행지 상세 화면 (숨겨진 영역) -->
  <section id="detailSection" class="w-full bg-white py-12 hidden">
    <div class="max-w-screen-lg mx-auto px-4 relative">
      <div class="mt-24 mb-12 text-center space-y-4 -translate-y-16">
        <!-- 이전에 검색창 및 해시태그가 있었던 영역으로 보임, 현재는 비어있음 -->
      </div>

      <!-- 상단 탭 배너 (스크롤용) -->
      <div class="w-full border-b border-gray-300 mb-8">
        <div class="grid grid-cols-3 text-center text-lg font-medium text-gray-600">
          <button onclick="scrollToSection('infoSection')" id="tab-info" class="py-3 tab-btn-style border-b-2 border-black text-black font-bold">여행지 위치</button>
          <button onclick="scrollToSection('reviewList')" id="tab-review" class="py-3 tab-btn-style border-l border-r border-gray-300 hover:text-primary">여행지 후기</button>
          <button onclick="scrollToSection('revwriteSection')" id="tab-revwrite" class="py-3 tab-btn-style hover:text-primary">리뷰작성</button>
        </div>
      </div>

      <!-- 이미지 슬라이더 -->
      <div class="w-full h-[600px] rounded-xl shadow overflow-hidden mb-10">
        <div id="mainImageSlider" class="flex transition-transform duration-500 ease-in-out">
  <c:choose>
        <c:when test="${empty place.repr_img_url}">
           <div class="skeleton-img"></div>
        </c:when>
        <c:otherwise>
          <img src="${place.repr_img_url}" class="main-photo w-full h-full object-cover snap-center cursor-pointer" />
       </c:otherwise>
    </c:choose>

        </div>
      </div>

      <!-- 여행지 설명 및 정보 탭 -->
      <div class="space-y-4 mb-12">
        <div class="flex items-center gap-2">
          <h2 class="text-3xl font-bold text-gray-900">${place.dest_name}</h2>
          <button id="likeBtn" class="text-red-500 hover:text-red-600 text-2xl leading-none focus:outline-none">
            <i id="likeIcon" class="ri-heart-line align-middle"></i>
          </button>
        </div>
        <div id="infoSection" class="flex items-center text-yellow-400 text-xl">
          <i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-half-fill"></i>
          <span class="ml-2 text-sm text-gray-600 font-semibold">4.5</span> <!-- 예시 평점 -->
        </div>
        <div class="flex space-x-6 border-b text-sm font-medium pb-4">
     
          <button class="tab-btn text-gray-500 hover:text-primary" data-tab="guide">이용안내</button>
          <button class="tab-btn text-gray-500 hover:text-primary" data-tab="detail">상세정보</button>
          
        </div>
        <div class="bg-gray-50 border rounded-lg p-4 h-48 overflow-y-auto text-sm text-gray-700">
         
          <div id="tab-guide" class="tab-content block">
            <!-- <p>${detail.contenttypeid}</p> --><!-- 디버깅용 contenttypeid 출력 -->
           
            <c:choose>
              <c:when test="${detail.contenttypeid == 12}"> <!-- 관광지 -->
                <p><strong>운영시간: </strong>${detail.usetime}</p>
                <p><strong>휴무일: </strong>${detail.restdate}</p>
                <p><strong>이용요금: </strong>${detail.usefee}</p>
                <p><strong>문의처: </strong>${detail.infocenter}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 14}"> <!-- 문화시설 -->
                <p><strong>운영시간: </strong>${detail.usetime}</p>
                <p><strong>휴무일: </strong>${detail.restdate}</p>
                <p><strong>이용요금: </strong>${detail.usefee}</p>
                <p><strong>문의처: </strong>${detail.infocenter}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 15}"> <!-- 행사/공연/축제 -->
                <p><strong>행사시작일: </strong>${detail.eventstartdate}</p>
                <p><strong>행사종료일: </strong>${detail.eventenddate}</p>
                <p><strong>공연시간: </strong>${detail.usetime}</p>
                <p><strong>이용요금: </strong>${detail.usefee}</p>
                <p><strong>문의처: </strong>${detail.infocenter}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 28}"> <!-- 레포츠 -->
                <p><strong>운영시간: </strong>${detail.usetime}</p>
                <p><strong>휴무일: </strong>${detail.restdate}</p>
                <p><strong>이용요금: </strong>${detail.usefee}</p>
                <p><strong>문의처: </strong>${detail.infocenter}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 32}"> <!-- 숙박 -->
                <p><strong>문의처: </strong>${detail.infocenter}</p>
                <p><strong>예약안내: </strong>${detail.reservationurl}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 38}"> <!-- 쇼핑 -->
                <p><strong>운영시간: </strong>${detail.usetime}</p>
                <p><strong>휴무일: </strong>${detail.restdate}</p>
                <p><strong>문의처: </strong>${detail.infocenter}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 39}"> <!-- 음식점 -->
                <p><strong>운영시간: </strong>${detail.usetime}</p>
                <p><strong>휴무일: </strong>${detail.restdatefood}</p>
                <p><strong>문의처: </strong>${detail.reservation}</p> <!-- 음식점의 경우 reservation 필드가 문의처일 수 있음 -->
              </c:when>
            </c:choose>
          </div>
          <div id="tab-detail" class="tab-content hidden">
            <!-- <p>${detail.contenttypeid}</p> --><!-- 디버깅용 contenttypeid 출력 -->
            <c:choose>
              <c:when test="${detail.contenttypeid == 12}"> <!-- 관광지 -->
                <p><strong>주차시설: </strong>${detail.parking}</p>
                <p><strong>이용시기: </strong>${detail.useseason}</p>
                <p><strong>체험가능연령: </strong>${detail.age}</p>
                <p><strong>체험안내: </strong>${detail.expguide}</p>
                <p><strong>개장일: </strong>${detail.opendate}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 14}"> <!-- 문화시설 -->
                <p><strong>주차시설: </strong>${detail.parking}</p>
                <p><strong>관람소요시간: </strong>${detail.spendtime}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 15}"> <!-- 행사/공연/축제 -->
                <p><strong>행사장소: </strong>${detail.eventplace}</p>
                <p><strong>행사장위치: </strong>${detail.placeinfo}</p>
                <p><strong>주최자: </strong>${detail.sponsor}</p>
                <p><strong>행사프로그램: </strong>${detail.program}</p>
                <p><strong>관람소요시간: </strong>${detail.spendtime}</p>
                <p><strong>행사홈페이지: </strong>${detail.homepage}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 28}"> <!-- 레포츠 -->
                <p><strong>개장기간: </strong>${detail.openperiod}</p>
                <p><strong>예약안내: </strong>${detail.reservation}</p>
                <p><strong>수용인원: </strong>${detail.accomcount}</p>
                <p><strong>체험가능연령: </strong>${detail.age}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 32}"> <!-- 숙박 -->
                <p><strong>입실시간: </strong>${detail.checkintime}</p>
                <p><strong>퇴실시간: </strong>${detail.checkouttime}</p>
                <p><strong>객실유형: </strong>${detail.roomtype}</p>
                <p><strong>객실수: </strong>${detail.roomcount}</p>
                <p><strong>수용가능인원: </strong>${detail.accomcount}</p>
                <p><strong>바베큐장여부: </strong>${detail.barbecue}</p>
                <p><strong>환불규정: </strong>${detail.refund}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 38}"> <!-- 쇼핑 -->
                <p><strong>주차시설: </strong>${detail.parking}</p>
                <p><strong>판매품목: </strong>${detail.saleitem}</p>
              </c:when>
              <c:when test="${detail.contenttypeid == 39}"> <!-- 음식점 -->
                <p><strong>대표메뉴: </strong>${detail.firstmenu}</p>
                <p><strong>취급메뉴: </strong>${detail.treatmenu}</p>
                <p><strong>주차시설: </strong>${detail.parking}</p>
                <p><strong>포장가능: </strong>${detail.packing}</p>
                <p><strong>좌석수: </strong>${detail.seat}</p>
              </c:when>
            </c:choose>
          </div>
        </div>
      </div>

      <!-- 지도 및 주변 정보 -->
      <div class="flex flex-col md:flex-row bg-white shadow-lg overflow-hidden" style="height: 600px;">
        <!-- 지도 영역 -->
        <div id="map" class="w-full md:w-1/2 h-[300px] md:h-full bg-gray-200">
          <div class="flex items-center justify-center h-full text-gray-500">지도 로딩 중...</div>
        </div>
        <!-- 주변 정보 영역 (카테고리 버튼 + 장소 목록) -->
        <div class="w-full md:w-1/2 h-[calc(600px-300px)] md:h-full flex flex-col">
          <div class="p-4 bg-gray-50 flex-shrink-0">
            <div class="flex justify-around gap-2">
              <button class="category-btn flex-grow px-3 py-2 text-xs sm:text-sm rounded-full text-gray-700 font-medium hover:bg-primary/10 hover:text-primary focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all duration-150" data-category="FD6">
                <i class="ri-restaurant-line mr-1 sm:mr-2"></i>맛집
              </button>
              <button class="category-btn flex-grow px-3 py-2 text-xs sm:text-sm rounded-full text-gray-700 font-medium hover:bg-primary/10 hover:text-primary focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all duration-150" data-category="AD5">
                <i class="ri-hotel-bed-line mr-1 sm:mr-2"></i>숙소
              </button>
              <button class="category-btn flex-grow px-3 py-2 text-xs sm:text-sm rounded-full text-gray-700 font-medium hover:bg-primary/10 hover:text-primary focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all duration-150" data-category="AT4">
                <i class="ri-camera-lens-line mr-1 sm:mr-2"></i>관광지
              </button>
            </div>
          </div>
          <div id="placeListContainer" class="p-4 flex-grow overflow-y-auto">
            <div id="placeList" class="space-y-2 sm:space-y-3 text-sm">
              <p class="text-center text-gray-400 py-6">카테고리를 선택하면 주변 장소가 표시됩니다.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 여행지 후기 섹션 타이틀 및 정렬 버튼 -->
      <div class="mt-16 mb-6">
        <div class="flex items-center justify-between mb-3">
          <h3 class="text-2xl font-bold text-gray-800">여행지 후기</h3>
          <div class="flex gap-2">
            <button class="sort-btn px-3 py-1 border rounded-full text-sm text-gray-600 hover:bg-primary hover:text-white transition" data-sort="lastest">최신순</button>
            <button class="sort-btn px-3 py-1 border rounded-full text-sm text-gray-600 hover:bg-primary hover:text-white transition" data-sort="rating">별점순</button>
          </div>
        </div>
        <div class="border-t border-gray-200 w-full"></div>
      </div>

      <!-- 리뷰 목록 -->
      <div id="reviewList" class="mt-24 space-y-10">
        <c:forEach var="review" items="${reviewList}">
          <div class="review-card bg-white shadow rounded-xl p-6 space-y-4 relative" id="review-${review.review_id}">
            <!-- 리뷰 보기 모드 -->
            <div class="view-mode space-y-2">
              <div class="flex justify-between items-start">
                <div class="text-sm font-semibold text-gray-800">회원 ID:${review.user_name}</div>
                <c:if test="${review.user_id == loginUserId or review.user_id eq loginUserId}">
                  <div class="flex gap-2">
                    <button onclick="editReview(${review.review_id})" class="flex items-center gap-1 text-blue-600 hover:text-primary text-sm font-medium">
                      <img src="https://cdn-icons-png.flaticon.com/512/84/84380.png" class="w-4 h-4" />수정
                    </button>
                    <button onclick="deleteReview(${review.review_id})" class="flex items-center gap-1 text-red-500 hover:text-red-700 text-sm font-medium">
                      <img src="https://cdn-icons-png.flaticon.com/512/6861/6861362.png" class="w-4 h-4" />삭제
                    </button>
                  </div>
                </c:if>
              </div>
              <c:if test="${not empty review.image_path and fn:length(review.image_path) > 0}">
                <div class="grid grid-cols-2 gap-4 mt-2">
                  <c:forEach var="img" items="${fn:split(review.image_path, ',')}" varStatus="status">
                    <c:if test="${status.index lt 2 and not empty img}">
                      <img src="${pageContext.request.contextPath}${img}" class="w-full h-[250px] object-cover rounded-xl shadow cursor-pointer review-image" alt="리뷰 이미지" />
                    </c:if>
                  </c:forEach>
                  <c:forEach var="img" items="${fn:split(review.image_path, ',')}" varStatus="status">
                    <c:if test="${status.index ge 2 and not empty img}">
                      <img src="${pageContext.request.contextPath}${img}" class="hidden review-image" alt="리뷰 이미지 (숨김)" />
                    </c:if>
                  </c:forEach>
                </div>
              </c:if>
              <div class="flex text-yellow-400 text-base mt-2">
                <c:forEach begin="1" end="${review.full_stars}"><i class="ri-star-fill"></i></c:forEach>
                <c:if test="${review.half_star}"><i class="ri-star-half-fill"></i></c:if>
                <c:forEach begin="1" end="${review.empty_stars}"><i class="ri-star-line"></i></c:forEach>
              </div>
              <p class="text-sm text-gray-900 whitespace-pre-line">${review.content}</p>
              <div class="flex justify-between items-center mt-2">
                <p class="text-sm text-gray-400">작성일: ${review.created_at_str}</p>
                <div class="flex items-center gap-2">                 
                  <button class="text-xs text-gray-400 hover:text-red-500">신고</button>
                </div>
              </div>
            </div>

            <!-- 리뷰 수정 모드 (기본 숨김) -->
            <div class="edit-mode hidden">
              <input type="number" class="border rounded px-2 py-1 text-sm" name="rating" value="${review.rating}" min="0" max="5" step="0.5" />
              <textarea name="content" class="w-full mt-2 border p-2 rounded text-sm">${review.content}</textarea>
              <div class="grid grid-cols-2 gap-4 mt-3" id="edit-images-${review.review_id}">
                <c:forEach var="img" items="${fn:split(review.image_path, ',')}">
                  <c:if test="${not empty img}">
                    <div class="relative">
                      <img src="${pageContext.request.contextPath}${img}" class="w-full h-[250px] object-cover rounded shadow" />
                      <button type="button" onclick="this.closest('div').remove();" class="absolute top-2 right-2 bg-red-500 text-white w-6 h-6 rounded-full text-xs flex items-center justify-center">×</button>
                    </div>
                  </c:if>
                </c:forEach>
              </div>
              <div class="mt-2">
                <label class="text-sm text-gray-600">이미지 추가:</label>
                <input type="file" id="editFileInput-${review.review_id}" name="newImageFiles" multiple accept="image/*" class="mt-1 block w-full text-sm border rounded p-1" />
                <div id="editPreviewContainer-${review.review_id}" class="mt-4 grid grid-cols-2 gap-4"></div>
              </div>
              <div class="mt-4 flex gap-2">
                <button class="bg-primary text-white px-4 py-2 rounded text-sm" onclick="submitReviewEdit(${review.review_id})">완료</button>
                <button class="bg-gray-300 text-gray-700 px-4 py-2 rounded text-sm" onclick="cancelReviewEdit(${review.review_id})">취소</button>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>

      <!-- 리뷰 작성 폼 -->
      <form id="reviewForm" method="post" enctype="multipart/form-data" class="text-sm mt-8 max-w-screen-lg mx-auto px-4">
        <div class="bg-white rounded-xl p-6 space-y-4 shadow-sm border border-gray-200">
          <div class="flex items-center gap-2">
           <span class="text-sm font-semibold text-gray-800">작성자 : ${user.user_name}</span>
          </div>
          <input type="hidden" name="user_id" value="${loginUserId}" />
          <input type="hidden" name="dest_id" value="${place.dest_id}" /> 
          <div id="starRating">
            <div class="base">
              <i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i>
            </div>
            <div id="starOverlay">
              <i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i><i class="ri-star-fill"></i>
            </div>
          </div>
          <div class="flex items-center gap-2">
            <label for="ratingInput" class="text-sm text-gray-700">별점 :</label>
            <input type="number" id="ratingInput" name="rating" min="0" max="5" step="0.5" value="0" class="w-16 border border-gray-300 rounded px-2 py-1 text-sm text-right" />
            <span> 점</span>
            <span id="ratingDisplay" class="hidden"></span>
          </div>
          <textarea id="revwriteSection" name="content" placeholder="리뷰를 입력해주세요." rows="3" class="w-full border border-gray-300 rounded p-3 resize-none focus:outline-none focus:ring-1 focus:ring-primary text-sm"></textarea>
          <div class="flex items-center justify-between gap-4 w-full">
            <input type="file" id="previewInput" name="imageFiles" accept="image/*" multiple class="block text-sm text-gray-500 file:mr-4 file:py-1 file:px-2 file:rounded file:border-0 file:text-sm file:font-semibold file:bg-primary/10 file:text-primary hover:file:bg-primary/20" />
            <div id="previewContainer" class="flex flex-wrap gap-2"></div>
            <button type="submit" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary/90 whitespace-nowrap">등록</button>
          </div>
        </div>
      </form>
    </div>
  </section>

  <!-- 맨 위로 이동 버튼 -->
  <div class="fixed bottom-5 right-5 sm:bottom-6 sm:right-6 z-50">
    <button id="scrollToTopBtn" aria-label="맨 위로 이동" class="bg-primary text-white w-10 h-10 sm:w-12 sm:h-12 rounded-full shadow-lg flex items-center justify-center hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition-all duration-200 ease-in-out hover:scale-105 opacity-0 hidden">
      <i class="ri-arrow-up-s-line text-xl sm:text-2xl"></i>
    </button>
  </div>

  <!-- 검색 결과 모달 -->
  <div id="searchModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm hidden">
    <div class="bg-white w-[90vw] h-[80vh] max-w-[1400px] max-h-[900px] shadow-2xl flex overflow-hidden animate-fade-in-up">
      <div id="modalMap" class="w-1/2 h-full"></div>
      <div class="w-1/2 h-full flex flex-col bg-gray-50">
        <div class="flex justify-between items-center px-6 py-4 border-b border-gray-200 bg-white shadow-sm">
          <h3 class="text-xl font-semibold text-gray-800">"<span id="searchKeywordDisplay" class="text-primary font-bold">검색어</span>" 검색 결과</h3>
          <button onclick="closeModal()" class="text-gray-500 text-2xl hover:text-red-400 transition">×</button>
        </div>
        <div id="searchList" class="flex-1 overflow-y-auto p-6 space-y-4">
          <!-- 검색 결과 항목 동적 생성 -->
        </div>
      </div>
    </div>
  </div>

  <!-- 리뷰 이미지 모달 -->
  <div id="imageModal" class="fixed inset-0 z-50 bg-neutral-800/50 backdrop-blur-sm hidden flex items-center justify-center text-white">
    <div class="relative max-w-5xl w-full px-4">
      <div class="relative overflow-hidden">
        <img id="modalImage" src="" class="max-h-[70vh] mx-auto rounded-lg object-contain transition duration-300" />
        <button id="prevBtn" class="absolute top-1/2 left-0 transform -translate-y-1/2 text-white text-3xl px-4 hover:text-primary z-50">❮</button>
        <button id="nextBtn" class="absolute top-1/2 right-0 transform -translate-y-1/2 text-white text-3xl px-4 hover:text-primary z-50">❯</button>
      </div>
      <div class="mt-4 text-center">
        <p id="modalUser" class="text-sm opacity-90"></p>
        <p id="modalCreated" class="text-xs mt-1 opacity-60"></p>
      </div>
      <button onclick="closeImageModal()" class="absolute -top-6 -right-6 bg-black/70 text-white w-10 h-10 rounded-full flex items-center justify-center hover:bg-red-600 z-50 shadow-lg transition">
        <i class="ri-close-line text-xl"></i>
      </button>
    </div>
  </div>

  <!-- 메인 이미지 모달 -->
  <div id="mainImageModal" class="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm hidden flex items-center justify-center text-white">
    <div class="relative max-w-5xl w-full px-4">
      <img id="mainModalImage" class="max-h-[70vh] mx-auto rounded-lg object-contain transition duration-300" />
      <button id="mainPrevBtn" class="absolute top-1/2 left-0 transform -translate-y-1/2 text-white text-3xl px-4">❮</button>
      <button id="mainNextBtn" class="absolute top-1/2 right-0 transform -translate-y-1/2 text-white text-3xl px-4">❯</button>
      <button onclick="closeMainImageModal()" class="absolute top-4 right-4 bg-white/10 w-10 h-10 rounded-full flex items-center justify-center hover:bg-red-600"><i class="ri-close-line text-xl"></i></button>
    </div>
  </div>

  <!-- 리뷰 삭제 확인 모달 -->
  <div id="deleteModal" class="fixed inset-0 bg-black/50 backdrop-blur-sm hidden flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 w-full max-w-sm shadow-lg">
      <h2 class="text-lg font-semibold text-gray-800 mb-4">리뷰 삭제 확인</h2>
      <p class="text-sm text-gray-600 mb-2">본인 확인을 위해 회원 ID를 입력하세요.</p>
      <input type="text" id="deleteUserIdInput" class="w-full border px-3 py-2 rounded text-sm mb-4" placeholder="회원 ID 입력" />
      <div class="flex justify-end gap-2">
        <button onclick="closeDeleteModal()" class="px-4 py-2 text-sm text-gray-600 hover:text-black">취소</button>
        <button id="confirmDeleteBtn" class="bg-gray-800 hover:bg-red-600 text-white px-4 py-2 text-sm rounded">삭제</button>
      </div>
    </div>
  </div>

  <!-- 리뷰 신고 확인 모달 -->
  <div id="reportModal" class="hidden fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50">
    <div class="bg-white rounded-xl shadow p-6 w-80 space-y-4">
      <h2 class="text-lg font-bold text-gray-800 text-center">리뷰 신고</h2>
      <p class="text-sm text-gray-600 text-center">정말 이 리뷰를 신고하시겠습니까?</p>
      <div class="flex justify-center gap-4 pt-2">
        <button onclick="closeReportModal()" class="px-4 py-2 rounded bg-gray-300 text-gray-800 text-sm">취소</button>
        <button id="confirmReportBtn" class="px-4 py-2 rounded bg-red-600 text-white text-sm">신고</button>
      </div>
    </div>
  </div>

  <!-- 토스트 메시지 -->
  <div id="toast" class="hidden fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-black bg-opacity-70 text-white px-4 py-2 rounded shadow z-50 opacity-0 transition-opacity duration-500 text-sm text-center max-w-[80%]">
  </div>

</body>
</html>