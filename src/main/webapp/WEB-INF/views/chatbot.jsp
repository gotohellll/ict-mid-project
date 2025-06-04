<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix='c' uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title> 챗봇 페이지 </title>
<link rel="icon" href="/tripin2/resources/img/favicon.ico">
<!-- Pacifico 폰트 링크 -->
<link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
<!-- Noto Sans KR 폰트 링크 -->
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&amp;display=swap" rel="stylesheet">
<!-- Remix icon 아이콘 폰트 라이브러리 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
<!-- 내 css 파일경로 -->
<link href="/tripin2/resources/css/chatbot.css" rel="stylesheet">
<!-- jquery -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- 내 js 파일경로 -->
<script type="text/javascript" src="/tripin2/resources/js/chatbot.js"></script>
<!-- 향후 null값 고려해서 if절 써야함 -->
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
	
	
		<main class="main-section">
			<div class="max-w-5xl mx-auto">
				<div class="main-text">
					<h1 class="main-title">
						AI 여행 플래너와 함께<br>나만의 테마여행을 계획해보세요
					</h1>
					<p class="main-subtext">
						여행 계획부터 문의사항까지<br>AI가 도와드립니다
					</p>
				</div>
				<div class="card-box">
					<div class="tab-buttons">
						<button id="travelTab" class="tab-active">여행 계획</button>
						<button id="supportTab"	class="tab-inactive">고객 문의</button>
					</div>
					<div class="flex gap-6">
						<div id="chat-reco-container" class="chat-container">
							<div class="chat-message">
								<div class="chat-row chat-row-left">
									<div class="chat-avatar">
										<i class="ri-robot-line text-white"></i>
									</div>
									<div class="chat-content">
										<div class="chat-bubble">
											<p class="chat-text">안녕하세요! 저는 당신의 AI여행 플래너 '트리비'입니다. 어떤 여행을 계획하고 계신가요?</p>
										</div>
										<div class="chat-options">
											<button class="option-button">
												<i class="ri-group-line mr-2"></i>가족 여행
											</button>
											<button class="option-button">
												<i class="ri-heart-line mr-2"></i>커플 여행
											</button>
											<button class="option-button">
												<i class="ri-user-line mr-2"></i>혼자 여행
											</button>
											<button class="option-button">
												<i class="ri-user-line mr-2"></i>친구와 함께
											</button>
										</div>										
									</div>
								</div>

								
							</div>
						</div>
						<!-- 고객문의 기본 -->
						<div id="chat-inq-container" class="chat-container">
							<div class="chat-message">
								<div class="chat-row chat-row-left">
									<div class="chat-avatar">
										<i class="ri-robot-line text-white"></i>
									</div>
									<div class="chat-content">
										<div class="chat-bubble">
											<p class="chat-text">안녕하세요! 고객센터입니다. 문의하실 내용을 선택해주세요!</p>
										</div>
										<div class="chat-options">
											<button class="option-inq-button">
												<i class="ri-group-line mr-2"></i>이용 문의
											</button>
											<button class="option-inq-button">
												<i class="ri-heart-line mr-2"></i>신고 문의
											</button>
											<button class="option-inq-button">
												<i class="ri-user-line mr-2"></i>추천 문의
											</button>
											<button class="option-inq-button">
												<i class="ri-user-line mr-2"></i>관리자 문의
											</button>
										</div>										
									</div>
								</div>
							</div>
						</div>
						
						<div class="message-input-wrapper">
							<div class="message-input-row">
								<input type="text" placeholder="메시지를 입력하세요..." class="message-input">
								<button id="send_btn" class="message-input">
									<i class="ri-send-plane-fill"></i> 보내기
								</button>
							</div>
						</div>
					</div>
					
					
				</div>
			</div>
		</main>
		<footer class="custom-footer">
	        <div class="footer-container">
	            <div class="footer-content">
	                <div class="footer-left">
	                    <p class="footer-text">© 2025 Tripin. 모든 권리 보유.</p>
	                </div>
	                <div class="footer-links">
	                    <a href="#">고객센터</a>
	                    <a href="#">개인정보 처리방침</a>
	                    <a href="#">이용약관</a>
	                    <a href="#">로그아웃</a>
	                </div>
	            </div>
	        </div>
   		 </footer>
	
	<script type="text/javascript" crossorigin="anonymous"
		src="https://us-assets.i.posthog.com/array/phc_t9tkQZJiyi2ps9zUYm8TDsL6qXo4YmZx0Ot5rBlAlEd/config.js"></script>
	<script type="text/javascript" crossorigin="anonymous"
		src="https://us-assets.i.posthog.com/static/dead-clicks-autocapture.js?v=1.240.6"></script>



</body>
</html>