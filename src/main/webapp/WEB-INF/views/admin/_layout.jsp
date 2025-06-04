<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>TripIn 관리자 - ${pageTitle}</title>
<%-- 각 페이지별 타이틀 --%>
<script src="https://cdn.tailwindcss.com/3.4.16"></script>
<script>
    const contextPath = "${pageContext.request.contextPath}";
    console.log("Global contextPath set to:", contextPath); // 초기화 확인용 로그
</script>
<script>tailwind.config={theme:{extend:{colors:{primary:'#4F46E5',secondary:'#818CF8'},borderRadius:{'none':'0px','sm':'4px',DEFAULT:'8px','md':'12px','lg':'16px','xl':'20px','2xl':'24px','3xl':'32px','full':'9999px','button':'8px'}}}}</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap"
	rel="stylesheet">
<link
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap"
	rel="stylesheet">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
<link rel="icon" href="../resources/img/favicon.ico">

<%-- ECharts (메인 대시보드, 통계 대시보드 등에서 사용) --%>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/echarts/5.5.0/echarts.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>


<%-- DataTables (사용자, 여행지, 리뷰 관리 등 테이블이 필요한 곳에 사용) --%>
<%-- jQuery (DataTables 의존성) --%>
<script src="https://code.jquery.com/jquery-3.7.0.js"></script>
<link
	href="https://cdn.datatables.net/1.13.6/css/dataTables.tailwindcss.min.css"
	rel="stylesheet">
<%-- Tailwind CSS용 DataTables --%>
<script
	src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script
	src="https://cdn.datatables.net/1.13.6/js/dataTables.tailwindcss.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<%-- Tailwind CSS용 DataTables --%>


<style>
:where([class^="ri-"])::before {
	content: "\f3c2";
}
body {
	font-family: 'Noto Sans KR', sans-serif;
	background-color: #f9fafb;

}

input[type="number"]::-webkit-inner-spin-button, input[type="number"]::-webkit-outer-spin-button
	{
	-webkit-appearance: none;
	margin: 0;
}
.dataTables_wrapper .dataTables_paginate .paginate_button { @apply px-3
	py-1 rounded-md border border-gray-300 text-sm mx-1;
	
}

.dataTables_wrapper .dataTables_paginate .paginate_button.current,
	.dataTables_wrapper .dataTables_paginate .paginate_button:hover:not(.disabled)
	{ @apply bg-primary text-white border-primary;
	
}

.dataTables_wrapper .dataTables_length select, .dataTables_wrapper .dataTables_filter input
	{ @apply bg-white border border-gray-300 rounded-md shadow-sm p-2
	text-sm;
	
}

.dataTables_wrapper .dataTables_paginate .paginate_button.disabled,
	.dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover,
	.dataTables_wrapper .dataTables_paginate .paginate_button.disabled:active
	{
	color: #9ca3af !important; 
	background-color: #f9fafb; 
	border-color: #e5e7eb;
}

.dataTables_wrapper .dataTables_paginate .paginate_button.current,
	.dataTables_wrapper .dataTables_paginate .paginate_button.current:hover
	{
	background-color: #4F46E5 !important; 
	color: white !important;
	border-color: #4F46E5 !important;
}

.dataTables_wrapper .dataTables_paginate .paginate_button:hover {
	background-color: #f3f4f6; 
	border-color: #e5e7eb;
	color: #111827 !important; 
}

.dataTables_wrapper .dataTables_paginate .paginate_button {
	color: #1f2937 !important; /* 글자색 - !important는 필요에 따라 */
	background-color: #ffffff; /* 기본 배경 흰색 */
	border: 1px solid #d1d5db; /* 테두리 */
	padding: 0.5em 0.75em;
	margin-left: 2px;
	border-radius: 0.375rem;
}
/* DataTables "개씩 보기" 드롭다운 스타일 */
.dataTables_wrapper .dataTables_length label, .dataTables_wrapper .dataTables_length select
	{
	color: #1f2937; /* Tailwind text-gray-800 (검은색 계열) */
}

.dataTables_wrapper .dataTables_length select {
	background-color: #ffffff; /* 흰색 배경 */
	border: 1px solid #d1d5db; /* Tailwind border-gray-300 */
	border-radius: 0.375rem; /* Tailwind rounded-md */
	padding: 0.3rem 1.75rem 0.3rem 0.5rem; /* 내부 여백 및 화살표 공간 확보 */
	/* appearance: none; */ /* 기본 OS 스타일 화살표 제거 (선택적, 커스텀 화살표 사용 시) */
}

/* DataTables "개씩 보기" 드롭다운 포커스 시 (선택적) */
.dataTables_wrapper .dataTables_length select:focus {
	outline: 2px solid transparent;
	outline-offset: 2px;
	border-color: #4F46E5; /* TripIn primary color */
	box-shadow: 0 0 0 2px #4F46E5; /* Tailwind ring-2 ring-primary */
}

/* DataTables "검색" 레이블 및 입력창 스타일 */
.dataTables_wrapper .dataTables_filter label, .dataTables_wrapper .dataTables_filter input
	{
	color: #1f2937; /* Tailwind text-gray-800 (검은색 계열) */
}

.dataTables_wrapper .dataTables_filter input[type="search"] {
	background-color: #ffffff; /* 흰색 배경 */
	border: 1px solid #d1d5db; /* Tailwind border-gray-300 */
	border-radius: 0.375rem; /* Tailwind rounded-md */
	padding: 0.5rem 0.75rem; /* 내부 여백 */
	margin-left: 0.5rem; /* "검색:" 레이블과의 간격 */
}

/* DataTables "검색" 입력창 포커스 시 (선택적) */
.dataTables_wrapper .dataTables_filter input[type="search"]:focus {
	outline: 2px solid transparent;
	outline-offset: 2px;
	border-color: #4F46E5; /* TripIn primary color */
	box-shadow: 0 0 0 2px #4F46E5; /* Tailwind ring-2 ring-primary */
}

/* DataTables 정보 텍스트 ("현재 1 - 10 / 23건") 스타일 */
.dataTables_wrapper .dataTables_info {
	color: #4b5563; /* Tailwind text-gray-600 */
	padding-top: 0.5em; /* DataTables 기본값과 유사하게 */
}

</style>
</head>
<body class="min-h-screen">
	<div class="flex h-screen overflow-hidden">
		<!-- 사이드바 -->
		<aside class="w-64 bg-white shadow-lg hidden md:block">
			<div class="h-full flex flex-col">
				<div class="h-16 flex items-center justify-start px-4">
					<a href="<c:url value='/admin/dashboard'/>"
						class="flex items-center"> <img
						src="<c:url value='/resources/img/logo.png'/>" alt="TripIn Logo"
						class="h-8 w-auto mr-2" />
					</a>
				</div>
				<nav class="flex-1 overflow-y-auto py-4">
					<ul class="space-y-1">
						<%-- 현재 페이지에 따라 active 스타일을 주기 위한 로직 필요 (예: requestURI 비교) --%>
						<c:set var="currentPath" value="${pageContext.request.requestURI}" />
						<li><a href="<c:url value='/admin/dashboard'/>"
							class="flex items-center px-4 py-3 text-sm font-medium rounded-r-full
                                <c:if test='${currentPath.endsWith("/admin/dashboard")}'>bg-primary bg-opacity-10 text-primary</c:if>
                                <c:if test='${!currentPath.endsWith("/admin/dashboard")}'>text-gray-600 hover:bg-gray-50 hover:text-primary</c:if>">
								<div class="w-5 h-5 flex items-center justify-center mr-3">
									<i class="ri-dashboard-line"></i>
								</div> <span>대시보드</span>
						</a></li>
						<li><a href="<c:url value='/admin/users'/>"
							class="flex items-center px-4 py-3 text-sm font-medium rounded-r-full
                                <c:if test='${currentPath.contains("/admin/users")}'>bg-primary bg-opacity-10 text-primary</c:if>
                                <c:if test='${!currentPath.contains("/admin/users")}'>text-gray-600 hover:bg-gray-50 hover:text-primary</c:if>">
								<div class="w-5 h-5 flex items-center justify-center mr-3">
									<i class="ri-user-settings-line"></i>
								</div> <span>사용자 관리</span>
						</a></li>
						<li><a href="<c:url value='/admin/destinations'/>"
							class="flex items-center px-4 py-3 text-sm font-medium rounded-r-full
                                <c:if test='${currentPath.contains("/admin/destinations")}'>bg-primary bg-opacity-10 text-primary</c:if>
                                <c:if test='${!currentPath.contains("/admin/destinations")}'>text-gray-600 hover:bg-gray-50 hover:text-primary</c:if>">
								<div class="w-5 h-5 flex items-center justify-center mr-3">
									<i class="ri-map-pin-line"></i>
								</div> <span>여행지 정보 관리</span>
						</a></li>
						<li><a href="<c:url value='/admin/reviews'/>"
							class="flex items-center px-4 py-3 text-sm font-medium rounded-r-full
                                <c:if test='${currentPath.contains("/admin/reviews")}'>bg-primary bg-opacity-10 text-primary</c:if>
                                <c:if test='${!currentPath.contains("/admin/reviews")}'>text-gray-600 hover:bg-gray-50 hover:text-primary</c:if>">
								<div class="w-5 h-5 flex items-center justify-center mr-3">
									<i class="ri-star-line"></i>
								</div> <span>리뷰 관리</span>
						</a></li>
						<li><a href="<c:url value='/admin/chat-inquiries'/>"
							class="flex items-center px-4 py-3 text-sm font-medium rounded-r-full
                                <c:if test='${currentPath.contains("/admin/chat-inquiries")}'>bg-primary bg-opacity-10 text-primary</c:if>
                                <c:if test='${!currentPath.contains("/admin/chat-inquiries")}'>text-gray-600 hover:bg-gray-50 hover:text-primary</c:if>">
								<div class="w-5 h-5 flex items-center justify-center mr-3">
									<i class="ri-feedback-line"></i>
								</div> <span>문의 내역</span>
						</a></li>
						<li><a href="<c:url value='/admin/logs'/>"
							class="flex items-center px-4 py-3 text-sm font-medium rounded-r-full
                                <c:if test='${currentPath.contains("/admin/logs")}'>bg-primary bg-opacity-10 text-primary</c:if>
                                <c:if test='${!currentPath.contains("/admin/logs")}'>text-gray-600 hover:bg-gray-50 hover:text-primary</c:if>">
								<div class="w-5 h-5 flex items-center justify-center mr-3">
									<i class="ri-file-settings-line"></i>
								</div> <span>관리 로그</span>
						</a></li>
					</ul>
				</nav>
				<div class="p-4 border-t border-gray-100">
					<div class="flex items-center">
						<div
							class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-2">
							<i class="ri-user-line text-gray-600"></i>
						</div>
						<div class="ml-0">
							<c:if test="${not empty currentAdmin}">
								<p class="text-sm font-medium">${fn:escapeXml(currentAdmin.admin_name)}</p>
								<p class="text-xs">${fn:escapeXml(currentAdmin.email)}</p>
           					 </c:if>
						</div>
					</div>
					<a href="<c:url value='/admin/logout'/>" id="admin_logout"
						class="mt-4 w-full flex items-center justify-center px-4 py-2 text-sm font-medium text-white bg-primary hover:bg-primary/90 rounded-button text-center">
						<div class="w-4 h-4 flex items-center justify-center mr-2">
							<i class="ri-logout-box-line"></i>
						</div> <span>로그아웃</span>
					</a>
				</div>
			</div>
		</aside>

		<!-- 메인 콘텐츠 -->
		<div class="flex-1 flex flex-col overflow-hidden">
			<!-- 헤더 -->
			<header class="bg-white shadow-sm z-10">
				<div class="flex items-center justify-between px-6 py-4">
					<div class="flex items-center">
						<button id="mobileMenuButton"
							class="md:hidden w-10 h-10 flex items-center justify-center text-gray-500 hover:text-gray-900">
							<i class="ri-menu-line ri-lg"></i>
						</button>
						<h1 class="ml-4 text-xl font-medium text-gray-800">${pageTitle}</h1>
						<%-- 각 페이지별 타이틀 --%>
					</div>
					<div class="flex items-center space-x-4">
						<%-- 알림, 사용자 드롭다운 등 --%>
						<div class="relative">
						<c:set var="notificationTitle" value="새로운 문의"/>
						<c:if test="${openInquiriesCountGlobal > 0}">
    					<c:set var="notificationTitle" value="새로운 문의 (${openInquiriesCountGlobal}건)"/>
						</c:if>
					<a href="<c:url value='/admin/chat-inquiries'/>?inquiryStatus=OPEN"
  						 title="${fn:escapeXml(notificationTitle)}"
   						class="w-10 h-10 flex items-center justify-center text-gray-500 hover:text-gray-900 rounded-full hover:bg-gray-100 transition-colors">
   						 <i class="ri-notification-3-line ri-lg"></i>
                    <c:if test="${openInquiriesCountGlobal > 0}">
                        <span class="absolute top-1 right-1 flex h-3 w-3">
                            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-3 w-3 bg-red-500">
                                <c:if test="${openInquiriesCountGlobal < 10}">
                                    <span class="absolute -top-1 -right-1 inline-flex 
                                    items-center justify-center px-1.5 py-0.5 text-xs font-bold 
                                    leading-none text-red-100 transform translate-x-1/2 -translate-y-1/2 bg-red-600 r
                                    ounded-full">${openInquiriesCountGlobal}</span>
                                </c:if>
                                <c:if test="${openInquiriesCountGlobal >= 10}">
                                    <span class="absolute -top-1 -right-1 inline-flex items-center justify-center px-1 py-0.5 
                                    text-xs font-bold leading-none text-red-100 transform translate-x-1/2 
                                    -translate-y-1/2 bg-red-600 rounded-full">9+</span>
                                </c:if>
                            </span>
                        </span>
                    </c:if>
                </a>
						</div>
						<div class="relative">
							<button
								class="flex items-center text-gray-700 hover:text-gray-900">
								<div
									class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
									<i class="ri-user-line text-gray-600"></i>
								</div>
								<span class="ml-2 text-sm font-medium hidden sm:block">${fn:escapeXml(currentAdmin.admin_name)}</span>
								<div class="w-5 h-5 flex items-center justify-center ml-1">
								</div>
							</button>
						</div>
					</div>
				</div>
			</header>

			<!-- 메인 콘텐츠 영역 (이 부분이 각 페이지별로 바뀜) -->
			<main class="flex-1 overflow-y-auto bg-gray-50 p-6">
				<jsp:include page="${contentPage}" />
			</main>
		</div>
	</div>

	<script>
	
	
        //메뉴 토글
        const mobileMenuButton = document.getElementById('mobileMenuButton');
        const sidebar = document.querySelector('aside');
        if (mobileMenuButton && sidebar) {
            mobileMenuButton.addEventListener('click', () => {
                sidebar.classList.toggle('hidden'); 
            });
        }
    </script>
</body>
</html>