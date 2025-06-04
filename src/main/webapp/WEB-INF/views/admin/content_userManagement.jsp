<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<div class="bg-white rounded shadow p-6">
	<div class="flex justify-between items-center mb-6">
		<h3 class="text-lg font-medium text-gray-700">사용자 목록</h3>
	</div>


	<c:if test="${not empty successMessage}">
		<div
			class="mb-4 p-3 bg-green-100 border border-green-400 text-green-700 rounded-lg text-sm">
			<i class="ri-check-line align-middle mr-1"></i> ${successMessage}
		</div>
	</c:if>

	<table id="userTable" class="display responsive nowrap w-full text-sm"
		style="width: 100%">
		<thead>
			<tr>
				<th class="px-4 py-2 text-left">사용자ID</th>
				<th class="px-4 py-2 text-left">로그인ID</th>
				<th class="px-4 py-2 text-left">이름</th>
				<th class="px-4 py-2 text-left">가입일</th>
				<th class="px-4 py-2 text-left">전화번호</th>
				<th class="px-4 py-2 text-left">로그인 방식</th>
				<th class="px-4 py-2 text-left">관리</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="user" items="${userList}">
				<tr>
					<td class="border px-4 py-2" style="background: white">${user.user_id}</td>
					<td class="border px-4 py-2" style="background: white">${user.login_id}</td>
					<td class="border px-4 py-2" style="background: white">${user.user_name}</td>
					<td class="border px-4 py-2" style="background: white"><fmt:formatDate
							value="${user.joined_at}" pattern="yyyy-MM-dd" /></td>
					<td class="border px-4 py-2" style="background: white">${user.phone_num}</td>
					<td class="border px-4 py-2" style="background: white">${user.login_provider}</td>
					<td class="border px-4 py-2" style="background: white"><a
						href="javascript:void(0);"
						class="text-blue-600 hover:text-blue-800 mr-2 edit-user-btn"
						<%-- 클래스 추가 --%>
       data-user-id="${user.user_id}"
						<%-- data 속성으로 ID 전달 --%>
       title="수정"> <i
							class="ri-pencil-line"></i>
					</a> <a
						href="javascript:void(0);"
						onclick="confirmDeleteUser( ${user.user_id}, '${user.user_name}');"
                   class="text-red-600 hover:text-red-800 mr-2"
						title="삭제"> <i class="ri-delete-bin-line"></i>
					</a></td>
				</tr>
			</c:forEach>
			<c:if test="${empty userList}">
				<tr>
					<td colspan="7" class="text-center py-4">등록된 사용자가 없습니다.</td>
				</tr>
			</c:if>
		</tbody>
	</table>
</div>

<!-- 사용자 정보 수정 모달 -->
<div id="editUserModal"
	class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
	<div
		class="relative top-20 mx-auto p-5 border w-full max-w-xl shadow-lg rounded-md bg-white">
		<!-- 모달 헤더 -->
		<div class="flex justify-between items-center pb-3 border-b">
			<p class="text-2xl font-bold text-gray-700">사용자 정보 수정</p>
			<div id="closeEditUserModal"
				class="cursor-pointer z-50 p-1 hover:bg-gray-200 rounded-full">
				<i class="ri-close-line ri-xl text-gray-500"></i>
			</div>
		</div>

		<!-- 모달 바디 (수정 폼) -->
		<div class="mt-5">
			<form id="editUserForm">
				<input type="hidden" id="editUserId" name="userId">

				<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
					<div>
						<label for="editLoginId"
							class="block text-sm font-medium text-gray-700">로그인 ID</label> <input
							type="text" name="loginId" id="editLoginId"
							readonly 
                               class="mt-1 block w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md shadow-sm sm:text-sm">
					</div>
					<div>
						<label for="editUserName"
							class="block text-sm font-medium text-gray-700">이름</label> <input
							type="text" name="userName" id="editUserName" required
							class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
					</div>
				</div>

				<div class="mb-4">
					<label for="editAddress"
						class="block text-sm font-medium text-gray-700">주소</label> <input
						type="text" name="address" id="editAddress"
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
				</div>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
					<div>
						<label for="editPhoneNum"
							class="block text-sm font-medium text-gray-700">전화번호</label> <input
							type="text" name="phoneNum" id="editPhoneNum"
							class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
					</div>
					<div>
						<label for="editBirthDate"
							class="block text-sm font-medium text-gray-700">생년월일</label> <input
							type="date" name="birthDate" id="editBirthDate"
							class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
					</div>
				</div>

				<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
					<div>
						<label for="editLoginProvider"
							class="block text-sm font-medium text-gray-700">로그인 방식</label> <select
							name="loginProvider" id="editLoginProvider"
							class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
							<option value="NORMAL">일반</option>
							<option value="KAKAO">카카오</option>
							<option value="GOOGLE">구글</option>
							<!-- 다른 방식 추가 가능 -->
						</select>
					</div>
					<div>
						<label for="editIsModified"
							class="block text-sm font-medium text-gray-700">수정 여부
							(테스트용)</label> <input type="text" name="isModified" id="editIsModified"
							class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
					</div>
				</div>


				<!-- 모달 푸터 (버튼) -->
				<div class="pt-4 border-t flex justify-end space-x-2">
					<button type="button" id="cancelEditUser"
						class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition duration-150">취소</button>
					<button type="submit"
						class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 transition duration-150">저장</button>
				</div>
			</form>
		</div>
	</div>
</div>

<script>

const Toast = Swal.mixin({
    toast: true,
    position: "top-end", // 화면 오른쪽 상단에 표시
    showConfirmButton: false, // '확인' 버튼 숨김
    timer: 3000, // 3초 후 자동으로 사라짐
    timerProgressBar: true, // 타이머 진행 바 표시
    didOpen: (toast) => {
        toast.onmouseenter = Swal.stopTimer; // 마우스 올리면 타이머 정지
        toast.onmouseleave = Swal.resumeTimer; // 마우스 벗어나면 타이머 다시 시작
    }
});

$(document).ready(function() {
    $('#userTable').DataTable({
        responsive: true,
        language: { 
            emptyTable: "데이터가 없습니다.",
            lengthMenu: "_MENU_ 개씩 보기",
            info: "현재 _START_ - _END_ / _TOTAL_건",
            infoEmpty: "데이터 없음",
            infoFiltered: "( _MAX_건의 데이터에서 필터링됨 )",
            search: "검색: ",
            zeroRecords: "일치하는 데이터가 없습니다.",
            loadingRecords: "로딩중...",
            processing: "잠시만 기다려 주세요...",
            paginate: {
                first: "처음",
                last: "마지막",
                next: "다음",
                previous: "이전"
            }
        }
    });
     
});

function confirmDeleteUser(userId, userName) {

    if (confirm("'" + userName + "' (사용자 ID: " + userId + ") 사용자를 정말 삭제하시겠습니까?\n관련 데이터가 함께 삭제될 수 있습니다.")) {

        window.location.href = '<c:url value="/admin/users/delete"/>?user_id=' + userId;

    } else {
        console.log("사용자 삭제 취소: " + userName);
    }
}

const editUserModal = document.getElementById('editUserModal');
const closeEditUserModalButton = document.getElementById('closeEditUserModal');
const cancelEditUserButton = document.getElementById('cancelEditUser');
const editUserForm = document.getElementById('editUserForm');

// "수정" 버튼 클릭 시 이벤트 처리 (이벤트 위임)
document.addEventListener('click', function(event) {
    if (event.target.closest('.edit-user-btn')) {
        event.preventDefault();
        const button = event.target.closest('.edit-user-btn');
        const userIdToEdit = button.dataset.userId;

        // AJAX를 사용하여 서버에서 특정 사용자 정보 가져오기
        fetch('<c:url value="/admin/users/api/detail"/>?user_id=' + userIdToEdit) // API 엔드포인트 예시
            .then(response => {
                if (!response.ok) {
                    throw new Error('사용자 정보를 가져오는데 실패했습니다.');
                }
                return response.json();
            })
            .then(userData => {
                if (userData) {
                    populateEditForm(userData);
                    editUserModal.classList.remove('hidden');
                } else {
                    alert('사용자 정보를 찾을 수 없습니다.');
                }
            })
            .catch(error => {
                console.error('Error fetching user data:', error);
                alert(error.message);
            });
    }
});

// 모달 폼에 데이터 채우는 함수
function populateEditForm(user) {
    document.getElementById('editUserId').value = user.user_Id;
    document.getElementById('editLoginId').value = user.login_id || '';
    document.getElementById('editUserName').value = user.user_name || '';
    document.getElementById('editAddress').value = user.address || '';
    document.getElementById('editPhoneNum').value = user.phone_num || '';
    document.getElementById('editBirthDate').value = user.birth_date || '';  
    document.getElementById('editIsModified').value = user.is_modified || '';
    document.getElementById('editLoginProvider').value = user.login_provider || '';
}

// 모달 "저장" 버튼 (폼 제출)
if (editUserForm) {
    editUserForm.addEventListener('submit', function(event) {
         event.preventDefault();
        const formData = new FormData(editUserForm);
        const updatedUserData = {};
        formData.forEach((value, key) => {
            updatedUserData[key] = value;
        });

        console.log('수정할 사용자 데이터 (From Modal):', updatedUserData);

        fetch('<c:url value="/admin/users/editAction"/>', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(updatedUserData)
        })
        .then(response => {
            if (!response.ok) {
                return response.json().then(err => { throw new Error(err.message || '서버 응답 오류') });
            }
            return response.json();
        })
        .then(data => {
            console.log('사용자 정보 수정 성공:', data);
            editUserModal.classList.add('hidden');
            Toast.fire({
                icon: "success", // 성공 아이콘
                title: "사용자 정보가 성공적으로 수정되었습니다." // 알림 메시지
            });
            setTimeout(() => {
            location.reload();
            },3100);
        })
        .catch(error => {
            console.error('사용자 정보 수정 실패:', error);
            Toast.fire({
                icon: "error",
                title: "사용자 정보 수정 중 오류가 발생했습니다: " + error.message
            });
        });
    });
}

if (closeEditUserModalButton) {
    closeEditUserModalButton.addEventListener('click', function() {
        editUserModal.classList.add('hidden');
    });
}

// 모달 "취소" 버튼
if (cancelEditUserButton) {
    cancelEditUserButton.addEventListener('click', function() {
        editUserModal.classList.add('hidden');
    });
}

// 모달 외부 클릭 시 닫기 (선택적)
if (editUserModal) {
    editUserModal.addEventListener('click', function(event) {
        if (event.target === editUserModal) { // 모달 배경 클릭 시
            editUserModal.classList.add('hidden');
        }
    });
}
</script>