<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>로그인 - Tripin</title>
<script src="https://cdn.tailwindcss.com/3.4.16"></script>
<script>tailwind.config={theme:{extend:{colors:{primary:'#4F46E5',secondary:'#10B981'},borderRadius:{'none':'0px','sm':'4px',DEFAULT:'8px','md':'12px','lg':'16px','xl':'20px','2xl':'24px','3xl':'32px','full':'9999px','button':'8px'}}}}</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link
	href="https://fonts.googleapis.com/css2?family=Pacifico&display=swap"
	rel="stylesheet">
<link
	href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap"
	rel="stylesheet">
<link rel="icon" href="resources/img/favicon.ico">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/remixicon/4.6.0/remixicon.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css">
<style>
:where([class^="ri-"])::before {
	content: "\f3c2";
}

body {
	font-family: 'Noto Sans KR', sans-serif;
}

.hero-section {
	background-image:
		url('https://readdy.ai/api/search-image?query=Beautiful%20travel%20destination%20landscape%20with%20mountains%2C%20lakes%2C%20and%20traditional%20Korean%20architecture.%20The%20left%20side%20has%20a%20soft%20gradient%20to%20white%20for%20text%20overlay.%20Modern%2C%20clean%20aesthetic%20with%20natural%20lighting%20and%20vibrant%20colors.%20Perfect%20for%20travel%20website%20hero%20image%20with%20space%20for%20text%20on%20the%20left%20side.&width=1600&height=800&seq=1&orientation=landscape');
	background-size: cover;
	background-position: center;
}

.search-input:focus {
	outline: none;
}

.theme-card:hover .theme-overlay {
	opacity: 1;
}

.custom-checkbox {
	position: relative;
	padding-left: 28px;
	cursor: pointer;
}

.custom-checkbox input {
	position: absolute;
	opacity: 0;
	cursor: pointer;
}

.checkmark {
	position: absolute;
	top: 0;
	left: 0;
	height: 20px;
	width: 20px;
	border: 2px solid #ccc;
	border-radius: 4px;
}

.custom-checkbox:hover input ~ .checkmark {
	border-color: #aaa;
}

.custom-checkbox input:checked ~ .checkmark {
	background-color: #4F46E5;
	border-color: #4F46E5;
}

.checkmark:after {
	content: "";
	position: absolute;
	display: none;
}

.custom-checkbox input:checked ~ .checkmark:after {
	display: block;
}

.custom-checkbox .checkmark:after {
	left: 6px;
	top: 2px;
	width: 5px;
	height: 10px;
	border: solid white;
	border-width: 0 2px 2px 0;
	transform: rotate(45deg);
}

.custom-select {
	position: relative;
}

.custom-select-options {
	display: none;
	position: absolute;
	top: 100%;
	left: 0;
	right: 0;
	z-index: 10;
}

.custom-select.active .custom-select-options {
	display: block;
}
</style>
</head>
<body class="bg-gray-50 min-h-screen">
	<header class="bg-white shadow-sm">
		<div class="h-16 flex items-center justify-start px-4">
			<a href="#" class="flex items-center"> <img
				src="<c:url value='/resources/img/logo.png'/>" alt="TripIn Logo"
				class="h-8 w-auto mr-2" />
			</a>
		</div>
	</header>

	<main class="container mx-auto px-4 py-16">
		<div class="max-w-md mx-auto">
			<div class="bg-white rounded-xl shadow-md p-8">
				<div class="text-center mb-8">
					<h1 class="text-2xl font-bold text-gray-900 mb-2">Tripin에 오신
						것을 환영합니다</h1>
					<p class="text-gray-600">로그인하고 트래비와 대화해 보세요</p>
				</div>

				<form action="<c:url value='/loginAction'/>" method="POST"
					class="space-y-4">
					<div>
						<label class="block text-sm font-medium text-gray-700 mb-1">이메일</label>
						<input type="email" name="email" required
							class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary"
							placeholder="이메일 주소를 입력하세요">
					</div>

					<div>
						<label class="block text-sm font-medium text-gray-700 mb-1">비밀번호</label>
						<div class="relative">
							<input type="password" name="password" required
								class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary"
								placeholder="비밀번호를 입력하세요">
							<button type="button"
								class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
								<div class="w-5 h-5 flex items-center justify-center">
									<i class="ri-eye-off-line"></i>
								</div>
							</button>
						</div>
					</div>

					<div class="flex items-center justify-between">
						<label class="custom-checkbox text-sm text-gray-700"> <input
							type="checkbox" name="remember"> <span class="checkmark"></span>
							로그인 상태 유지
						</label> <a href="#" class="text-sm text-primary hover:text-primary/80">비밀번호를
							잊으셨나요?</a>
					</div>

					<button type="submit"
						class="w-full bg-primary text-white py-2 !rounded-button font-medium">로그인</button>
				</form>

				<div class="relative my-8">
					<div class="absolute inset-0 flex items-center">
						<div class="w-full border-t border-gray-200"></div>
					</div>
					<div class="relative flex justify-center text-sm">
						<span class="px-4 bg-white text-gray-500">또는</span>
					</div>
				</div>

				<div class="space-y-4">
					<a href="javascript:loginWithKakao();" style="background: #FFE300"
						class="flex items-center justify-center w-[280px] h-[50px] mx-auto
              border border-gray-300 rounded-md shadow-sm
              bg-white text-gray-700 hover:bg-gray-50
              transition duration-150 ease-in-out">
						<i class="ri-kakao-talk-fill text-lg mr-2"></i> <span>카카오
							로그인</span>
					</a>

					<div class="flex justify-center">
						<div id="g_id_onload"
							data-client_id="240873906518-2qdjidtfg7epvjuq7ejsgppcutmq99bl.apps.googleusercontent.com"
							data-login_uri="http://localhost:8080/tripin2/auth/google/callback"
							data-auto_prompt="false"></div>
						<div class="g_id_signin" data-type="standard"
							data-shape="rectangular"
							
     data-theme="outline"
							
     data-text="continue_with"
							
     data-size="large"
							
     data-logo_alignment="left"
							data-width="280">
							
						</div>
					</div>

					<a href="<c:url value='/admin/login'/>"
						class="flex items-center justify-center w-[280px] h-[50px] mx-auto
              border border-gray-300 rounded-md shadow-sm
              bg-white text-gray-700 hover:bg-gray-50
              transition duration-150 ease-in-out">
						<i
						class="ri-user-settings-line text-lg mr-2"></i> <span>관리자
							로그인 연결</span>
					</a>
				</div>

				<p class="mt-8 text-center text-sm text-gray-600">
					아직 계정이 없으신가요? <a href="javascript:void(0);"
						id="openRegisterModalLink"
						class="text-primary hover:text-primary/80 font-medium">회원가입</a>
				</p>
			</div>
		</div>
	</main>

	<footer class="mt-auto py-8">
		<div class="container mx-auto px-4">
			<div class="text-center text-sm text-gray-500">
				<p>© 2025 Tripin. All rights reserved.</p>
				<div class="flex justify-center gap-4 mt-2">
					<a href="#" class="hover:text-gray-700">이용약관</a> <a href="#"
						class="hover:text-gray-700">개인정보처리방침</a> <a href="#"
						class="hover:text-gray-700">고객센터</a>
				</div>
			</div>
		</div>
	</footer>



	<div id="registerModal"
		class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
		<div
			class="relative top-10 mx-auto p-5 border w-full max-w-md shadow-lg rounded-md bg-white mb-10">
			<!-- 모달 헤더 -->
			<div class="flex justify-between items-center pb-3 border-b mb-5">
				<p class="text-2xl font-bold text-gray-900">Tripin 회원가입</p>
				<button id="closeRegisterModal" type="button"
					class="p-1 rounded-full hover:bg-gray-200">
					<i class="ri-close-line ri-xl text-gray-500"></i>
				</button>
			</div>

			<!-- 모달 바디 (회원가입 폼) -->
			<form id="registerForm" class="space-y-4">
				<div>
					<label for="registerUserName"
						class="block text-sm font-medium text-gray-700 mb-1">닉네임
						(이름)</label> <input type="text" name="userName" id="registerUserName"
						required
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary"
						placeholder="사용하실 닉네임 또는 이름을 입력하세요">
					<p id="userNameError" class="text-xs text-red-500 mt-1 hidden"></p>
				</div>
				<div>
					<label for="registerEmail"
						class="block text-sm font-medium text-gray-700 mb-1">로그인
						이메일</label> <input type="email" name="login_id" id="registerEmail"
						required 
                       class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary"
						placeholder="로그인에 사용할 이메일 주소를 입력하세요">
					<p id="emailError" class="text-xs text-red-500 mt-1 hidden"></p>
					
				</div>
				<div>
					<label for="registerPassword"
						class="block text-sm font-medium text-gray-700 mb-1">비밀번호</label>
					<input type="password" name="password" id="registerPassword"
						required
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary"
						placeholder="비밀번호 (8자 이상)">
				</div>
				<div>
					<label for="registerPasswordConfirm"
						class="block text-sm font-medium text-gray-700 mb-1">비밀번호
						확인</label> <input type="password" name="passwordConfirm"
						id="registerPasswordConfirm" required
						class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary/20 focus:border-primary"
						placeholder="비밀번호를 다시 한번 입력하세요">
					<p id="passwordError" class="text-xs text-red-500 mt-1 hidden"></p>
					<%-- 비밀번호 불일치 오류 메시지 --%>
				</div>

				<p id="registerGeneralError"
					class="text-sm text-red-600 text-center hidden"></p>
				<%-- 일반 오류 메시지 --%>

				<button type="submit" id="submitRegisterForm"
					class="w-full bg-primary text-white py-2 !rounded-button font-medium hover:bg-primary/90 transition duration-150">
					회원가입</button>
			</form>
		</div>
	</div>

	<script src="https://accounts.google.com/gsi/client" async defer></script>
	<script src="https://t1.kakaocdn.net/kakao_js_sdk/2.7.1/kakao.min.js"
		integrity="sha384-kDljxUXHaJ9xAb2AzRd59KxjrFjzHa5TAoFQ6GbYTCAG0bjM55XohjjDT7tDDC01"
		crossorigin="anonymous"></script>
	<script>
    // Kakao SDK 초기화 (발급받은 JavaScript 키 사용)
    if (!Kakao.isInitialized()) { // 중복 초기화 방지
        Kakao.init('d493f008583205194ab7f9d9dd1db8f6'); // 여기에 실제 JavaScript 키 입력!
        console.log("Kakao SDK Initialized:", Kakao.isInitialized());
    }

    function loginWithKakao() {
        Kakao.Auth.authorize({
            redirectUri: 'http://localhost:8080/tripin2/auth/kakao/callback', // 카카오 개발자에 등록한 Redirect URI와 정확히 일치!
        });
    }
</script>


	<script>

document.addEventListener('DOMContentLoaded', function() {
    const Toast = Swal.mixin({
        toast: true,
        position: "top-end",
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.onmouseenter = Swal.stopTimer;
            toast.onmouseleave = Swal.resumeTimer;
        }
    });



    // --- 회원가입 모달 관련 요소 가져오기 ---
    const registerModal = document.getElementById('registerModal');
    const openRegisterModalLink = document.getElementById('openRegisterModalLink');
    const closeRegisterModalButton = document.getElementById('closeRegisterModal');
    const registerForm = document.getElementById('registerForm');
    const submitRegisterFormButton = document.getElementById('submitRegisterForm');

    // 오류 메시지 표시용 p 태그 ID들
    const userNameErrorEl = document.getElementById('userNameError');
    const emailErrorEl = document.getElementById('emailError');
    const passwordErrorEl = document.getElementById('passwordError');
    const registerGeneralErrorEl = document.getElementById('registerGeneralError');

    // "회원가입" 링크 클릭 시 모달 열기
    if (openRegisterModalLink && registerModal) {
        openRegisterModalLink.addEventListener('click', function(event) {
            event.preventDefault();
            registerModal.classList.remove('hidden');
            clearRegisterFormErrors(); // 모달 열 때 이전 오류 초기화
            document.getElementById('registerUserName').focus();
        });
    }

    // 모달 닫기 버튼 (X 아이콘)
    if (closeRegisterModalButton && registerModal) {
        closeRegisterModalButton.addEventListener('click', function() {
            registerModal.classList.add('hidden');
            clearRegisterFormErrors();
        });
    }

    // 모달 외부 클릭 시 닫기
    if (registerModal) {
        registerModal.addEventListener('click', function(event) {
            if (event.target === registerModal) {
                registerModal.classList.add('hidden');
                clearRegisterFormErrors();
            }
        });
    }

    // 회원가입 폼 제출 시
    if (registerForm && submitRegisterFormButton) {
        registerForm.addEventListener('submit', function(event) {
            event.preventDefault();
            clearRegisterFormErrors();

            const userName = document.getElementById('registerUserName').value.trim();
            const loginId = document.getElementById('registerEmail').value.trim();
            const password = document.getElementById('registerPassword').value;
            const passwordConfirm = document.getElementById('registerPasswordConfirm').value;

            // --- 클라이언트 사이드 유효성 검사 ---
            let isValid = true;
            if (!userName) {
                showFieldError('userNameError', '닉네임(이름)을 입력해주세요.');
                isValid = false;
            }
            if (!loginId) {
                showFieldError('emailError', '이메일을 입력해주세요.');
                isValid = false;
            } else if (!isValidEmail(loginId)) {
                showFieldError('emailError', '올바른 이메일 형식이 아닙니다.');
                isValid = false;
            }
            if (!password) {
                showFieldError('passwordError', '비밀번호를 입력해주세요.');
                isValid = false;
            } else if (password.length < 8) {
                showFieldError('passwordError', '비밀번호는 8자 이상이어야 합니다.');
                isValid = false;
            }
            if (!passwordConfirm) {
                showFieldError('passwordError', '비밀번호 확인을 입력해주세요.');
                isValid = false;
            } else if (password !== passwordConfirm) {
                showFieldError('passwordError', '비밀번호가 일치하지 않습니다.');
                isValid = false;
            }

            if (!isValid) {
                return;
            }
            // --- 유효성 검사 끝 ---

            submitRegisterFormButton.disabled = true;
            submitRegisterFormButton.textContent = '가입 처리 중...';

            const userData = {
                user_name: userName,
                login_id: loginId,
                password: password
            };

            console.log("Sending to server:", JSON.stringify(userData));

            fetch('<c:url value="/api/users/register"/>', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
            
                },
                body: JSON.stringify(userData)
            })
            .then(response => {
                const contentType = response.headers.get("content-type");
                if (response.ok) { 
                    if (contentType && contentType.indexOf("application/json") !== -1) {
                        return response.json(); 
                    } else {
                        // 성공했지만 JSON이 아닌 경우 (예상치 못한 상황)
                        console.warn("Successful response was not JSON. Content-Type:", contentType);
                        return { success: true, message: "회원가입 요청이 접수되었습니다." }; 
                    }
                } else { // HTTP 에러 상태 코드 (4xx, 5xx 등)
                    if (contentType && contentType.indexOf("application/json") !== -1) {
                        return response.json().then(errData => {
                            throw { success: false, status: response.status, data: errData };
                        });
                    } else {
                       
                        return response.text().then(text => {
                            console.error("Non-JSON server error response text:", text);
                            throw { success: false, status: response.status, data: { message: "서버 오류가 발생했습니다. (응답 유형 오류)" } };
                        });
                    }
                }
            })
            .then(data => { 
                if (data.success) {
                    registerModal.classList.add('hidden');
                    registerForm.reset();
                    Toast.fire({
                        icon: 'success',
                        title: data.message || '회원가입이 완료되었습니다! 로그인해주세요.'
                    });
                    setTimeout(() => { location.reload(); }, 1500); // Toast 볼 시간 후 페이지 새로고침
                } else {
             
                    handleRegistrationError(data);
                }
            })
            .catch(error => { 
                console.error('회원가입 최종 처리 오류:', error);
                handleRegistrationError(error.data || { message: error.message || '알 수 없는 오류가 발생했습니다.' });
            })
            .finally(() => {
                submitRegisterFormButton.disabled = false;
                submitRegisterFormButton.textContent = '회원가입';
            });
        });
    }

    // 간단한 이메일 형식 유효성 검사 함수
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    // 오류 메시지 표시 함수
    function showFieldError(elementId, message) {
        const errorElement = document.getElementById(elementId);
        if (errorElement) {
            errorElement.textContent = message;
            errorElement.classList.remove('hidden');
        } else {
            console.warn("Error element not found for ID:", elementId, "Message:", message);
            const generalErrorEl = document.getElementById('registerGeneralError');
            if (generalErrorEl && generalErrorEl.classList.contains('hidden')) { 
                generalErrorEl.textContent = message; 
                generalErrorEl.classList.remove('hidden');
            }
        }
    }

    // 폼 오류 메시지 초기화 함수
    function clearRegisterFormErrors() {
        if (userNameErrorEl) { userNameErrorEl.classList.add('hidden'); userNameErrorEl.textContent = ''; }
        if (emailErrorEl) { emailErrorEl.classList.add('hidden'); emailErrorEl.textContent = ''; }
        if (passwordErrorEl) { passwordErrorEl.classList.add('hidden'); passwordErrorEl.textContent = ''; }
        if (registerGeneralErrorEl) { registerGeneralErrorEl.classList.add('hidden'); registerGeneralErrorEl.textContent = ''; }
    }

    // 회원가입 오류 처리 통합 함수
    function handleRegistrationError(errorData) {
        if (errorData && errorData.errors) {
            for (const fieldKey in errorData.errors) {                
                let errorElementId = '';
                if (fieldKey === 'userName') errorElementId = 'userNameError'; 
                else if (fieldKey === 'loginId') errorElementId = 'emailError';
                else if (fieldKey === 'password') errorElementId = 'passwordError';
              

                if (errorElementId) {
                    showFieldError(errorElementId, errorData.errors[fieldKey]);
                } else {
                    const generalMsg = document.getElementById('registerGeneralError');
                    if(generalMsg) {
                        generalMsg.textContent += (generalMsg.textContent ? '\n' : '') + errorData.errors[fieldKey];
                        generalMsg.classList.remove('hidden');
                    }
                }
            }
        } else if (errorData && errorData.message) {
            showFieldError('registerGeneralError', errorData.message);
        } else {
            showFieldError('registerGeneralError', '알 수 없는 오류로 회원가입에 실패했습니다.');
        }
    }

}); // DOMContentLoaded 끝
</script>
</body>
</html>
