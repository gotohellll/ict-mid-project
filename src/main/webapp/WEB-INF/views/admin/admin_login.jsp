<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tripin 관리자 로그인</title>
    <script src="https://cdn.tailwindcss.com/3.4.16"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
    <link rel="icon" href="../resources/img/favicon.ico">
    <style>
        body { font-family: 'Noto Sans KR', sans-serif; }
    </style>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">
    <div class="bg-white p-8 md:p-12 rounded-xl shadow-2xl w-full max-w-md">
<div class="text-center mb-8">
    <a href="<c:url value='/'/>"> 
        <img src="<c:url value='../resources/img/logo.png'/>"  alt="TripIn Logo"
             class="mx-auto h-12 w-auto mb-2" />
    </a>
    <p class="text-gray-600 text-lg">관리자 로그인</p>
</div>

        <form id="loginForm" action="<c:url value='/admin/loginAction'/>" method="POST">
            <div class="mb-6">
                <label for="admin_id" class="block text-sm font-medium text-gray-700 mb-1">아이디</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i class="ri-user-line text-gray-400"></i>
                    </div>
                    <input type="text" id="admin_id" name="admin_id"
                           class="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary transition duration-150"
                           placeholder="관리자 아이디를 입력하세요" required value="${param.admin_id}"> <%-- 로그인 실패 시 ID 유지 --%>
                </div>
            </div>

            <div class="mb-6">
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">비밀번호</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i class="ri-lock-password-line text-gray-400"></i>
                    </div>
                    <input type="password" id="password" name="password"
                           class="w-full pl-10 pr-3 py-2.5 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary transition duration-150"
                           placeholder="비밀번호를 입력하세요" required>
                </div>
            </div>

            <%-- 로그인 실패 메시지 --%>
            <c:if test="${not empty loginError}">
                <div class="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg text-sm">
                    <i class="ri-error-warning-line align-middle mr-1"></i>
                    ${loginError}
                </div>
            </c:if>
            <%-- 로그아웃 성공 메시지 --%>
            <c:if test="${param.logout == 'true'}">
                 <div class="mb-4 p-3 bg-green-100 border border-green-400 text-green-700 rounded-lg text-sm">
                    <i class="ri-check-line align-middle mr-1"></i>
                    성공적으로 로그아웃되었습니다.
                </div>
            </c:if>

            <div>
                <button type="submit" style="color:white; background:#4F46E5;"
                        class="w-full flex justify-center py-3 px-4 border border-transparent rounded-button shadow-sm text-sm font-medium text-white bg-primary hover:bg-primary/90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary transition duration-150">
                    로그인
                </button>
            </div>
        </form>
    </div>
    <script>
        // 폼 유효성 검사
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', function(event) {
                const usernameInput = document.getElementById('username');
                const passwordInput = document.getElementById('password');
                let isValid = true;

                // 아이디 유효성 검사 (예: 비어있는지)
                if (usernameInput.value.trim() === '') {
                    alert('아이디를 입력해주세요.');
                    usernameInput.focus();
                    isValid = false;
                    event.preventDefault(); // 폼 제출 막기
                    return;
                }

                // 비밀번호 유효성 검사 (예: 비어있는지)
                if (passwordInput.value.trim() === '') {
                    alert('비밀번호를 입력해주세요.');
                    passwordInput.focus();
                    isValid = false;
                    event.preventDefault();
                    return;
                }

                // 모든 유효성 검사 통과 시 폼 제출 진행
                if(isValid) {
                    console.log('폼 제출 시도');
                }
            });
        }
    </script>
</body>
</html>