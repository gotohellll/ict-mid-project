<!DOCTYPE html>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html lang="ko">
<!-- ✅ hero-section에도 높이, 배경, 기본 텍스트 스타일을 줘서 스타일 적용 명확히 -->
<style>
  /* hero-section에 배경 없이도 공간 차지하도록 height 추가 */
  .hero-section {
    height: 100vh; /* 화면 높이 만큼 차지하게 설정 */
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    color: #333; /* 배경 밝을 때 글씨가 안 보이는 문제 예방 */
    font-family: 'Noto Sans KR', sans-serif; /* 폰트 통일 */
    background-color: transparent; /* body 배경색이 그대로 보이도록 */
  }
</style>

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tripin - 당신만의 여행 파트너</title>
     <script src="https://cdn.tailwindcss.com/3.4.16"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: { primary: '#4F46E5', secondary: '#10B981' },
                    borderRadius: {
                        'none': '0px',
                        'sm': '4px',
                        'DEFAULT': '8px',
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
        };
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
    <link href="${pageContext.request.contextPath}/resources/css/mainpage.css" rel="stylesheet" type="text/css">
   <script>
  const pageContextPath = '${pageContext.request.contextPath}';
  const contextPath = '${pageContext.request.contextPath}';
</script>

</head>
<body data-current-user-id="${not empty user ? user.user_id : ''}" class="bg-[#f9fafb]">
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
				<a href="<c:url value='/logout'/>"
   class="inline-flex items-center px-4 py-2 text-sm font-medium text-primary border border-primary rounded-md
          hover:bg-primary hover:text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary
          dark:text-secondary dark:border-secondary dark:hover:bg-secondary dark:hover:text-gray-900
          transition-colors duration-150 ease-in-out">
    <i class="ri-logout-box-r-line mr-2"></i>
    로그아웃
</a>
			</div>
		</div>
	</header> 
	
<!-- 히어로 섹션 -->
<section class="relative h-[85vh] overflow-hidden">

        <!-- 이미지 슬라이드 -->
        <div class="absolute inset-0 z-0">
            <img src="${pageContext.request.contextPath}/resources/img/경복궁봄.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/경복궁여름.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/경복궁2.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/현대와전통.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/근정전겨울.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/한복.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/단청.jpg" class="slide-img" />
            <img src="${pageContext.request.contextPath}/resources/img/경복궁처마.jpg" class="slide-img" />
           
           
        </div>
 
  <!-- 텍스트 오버레이 -->
<div class="absolute bottom-12 left-12 z-20 bg-white/0 text-white px-10 py-6 rounded-xl text-left max-w-2xl shadow-none">

  <!-- 제목 -->
 <h1 class="text-4xl md:text-6xl font-bold mb-4 drop-shadow-md leading-snug">
    당신만의 특별한 여행을 디자인하세요
  </h1>
  
  <!-- 설명 (한 줄 + 글씨 크기 키움) -->
   <p class="text-2xl md:text-3xl mb-5 text-white/90 drop-shadow-sm leading-relaxed">
    다양한 여행 코스와 함께<br> 잊지 못할 추억을 만들어보세요
  </p>

  <!-- 버튼들 (글자 크기, 패딩 확대) -->
  <div class="flex flex-col sm:flex-row justify-center gap-4">
    
    <!-- 버튼 1 -->
    <a href="${pageContext.request.contextPath}/destinationdetail"
       class="bg-primary text-white text-lg md:text-xl px-8 py-4 rounded-button font-semibold whitespace-nowrap">
      여행지 알아보기
    </a>
    
    <!-- 버튼 2 -->
    <a href="chatbot" class="bg-white text-primary border border-primary text-lg md:text-xl px-8 py-4 rounded-button font-semibold whitespace-nowrap">
      트리비와 함께 나만의 여행지찾기
    </a>

  </div>
</div>

</section>
 
  

<!-- 추가 스타일 -->
<style>
  .slide-img {
    position: absolute;
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: opacity 1s ease-in-out;
    opacity: 0;
  }
  .slide-img.active {
    opacity: 1;
  }
</style>

<!-- 자동 슬라이드 전환 JS -->
<script>
  document.addEventListener('DOMContentLoaded', () => {
    const slides = document.querySelectorAll('.slide-img');
    let current = 0;
    slides[current].classList.add('active');
    setInterval(() => {
      slides[current].classList.remove('active');
      current = (current + 1) % slides.length;
      slides[current].classList.add('active');
    }, 8000); //  이미지 전환
  });
</script>


<!-- 테마별 추천 여행지 -->
<section class="py-16 bg-white">
  <div class="container mx-auto px-4">
  <!-- 제목과 슬라이드 버튼 -->
    <div class="flex justify-between items-center mb-8 relative">
      <h2 class="text-2xl font-bold text-gray-900">테마별 여행지</h2>
      <div class="flex gap-2">
      <!-- ✅ 슬라이드 버튼 클래스 추가됨 -->
        <button class="btn-prev arrow-btn left">
          <i class="ri-arrow-left-s-line ri-lg"></i>
        </button>
        <button class="btn-next arrow-btn right">
          <i class="ri-arrow-right-s-line ri-lg"></i>
        </button>
      </div>
    </div>

    <div class="relative overflow-hidden">
      <div class="theme-slider flex overflow-x-auto whitespace-nowrap scroll-smooth space-x-6">
        
      <!-- 카드 1: 역사 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/광화문.jpg" alt="역사" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color:rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-primary/80 rounded-full">역사</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 3px 3px 6px rgba(0, 0, 0, 0.9);">한국의 역사 유적지</h3>

                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">경복궁, 창덕궁, 수원화성</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 카드 2: 자연 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/제주주상절리.jpg" alt="자연" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-secondary/80 rounded-full">자연</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">한국의 아름다운 해안</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">제주도, 부산 해운대, 강릉</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 카드 3: 도시 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/롯데타워.jpg" alt="도시" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-pink-500/80 rounded-full">도시</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">도시 문화 탐방</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">서울, 부산, 인천</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 카드 4: 음식 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/한정식.jpg" alt="음식" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-orange-500/80 rounded-full">음식</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">맛있는 한국 음식</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">전주, 안동, 부산</p>
                </div>
              </div>
            </div>
          </div>
        </div>

       <!-- 카드 5: 휴양림 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/달음산자연휴양림.jpg" alt="휴식" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-green-500/80 rounded-full">휴식</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">휴양림코스</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">경기, 강원, 제주</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 카드 6: 한국체험-->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/딸기체험.jpg" alt="체험" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-red-400/80 rounded-full">체험</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">체험.액티비티</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">경기, 인천, 강원</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 카드 7: 캠핑 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/캠핑1.jpg" alt="캠핑" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-sky-400 rounded-full">캠핑</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">캠핑</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">서울, 경기, 인천</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 카드 8: 지역축제 -->
        <div class="w-full sm:w-1/2 lg:w-1/4 flex-shrink-0">
          <div class="rounded-lg overflow-hidden shadow-md group">
            <div class="relative h-56">
              <img src="${pageContext.request.contextPath}/resources/img/라벤더축제.jpg" alt="축제" class="w-full h-full object-cover object-top">
              <div class="absolute inset-0 flex items-end p-4">
                <div style="background-color: rgba(0,0,0,0.3); padding: 6px 12px; border-radius: 8px;">
                  <span class="text-white text-xs font-medium px-2 py-1 bg-purple-500 rounded-full">축제</span>
                  <h3 class="text-white text-lg font-bold mt-2" style="text-shadow: 2px 2px 4px rgba(0,0,0,0.7);">지역축제</h3>
                  <p class="text-white/90 text-sm" style="text-shadow: 1px 1px 3px rgba(0,0,0,0.6);">서울, 부산, 제주</p>
                </div>
              </div>
            </div>
          </div>
        </div>

      </div><!-- .theme-slider -->
    </div><!-- .overflow-hidden -->
  </div>
</section>




    <!-- 날씨 및 인기 여행지 -->
    <section class="py-16 bg-gray-50">
        <div class="container mx-auto px-4">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
  
      <div class="bg-white/85 rounded-lg shadow-lg p-6 backdrop-blur-0 relative"> 
    <div class="flex justify-between items-center mb-4"> 
        <h3 class="text-xl font-bold text-gray-900">실시간 날씨 정보</h3>
        
     
        <div class="weather-slider-controls flex space-x-2">
            <button 
                id="weatherPrevBtn"
                aria-label="이전 날씨 정보" 
                class="bg-gray-200 hover:bg-gray-400 text-gray-600 hover:text-gray-800
                       w-7 h-7 sm:w-8 sm:h-8 rounded-full shadow-sm flex items-center justify-center 
                       focus:outline-none focus:ring-1 focus:ring-offset-1 focus:ring-primary/50
                       transition-colors duration-150 ease-in-out"
            >
                <i class="ri-arrow-left-s-line text-lg sm:text-xl"></i>
            </button>
            <button 
                id="weatherNextBtn"
                aria-label="다음 날씨 정보" 
                class="bg-gray-200 hover:bg-gray-400 text-gray-600 hover:text-gray-800
                       w-7 h-7 sm:w-8 sm:h-8 rounded-full shadow-sm flex items-center justify-center 
                       focus:outline-none focus:ring-1 focus:ring-offset-1 focus:ring-primary/50
                       transition-colors duration-150 ease-in-out"
            >
                <i class="ri-arrow-right-s-line text-lg sm:text-xl"></i>
            </button>
        </div>
    </div>
    
   
    <div class="weather-slider-wrapper relative"> 
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 weather-container overflow-hidden"> 
            <c:if test="${empty weatherList}">
                <p class="text-center text-gray-500 col-span-full py-4">날씨 정보를 불러올 수 없습니다.</p>
            </c:if>

            <c:forEach var="weather" items="${weatherList}">
                <div class="bg-blue-100 rounded-lg p-4 weather-card flex-shrink-0 w-full">
                    <div class="flex items-center mb-2">
                        <div class="w-8 h-8 flex items-center justify-center text-blue-500">
                            <c:choose>
                                <c:when test="${weather.pty == '맑음'}"><i class="ri-sun-line ri-lg"></i></c:when>
                                <c:when test="${weather.pty == '구름많음' || weather.pty == '흐림'}"><i class="ri-cloudy-2-line ri-lg"></i></c:when>
                                <c:when test="${weather.pty == '비' || weather.pty == '소나기'}"><i class="ri-showers-line ri-lg"></i></c:when>
                                <c:when test="${weather.pty == '눈'}"><i class="ri-snowy-line ri-lg"></i></c:when>
                                <c:otherwise><i class="ri-question-mark ri-lg"></i></c:otherwise>
                            </c:choose>
                        </div>
                        <span class="font-medium ml-2">${weather.region}</span>
                    </div>
                    <div class="text-2xl font-bold">${weather.temp}°C</div>
                    <div class="text-sm text-gray-500">
                     
                        <c:if test="${not empty weather.pty && weather.pty != '없음' && weather.pty != '맑음'}">, ${weather.pty}</c:if>
                         습도 ${weather.humidity}%
                    </div>
                </div>
            </c:forEach>
        </div>        
    </div>

     <!-- 기상청 연결하기 -->
    <div class="mt-6">
        <a href="https://www.weather.go.kr/w/index.do" target="_blank"
           class="block w-full sm:w-1/2 mx-auto bg-blue-100 rounded-lg p-3 sm:p-4 text-center shadow hover:bg-blue-200 transition">
            <span class="text-blue-700 font-semibold text-base sm:text-lg">다른지역 날씨보기</span>
        </a>
    </div>
</div>      
          


                      
 
   
                
                <!-- 인기 여행지 -->
                
                <div class="bg-white/85 rounded-lg shadow-lg p-6 lg:col-span-2 backdrop-blur-0">
                <div class="flex justify-between items-center mb-3">
  <h2 class="text-lg font-semibold text-gray-900">추천 여행지</h2>
 <button id="refreshDestBtn" title="새로 추천받기"
  class="absolute top-3 right-3 p-2.5 w-10 h-10 md:w-12 md:h-12 rounded-full
         bg-white shadow hover:bg-gray-100 transition flex items-center justify-center">
  <i class="ri-refresh-line text-xl md:text-2xl text-gray-600 hover:text-blue-500 transition-transform duration-300"></i>
</button>


  <button id="refreshDestBtn" class="text-sm text-blue-500 hover:underline"> 
  </button>
</div>
  <div id="topDestinations" class="space-y-4"></div> <!-- 여기에 JS로 삽입 -->
</div>
    </section>






    
    <!-- 리뷰 섹션 -->
<section class="py-16 bg-white">
  <div class="container mx-auto px-4">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-bold text-gray-900 mb-4">여행자들의 생생한 후기</h2>
      <p class="text-gray-600 max-w-2xl mx-auto">Tripin과 함께한 여행자들의 실제 경험담을 들어보세요</p>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto">
      <c:forEach var="review" items="${randomReviews}">
        <div class="bg-gray-50 rounded-lg p-6 shadow-lg">
          <div class="flex text-yellow-400 mb-3">
            <!-- full_stars, half_star, empty_stars 로 변경 -->
            <c:forEach begin="1" end="${review.full_stars}"><i class="ri-star-fill"></i></c:forEach>
            <c:if test="${review.half_star}"><i class="ri-star-half-fill"></i></c:if>
            <c:forEach begin="1" end="${review.empty_stars}"><i class="ri-star-line"></i></c:forEach>
          </div>
          <p class="text-gray-700 mb-4">"${fn:escapeXml(review.content)}"</p>
          <div class="flex items-center">
            <div class="w-10 h-10 rounded-full bg-gray-300 flex items-center justify-center text-gray-600 mr-3">
              <i class="ri-user-line"></i>
            </div>
            <div>		           
				<div class="font-medium text-gray-900">
				  ${fn:escapeXml(review.user_name)}
				</div>
				<div class="text-sm text-gray-500">
				  ${fn:escapeXml(review.dest_name)}
				</div>

            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>
</section>
 



    <!-- 푸터 -->
     <footer class="bg-[#0c1a2b] text-white pt-16 pb-8 relative z-0">
  <div class="container mx-auto px-4">
    <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-12">
      <div>
        <a href="#" class="font-['Pacifico'] text-white text-2xl mb-4 block">Tripin</a>
        <p class="text-gray-300 mb-4">당신의 특별한 여행을 위한 최고의 파트너, Tripin과 함께 잊지 못할 추억을 만들어보세요.</p>
        <div class="flex space-x-4">
          <a href="#" class="text-gray-400 hover:text-white"><i class="ri-instagram-line"></i></a>
          <a href="#" class="text-gray-400 hover:text-white"><i class="ri-facebook-circle-line"></i></a>
          <a href="#" class="text-gray-400 hover:text-white"><i class="ri-youtube-line"></i></a>
          <a href="#" class="text-gray-400 hover:text-white"><i class="ri-twitter-x-line"></i></a>
                </div>
                </div>
                
                <div>
                    <h3 class="text-lg font-bold mb-4">서비스</h3>
                    <ul class="space-y-2 text-gray-300">
                      <li><a href="destinationdetail" class="hover:text-white">여행지 검색</a></li>
                   <li><a href="place_list.do" class="hover:text-white">테마 여행</a></li>
                     <li><a href="mypage" class="hover:text-white">마이페이지</a></li>
                    <li><a href="destinationdetail" class="hover:text-white">리뷰 및 평점</a></li>
                    
                    </ul>
                </div>
                
                <div>
                    <h3 class="text-lg font-bold mb-4">FAQ</h3>
                    <ul class="space-y-2 text-gray-300">
          <li><a href="chatbot" class="hover:text-white">자주 묻는 질문</a></li>
          <li><a href="chatbot" class="hover:text-white">1:1 문의</a></li>
          <li><a href="chatbot" class="hover:text-white">이용약관</a></li>
          <li><a href="chatbot" class="hover:text-white">개인정보처리방침</a></li>
          <li><a href="chatbot" class="hover:text-white">사이트맵</a></li>
        </ul>
      </div>
                
               <div>
        <h3 class="text-lg font-bold mb-4">연락처</h3>
        <ul class="space-y-2 text-gray-300">
          <li class="flex items-center"><i class="ri-map-pin-line mr-2"></i>서울특별시 마포구 백범로 23</li>
          <li class="flex items-center"><i class="ri-phone-line mr-2"></i>02-739-7235</li>
          <li class="flex items-center"><i class="ri-mail-line mr-2"></i>info@tripin.kr</li>
        </ul>
      </div>
    </div> 
            <div class="border-t border-gray-700 pt-8">
                <p class="text-gray-400 text-sm text-center">© 2025 Tripin. All rights reserved.</p>
            </div>
        </div>
    </footer>
<!-- 방문자 수 출력 -->
<div id="visitCount" class = "hidden" style="font-weight: bold; margin-top: 20px;">
  오늘 방문자 수: ${todayCount}
</div>

<!-- jQuery 로드 -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>


<!-- mainpage.js는 contextPath 선언 후 1회만 로드 -->
<script src="${pageContext.request.contextPath}/resources/js/mainpage.js"></script>

</body>
</html>


