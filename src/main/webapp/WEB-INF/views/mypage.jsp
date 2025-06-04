<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix='c' uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마이페이지</title>
<link rel="icon" href="/tripin2/resources/img/favicon.ico">
<!-- Pacifico 폰트 링크 -->
<link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
<!-- Noto Sans KR 폰트 링크 -->
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&amp;display=swap" rel="stylesheet">
<!-- Remix icon 아이콘 폰트 라이브러리 -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
<!-- 내 css 파일경로 -->
<link href="/tripin2/resources/css/mypage.css" rel="stylesheet">
<!-- jquery -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
<!-- 내 js 파일경로 -->
<script type="text/javascript" src="/tripin2/resources/js/mypage.js"></script>
<script src="https://cdn.tailwindcss.com/3.4.16"></script>
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
<body>
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

    <a href="<c:url value='mypage'/>" style="text-decoration:none;"
       title="${fn:escapeXml(userNotificationTitle)}"
       class="p-2 rounded-full text-gray-500 hover:text-gray-700 hover:bg-gray-100 relative flex items-center justify-center w-10 h-10">
        <i class="ri-notification-3-line ri-lg" style="text-decoration:none;"></i>

       
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
<a href="<c:url value='mypage'/>" style="text-decoration:none;">
					<i class="ri-user-line" style="text-decoration:none;"></i>
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
	
	
      
	
	<main class="main-container">
    
    	<!-- user_id 가져왔을 때 프로필 섹션-->
    	<section class="profile-section">
            <div class="profile-container">
                <div class="profile-image-wrapper">
                    <div class="profile-image-box">
                        <img class="profile-image" src="https://search.pstatic.net/common/?src=http%3A%2F%2Fimgnews.naver.net%2Fimage%2F5401%2F2024%2F09%2F20%2F0000318721_003_20240920144609446.jpg&type=sc960_832">
                    </div>
                </div>
                <div class="profile-text">
                	<input type="hidden" id="user_id" value="${user.user_id }"/>
                    <h1 id="profile-name" class="profile-name">${user.user_name}</h1>
                    <p id="profile-login" class="profile-login">${user.login_id}</p>
                    <div class="profile-tags">
                    	<c:if test="${ reviewCount >= 5 }">
                    		<span class="tag blue">여행 애호가</span>
                    	</c:if>
                        <span class="tag green">리뷰 ${reviewCount}개</span>
                    </div>
                </div>
                <button id="edit-profile-btn" class="edit-profile-btn">
                    프로필 편집
                </button>
                
                
                <!-- 프로필편집 팝업창 -->
				<div id="profile-modal" class="modal-wrapper" style="display: none;">
					<div class="modal-content">
						<span class="close-btn">&times;</span>
						<h2>프로필 편집</h2>
						
						<div class="profile-image-wrapper">
							<label for="profileImage" class="image-label"> <img id="profilePreview" src="" alt="프로필 이미지"
								class="profile-image-edit">
								<input type="file" id="profileImage" name="profileImage" accept="image/*" style="display: none;">
							</label>
							<div class="image-instruction">클릭하여 수정</div>
						</div>
						
						<!-- 사진편집 시 enctype="multipart/form-data" -->
						<form id="profile-form" action="updateUser.do" method="post">
							<input type="hidden" name="user_id" value="${user.user_id}"/>
							<input type="hidden" id="beforePass" value="${user.password}"/>
							<!-- 닉네임 -->
							<div class="form-group">
								<label for="user_name">닉네임</label> <input type="text"
									id="user_name" name="user_name" value="${user.user_name}"
									required>
							</div>

							<!-- 비밀번호 -->
							<div class="form-group">
								<label for="password">비밀번호</label> 
								<input type="hidden" id="password" name="password">
								<input type="password" id="password-input" >
								<button type="button" id="edit-password-btn" class="edit-btn">비밀번호 수정</button>
								
								
								<div id="update_pass_group" class="form-group">
									<label for="update_pass">새로운 비밀번호</label> <input type="password" id="update_pass">
									<label for="update_pass_confirm">비밀번호 확인</label> <input type="password" id="update_pass_confirm">
								</div>
								<small id="password-message" style="color: red; ">비밀번호가 일치하지 않습니다.</small>
							</div>

							<!-- 휴대폰번호 -->
							<div class="form-group">
								<label for="phone_num">휴대폰번호</label> <input type="text" id="phone_num"
									name="phone_num" value="${user.phone_num}">
							</div>


							<button type="submit" class="submit-btn" disabled>저장</button>
						</form>
					</div>
				</div>
				<!-- end of 프로필 편집 -->
				
			</div>
        </section>        

        <!-- 탭 네비게이션 -->
        <div class="tab-section">
            <div class="tab-header">
                <button class="tab-button" id="place-saved">저장한 여행지</button>
                <button class="tab-button" id="review-written">내가 작성한 리뷰</button>
                <button class="tab-button" id="my-inquiries">내 문의</button>
            </div>
			
            <!-- 저장 콘텐츠 탭 컨텐츠 -->
            <div id="content-saved" class="p-6">                

                <!-- 저장한 여행지 탭 -->
                <div id="content-places" class="content-hidden">
                    <div class="places-grid">
                    
                    	<!-- ************데이터베이스에서 가져온 것들 forEach 돌리기 ***********-->
                     	<c:forEach var="place" items="${places}">
	                    	<div class="place-card">
	                    		<input type="hidden" class="dest_id" value="${place.dest_id}">
	                            <div class="place-image-wrapper">
	                                   <c:choose>
								        <c:when test="${empty place.repr_img_url}">
								           <div class="skeleton-img"></div>
								        </c:when>
								        <c:otherwise>
								          <img src="${place.repr_img_url}">
								       </c:otherwise>
								    </c:choose>
	                            </div>
	               					<div class="place-info">	                            	
	                                <h3 class="place-title">${place.dest_name }</h3>
	                                <p class="place-location">${place.full_address}</p>
	                                <div class="place-rating">
	                                    <div class="stars">
	                                    <!-- avg(rating) 만큼 for문 돌리기(소수점 고려해야함) -->
	                                    <c:forEach begin="1" end="${place.avg_rating}">
	                                    	<i class="ri-star-fill"></i>
	                                    </c:forEach>
	                                    
	                                        <i class="ri-star-half-fill"></i>
	                                    </div>
	                                    <!-- dest_id의 여행지 상세페이지로 이동(리뷰도 거기 있음)-->
	                                    <a href ="">
	                                    	<!-- reviews 테이블에서 dest_id로 group by하고 avg(rating) 가져오기 -->
	                                    	<span id="review-avg" class="review-text">${place.avg_rating}</span>
	                                    	<!-- reviews 테이블에서 dest_id로 group by하고 count(rating) 가져오기 -->
	                                    	<span id="review-count" class="review-text">(${place.review_count} 리뷰)</span>
                                   		</a>
	                                </div>
	                                <div class="place-actions">
	                                    <button class="detail-button">
	                                        <i class="ri-information-line mr-1"></i> 상세정보
	                                    </button>
	                                    <button class="heart-button">
	                                        <i class="icon ri-heart-fill"></i>
	                                    </button>
	                                </div>
	                            </div>
	                        </div>
                    	</c:forEach> 
                        
                    </div>
                </div>
                               
				<!-- 내가 작성한 리뷰 탭 컨텐츠 -->
                
                <div id="content-reviews" class="content-hidden">
                    <div class="review-list">
                    	<!-- *********리뷰 forEach 돌리기********* -->
                    	<c:forEach var="review" items="${reviews }">
	                    	<div class="review-card">
	                    	<input type="hidden" class="review_id" value='${review.review_id}' />
	                            <div class="review-header">
	                                <div class="review-place">
	                                    <div class="review-avatar">
	                                        <img src="https://readdy.ai/api/search-image?query=beautiful%20landscape%20of%20Gyeongbokgung%20Palace%2C%20Seoul%2C%20South%20Korea%2C%20traditional%20Korean%20architecture%2C%20palace%20grounds%2C%20travel%20destination&amp;width=100&amp;height=100&amp;seq=12&amp;orientation=squarish" alt="경복궁">
	                                    </div>
	                                    <div>
	                                    	<!-- dests랑 조인해야되서 reviewVO에 dest_name 멤버 추가 해야됨 -->
	                                        <h3 class="place-title">${review.dest_name}</h3>
	                                        <div class="star-rating">
	                                        	<!-- ${review.rating} 값으로 for문 돌려야함-->
	                                        	
	                                            <c:forEach begin="1" end="${review.rating}">
											        <i class="ri-star-fill"></i>
											    </c:forEach>
	                                        </div>
	                                    </div>
	                                </div>
	                              <span class="review-text">
    <fmt:formatDate value="${review.created_at}" pattern="yyyy년 MM월 dd일" />
</span>
	                            </div>
	                            <p class="review-text">${review.content}</p>

								<c:if test="${not empty review.image_path}">
									<div class="review-photos flex flex-wrap gap-2 mt-2">
										<c:forTokens items="${review.image_path}" delims=","
											var="imgPath">
											<c:if test="${not empty fn:trim(imgPath)}">
												<div
													class="photo-thumbnail w-24 h-24 rounded overflow-hidden border">
													<img src="<c:url value='${fn:trim(imgPath)}'/>" alt="리뷰 사진"
														class="w-full h-full object-cover cursor-pointer review-modal-trigger"
														<%-- 클릭 시 모달 띄우기 위한 클래스 (선택적) --%>
                         data-full-image="<c:url value='${fn:trim(imgPath)}'/>">
												</div>
											</c:if>
										</c:forTokens>
									</div>
								</c:if>

								<div class="review-actions">
	                                <button class="action-button update">
	                                    <i class="ri-edit-line mr-1"></i> 수정
	                                </button>
	                                <button class="action-button delete">
	                                    <i class="ri-delete-bin-line mr-1"></i> 삭제
	                                </button>
	                            </div>
	                        </div>                    	
                    	</c:forEach>
                        
                    </div>
                </div>
                
                <!-- 내 문의 탭 컨텐츠 -->
                
                <div id="content-inquiries" class="content-hidden">
                    <div class="inquiry-list">
                    	<!-- *********문의 forEach 돌리기********* -->
                    	<c:forEach var="inquiry" items="${inquiries}">
	                    	<div class="inquiry-card">
	                    		<input type="hidden" class="chat_inq_id" value="${inquiry.chat_inq_id}"/>
	                    		<input type="hidden" class="user_id" value="${inquiry.user_id}"/>
	                            <div class="inquiry-header">
	                                <span class="inquiry-date">${inquiry.conv_at}</span>
	                            </div>
								<div class="inquiry-content">
									<p class="inquiry-text">${inquiry.user_query}</p>
									<button class="action-button delete_inquiry">
										<i class="ri-delete-bin-line mr-1"></i> 삭제
									</button>
								</div>
								<hr/>
	                            <!-- nvl써서 null 일 때 '관리자가 답변 확인 중입니다' 확인. -->
	                            <p class="inquiry-text">${inquiry.admin_response}</p>
	                            <div class="inquiry-actions">
	                            </div>
	                        </div>
                    	</c:forEach>
                    
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
                    <a href="<c:url value='/logout'/>">로그아웃</a>
                </div>
            </div>
        </div>
    </footer>



<script src="https://static.readdy.ai/static/share.js"></script>

<script>
    // 이전 답변에서 사용한 DOMContentLoaded 이벤트 리스너 내부에 추가하거나,
    // 이 스크립트가 _layout.jsp 하단에 있다면 바로 작성 가능
    document.addEventListener('DOMContentLoaded', function() {
        const userMenuButton = document.getElementById('userMenuButton');
        const userDropdownMenu = document.getElementById('userDropdownMenu');

        if (userMenuButton && userDropdownMenu) {
            userMenuButton.addEventListener('click', function() {
                userDropdownMenu.classList.toggle('hidden');
            });

            // 드롭다운 외부 클릭 시 닫기
            document.addEventListener('click', function(event) {
                if (!userMenuButton.contains(event.target) && !userDropdownMenu.contains(event.target)) {
                    userDropdownMenu.classList.add('hidden');
                }
            });
        }

        // ... (기존 Toast 알림, 다른 페이지용 JS 등) ...
    });
</script>


</body>
</html>