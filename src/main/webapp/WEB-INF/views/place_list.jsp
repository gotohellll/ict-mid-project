<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix='c' uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Tripin - 여행지 검색</title>
<script src="https://cdn.tailwindcss.com/3.4.16"></script>
<!-- css파일연결 -->
<link href="/tripin2/resources/css/css_place_list.css" rel="stylesheet" type="text/css">
<!-- Pacifico 폰트 링크 -->
<link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
<!-- Noto Sans KR 폰트 링크 -->
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&amp;display=swap" rel="stylesheet">
<!-- Remix icon 아이콘 폰트 라이브러리 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
<!-- jquery -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- js파일 -->
<script type="text/javascript" src="/tripin2/resources/js/place_list.js"></script>
<!-- favicon -->
<link rel="icon" href="/tripin2/resources/img/favicon.ico">
</head>
<body>
 <c:choose>
    <c:when test="${not empty sessionScope.user};">
        <script>
            const USER_ID = ${sessionScope.user.user_id};
        </script>
    </c:when>
    <c:otherwise>
        <script>
            const USER_ID = null;
        </script>
    </c:otherwise>
</c:choose>
</head>
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
	
	
 <!-- 메인 -->
  <main class="container column-layout">
  <div>
  <!-- 검색창 -->
    <section class="search-section full-width">
       <form action=""> 
   		<div class="search-box">
	        <div class="search-icon">
	          <i class="ri-search-line ri-lg"></i>
	        </div>
	        <input type="text" class="search-input" name="searchKeyword" placeholder="여행지, 명소, 체험 검색">
	        <input class="search-button" type="submit" value="검색">
   		</div>
	  </form>
      <!-- <form action="fetch" method="get">
      	<button type="submit">최신여행정보 불러오기</button>
      </form> -->
    </section>
  </div>
  <!-- 테마 필터 -->
  <div class="theme-filter-wrapper scroll-container">
  	<div class="theme-filter-scroll">
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-landscape-line ri-xl"></i>
  			</div>
  			<span data-value="1">자연</span>
  		</button>
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-ancient-pavilion-line ri-xl"></i>
  			</div>
  			<span data-value="2">문화</span>
  		</button>
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-run-line ri-xl"></i>
  			</div>
  			<span data-value="3">레저</span>
  		</button>
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-restaurant-line ri-xl"></i>
  			</div>
  			<span data-value="4">맛집</span>
  		</button>
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-hotel-line ri-xl"></i>
  			</div>
  			<span data-value="5">숙소</span>
  		</button>
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-shopping-bag-line ri-xl"></i>
  			</div>
  			<span data-value="6">쇼핑</span>
  		</button>
  		<button class="theme-button">
  			<div class="theme-icon">
  				<i class="ri-calendar-event-line ri-xl"></i>
  			</div>
  			<span data-value="7">축제</span>
  		</button>
  	</div>
  </div>
  
  <!-- 필터옵션 -->
  <section class="filter-bar">
  	
  	<div class="filter-left">
  		<span class="filter-label">정렬기준 : </span>
  		<div class="sort-dropdown">
  			<button class="sort-button"  id="sort-button" type="button">
  				<span id="selectedSort">
  					<c:choose>
  						<c:when test="${param.sort == '최신순'}">최신순</c:when>
  						<c:otherwise>인기순</c:otherwise>
  					</c:choose>
  				</span> 
  				<i class="ri-arrow-down-s-line"></i>
  			</button>
  			<div class="dropdown-menu" id="dropdown-menu">
  				<div class="dropdown-item" data-value="인기순">인기순</div>
  				<div class="dropdown-item" data-value="최신순">최신순</div>  			
  			</div>
  		</div>
  	</div>
  	<form action="place_list" method="get" id="filter-form">
	  	<input type="hidden" name="theme_id" id="theme_id">
	  	<input type="hidden" name="sort" id="sort">
  	</form>
	<div class="filter-right">
		<button class="reset-button" onclick="location.href='place_list.do'">
			<i class="ri-refresh-line reset-icon"></i>
			<span>필터 초기화</span>
		</button>
	</div>
  </section>
  <!-- 검색 결과 목록 : db연결 -->
  <section class="result-bar">
  	<!-- 여행지카드 -->
  	
  	<c:forEach var="place" items="${placeList}">
	  	<div class="place-card" data-dest-id="${place.dest_id}">
	  	<!-- 이미지 유무 -->
	  	<c:choose>
	  		<c:when test="${empty place.repr_img_url}">
	  			<div class="skeleton-img shimmer"></div>
	  		</c:when>
	  		<c:otherwise>
		  		<img  class="place-img" 
		  		src="${place.repr_img_url}" 
		  		alt="${place.dest_name}">	  			
	  		</c:otherwise>
	  	</c:choose>	

        <button class="bookmark" type="button">
        
        		<i class="ri-heart-line text-red-500"></i>
        	
         	
        		
        	
        </button>
    
	  		
	  		<div class="place-content">
	  			<h3 class="place-title">${place.dest_name}</h3>
	  			<p class="place-text">${place.rel_keywords}</p>
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
  	</c:forEach>
  </section>
  <!-- 더 불러오기 버튼 -->
  <div class="load-more-wrapper">
  	<button class="load-more-btn">
  		<span class="load-more-text">더 보기</span>
  		<div class="load-more-icon">
  			<i class="ri-arrow-down-s-line"></i>
  		</div>
  	</button>
  
  
  </div>
  </main>
 
 
</body>
</html>