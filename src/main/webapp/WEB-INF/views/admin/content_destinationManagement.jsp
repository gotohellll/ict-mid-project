<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="bg-white rounded shadow p-6">
	<div class="flex justify-between items-center mb-6">
		<h3 class="text-lg font-medium text-gray-700">여행지 목록</h3>
		<form action="fetch" method="get">
      	<button  class="bg-primary hover:bg-primary/90 text-white font-medium py-2 px-4 rounded-button flex items-center" 
      	type="submit"><i class="ri-add-line mr-2"></i>최신 여행정보 불러오기</button>
      </form>
	</div>

	<table id="destinationTable"
		class="display responsive nowrap w-full text-sm" style="width: 100%">
		<thead>
			<tr>
				<th class="px-4 py-2 text-left">ID</th>
				<th class="px-4 py-2 text-left">여행지명</th>
				<th class="px-4 py-2 text-left">코드</th>
				<th class="px-4 py-2 text-left">주소</th>
				<th class="px-4 py-2 text-left">연락처</th>
				<th class="px-4 py-2 text-left">관리</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach var="dest" items="${destinationList}">
				<tr>
					<td class="border px-4 py-2" style="background: white">${dest.dest_id}</td>
					<td class="border px-4 py-2" style="background: white">${dest.dest_name}</td>
					<td class="border px-4 py-2" style="background: white">${dest.dest_type}</td>
					<td class="border px-4 py-2" style="background: white">${dest.full_address}</td>
					<td class="border px-4 py-2" style="background: white">${dest.contact_num}</td>
					<td class="border px-4 py-2" style="background: white"><a
						href="javascript:void(0);"
						class="text-blue-600 hover:text-blue-800 mr-2 edit-dest-btn"

       data-dest-id="${dest.dest_id}"
       title="수정"> <i
							class="ri-pencil-line"></i>
					</a> <a
						href="<c:url value='/admin/destinations/delete?dest_id=${dest.dest_id}'/>"
						onclick="return confirm('정말 이 여행지를 삭제하시겠습니까?');"
						class="text-red-600 hover:text-red-800" title="삭제"><i
							class="ri-delete-bin-line"></i></a></td>
				</tr>
			</c:forEach>
			<c:if test="${empty destinationList}">
				<tr>
					<td colspan="6" class="text-center py-4">등록된 여행지가 없습니다.</td>
				</tr>
			</c:if>
		</tbody>
	</table>
</div>






<div id="editDestModal"
	class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
	<div
		class="relative top-10 mx-auto p-5 border w-full max-w-3xl shadow-lg rounded-md bg-white mb-10">
		<div class="flex justify-between items-center pb-3 border-b">
			<p class="text-2xl font-bold text-gray-700">여행지 정보 수정/상세</p>
			<div id="closeEditDestModal"
				class="cursor-pointer z-50 p-1 hover:bg-gray-200 rounded-full">
				<i class="ri-close-line ri-xl text-gray-500"></i>
			</div>
		</div>
		<div class="mt-5 max-h-[70vh] overflow-y-auto pr-2">
			<form id="editDestForm" enctype="multipart/form-data">
				<input type="hidden" id="editDestId" name="dest_id">

<div class="mb-4">
    <label for="detailDestIdInput" class="block text-sm font-medium text-gray-700">여행지 ID</label>
    <input type="text" id="detailDestIdInput" name="destIdToDisplay" readonly <%-- readonly 추가 --%>
           class="mt-1 block w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md shadow-sm sm:text-sm text-gray-700 cursor-not-allowed"> <%-- 스타일 추가 --%>
</div>
				<div class="mb-4">
					<label class="block text-sm font-medium text-gray-700">여행지
						이름</label> <input type="text" name="dest_name" id="editDestName" readonly
						class="mt-1 block w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md shadow-sm sm:text-sm">
				</div>

  <div class="mb-4">
      <label for="editDestType" class="block text-sm font-medium text-gray-700">코드</label>
<input type="text" name="dest_type" id="editDestType" value="${dest.dest_type}" readonly
						class="mt-1 block w-full px-3 py-2 bg-gray-100 border border-gray-300 rounded-md shadow-sm sm:text-sm">
  </div>

				<div class="mb-4">
					<label for="editFullAddress"
						class="block text-sm font-medium text-gray-700">주소</label>
					<input type="text" name="full_address" id="editFullAddress"
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary sm:text-sm">
				</div>
				<div class="mb-4">
					<label for="editContactNum"
						class="block text-sm font-medium text-gray-700">연락처</label> <input type="text" name="contact_num" id="editContactNum"
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary sm:text-sm">
				</div>
				  <hr class="my-6">
                <h4 class="text-lg font-semibold text-gray-800 mb-3">여행지 사진 관리</h4>

                <!-- 기존 대표 이미지 표시 및 변경 -->
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">대표 이미지</label>
                    <div id="currentReprImageContainer" class="mb-2">
                    </div>
                    <input type="file" name="newReprImageFile" id="editNewReprImageFile" accept="image/*"
                           class="block w-full text-sm text-gray-500 file:mr-4 file:py-1.5 file:px-3 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary/10 file:text-primary hover:file:bg-primary/20">
                    <p class="text-xs text-gray-500 mt-1">새로운 대표 이미지를 선택하면 기존 이미지를 대체합니다.</p>
                    <input type="hidden" name="existingReprImgUrl" id="existingReprImgUrl"> 
                </div>

                <!-- 기존 추가 이미지 표시 및 관리 (선택적) -->
                <div class="mb-6">
                    <label class="block text-sm font-medium text-gray-700 mb-1">추가 이미지</label>
                    <div id="currentAdditionalImagesContainer" class="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2 mb-2">
                       
                    </div>
                    <input type="file" name="newAdditionalImageFiles" id="editNewAdditionalImageFiles" accept="image/*" multiple
                           class="block w-full text-sm text-gray-500 file:mr-4 file:py-1.5 file:px-3 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-primary/10 file:text-primary hover:file:bg-primary/20">
                    <p class="text-xs text-gray-500 mt-1">새로운 추가 이미지를 선택하세요.</p>
                    <div id="newAdditionalImagePreviewContainer" class="mt-2 grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2">
                        
                    </div>
                    <input type="hidden" name="existingAdditionalImgUrls" id="existingAdditionalImgUrls"> 
                </div>
				<div class="mb-4">
					<label for="editOperHours"
						class="block text-sm font-medium text-gray-700">운영시간</label> <input type="text" name="oper_hours" id="editOperHours"
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary sm:text-sm">
				</div>
				<div class="mb-4">
					<label for="editFeeInfo"
						class="block text-sm font-medium text-gray-700">입장료</label> <input type="text" name="fee_info" id="editFeeInfo"
						class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-primary focus:border-primary sm:text-sm">
				</div>



				<div class="pt-4 border-t flex justify-end space-x-2">
					<button type="button" id="cancelEditDest"
						class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300">취소</button>
					<button type="submit"
						class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90">저장</button>
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
    $('#destinationTable').DataTable({
        responsive: true,
        language: { emptyTable: "데이터가 없습니다.",
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
                previous: "이전" }
        }
    });
});

const editDestModal = document.getElementById('editDestModal');
const closeEditDestModalButton = document.getElementById('closeEditDestModal');
const cancelEditDestButton = document.getElementById('cancelEditDest');
const editDestForm = document.getElementById('editDestForm');
const currentReprImageContainer = document.getElementById('currentReprImageContainer');
const existingReprImgUrlInput = document.getElementById('existingReprImgUrl');
const editNewReprImageFileInput = document.getElementById('editNewReprImageFile');

const currentAdditionalImagesContainer = document.getElementById('currentAdditionalImagesContainer');
const existingAdditionalImgUrlsInput = document.getElementById('existingAdditionalImgUrls');
const editNewAdditionalImageFilesInput = document.getElementById('editNewAdditionalImageFiles');
const newAdditionalImagePreviewContainer = document.getElementById('newAdditionalImagePreviewContainer');
let existingAdditionalPathsArray = [];


// "수정" 버튼 클릭 시 이벤트 처리
document.addEventListener('click', function(event) {
    if (event.target.closest('.edit-dest-btn')) {
        event.preventDefault();
        const button = event.target.closest('.edit-dest-btn');
        const destId = button.dataset.destId;

        fetch('<c:url value="/admin/destinations/api/detail"/>?dest_id=' + destId)
            .then(response => {
                if (!response.ok) throw new Error('여행지 정보를 가져오는데 실패했습니다.');
                return response.json();
            })
            .then(destinationData => {
                if (destinationData) {
                    populateEditDestForm(destinationData);
                    editDestModal.classList.remove('hidden');
                } else {
                    alert('여행지 정보를 찾을 수 없습니다.');
                }
            })
            .catch(error => {
                console.error('Error fetching destination data:', error);
                alert(error.message);
            });
    }
});

function populateEditDestForm(dest) {
	document.getElementById('editDestId').value = dest.dest_id;
	document.getElementById('detailDestIdInput').value = dest.dest_id;
    document.getElementById('editDestName').value = dest.dest_name || '';
    document.getElementById('editDestType').value = dest.dest_type || '';
    document.getElementById('editFullAddress').value = dest.full_address || '';
    document.getElementById('editContactNum').value = dest.contact_num || '';
    document.getElementById('editOperHours').value = dest.oper_hours || '';
    document.getElementById('editFeeInfo').value = dest.fee_info || '';

    currentReprImageContainer.innerHTML = ''; // 컨테이너 초기화
    const imageUrlFromDB = dest.repr_img_url; 


    if (imageUrlFromDB && typeof imageUrlFromDB === 'string' && imageUrlFromDB.trim() !== '' && imageUrlFromDB.trim().toLowerCase() !== 'null') {
        if (currentReprImageContainer) {

            const imgTag = document.createElement('img');
            imgTag.src = imageUrlFromDB;
            imgTag.alt = "대표 이미지";
            imgTag.className = "max-h-40 rounded-md border mb-1 object-contain";

            const pTag = document.createElement('p');
            pTag.className = "text-xs text-gray-500";
            pTag.textContent = "기존 대표 이미지. 새 파일을 선택하면 변경됩니다.";

            currentReprImageContainer.innerHTML = ''; 
            currentReprImageContainer.appendChild(imgTag);
            currentReprImageContainer.appendChild(pTag);

            console.log("IMG tag created with src:", imgTag.src); 
        }
    }else {
        // 대표 이미지가 없는 경우
        currentReprImageContainer.innerHTML = `
            <div class="w-full h-40 bg-gray-200 animate-pulse flex items-center justify-center rounded-md border mb-1">
                <i class="ri-image-line text-4xl text-gray-400"></i>
                <p class="ml-2 text-sm text-gray-500">대표 이미지가 없습니다.</p>
            </div>`;
    }
    editNewReprImageFileInput.value = '';// 파일 선택 초기화

    // 추가 이미지 표시 및 관리용 배열 초기화
    currentAdditionalImagesContainer.innerHTML = '';
    newAdditionalImagePreviewContainer.innerHTML = '';
    editNewAdditionalImageFilesInput.value = '';
    existingAdditionalPathsArray = []; 

    if (dest.additional_img_urls && typeof dest.additional_img_urls === 'string' && dest.additional_img_urls.trim() !== '') {
        existingAdditionalPathsArray = dest.additional_img_urls.split(',').map(p => p.trim()).filter(p => p);
        renderExistingAdditionalImages();
    } else {
         currentAdditionalImagesContainer.innerHTML = '<p class="text-sm text-gray-500 col-span-full">추가 이미지가 없습니다.</p>';
    }
    existingAdditionalImgUrlsInput.value = existingAdditionalPathsArray.join(','); // 현재 유지할 이미지 경로 저장
}
//기존 추가 이미지 렌더링 및 삭제 버튼 기능
function renderExistingAdditionalImages() {
    currentAdditionalImagesContainer.innerHTML = ''; // 초기화
    existingAdditionalPathsArray.forEach((path, index) => {
        const imgDiv = document.createElement('div'); 
        imgDiv.className = 'relative w-24 h-24 group';
        imgDiv.innerHTML = `
            <img src="${contextPath}${path}" alt="추가 이미지 ${index + 1}" class="w-full h-full object-cover rounded-md border">
            <button type="button"
                    data-path-to-delete="${path}"
                    class="absolute top-1 right-1 bg-red-500 text-white w-5 h-5 rounded-full text-xs opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center leading-none"
                    title="이 이미지 삭제">×</button>
        `;
        currentAdditionalImagesContainer.appendChild(imgDiv);
    });
}

// 기존 추가 이미지 삭제 버튼 클릭 이벤트 (이벤트 위임)
if (currentAdditionalImagesContainer) {
    currentAdditionalImagesContainer.addEventListener('click', function(event) {
        if (event.target.closest('button[data-path-to-delete]')) {
            const button = event.target.closest('button[data-path-to-delete]');
            const pathToDelete = button.dataset.pathToDelete;
            if (confirm(`'${pathToDelete.substring(pathToDelete.lastIndexOf('/') + 1)}' 이미지를 삭제하시겠습니까? 저장 시 반영됩니다.`)) {
                existingAdditionalPathsArray = existingAdditionalPathsArray.filter(p => p !== pathToDelete);
                renderExistingAdditionalImages(); // 목록 다시 그리기
                existingAdditionalImgUrlsInput.value = existingAdditionalPathsArray.join(',');
            }
        }
    });
}


// 새로 선택한 추가 이미지 미리보기
if (editNewAdditionalImageFilesInput && newAdditionalImagePreviewContainer) {
    editNewAdditionalImageFilesInput.addEventListener('change', function() {
        newAdditionalImagePreviewContainer.innerHTML = ''; // 이전 미리보기 초기화
        const files = Array.from(this.files);
        if (files.length + existingAdditionalPathsArray.length > 5) { //전체 이미지 5장 제한
            alert("대표 이미지를 포함하여 전체 이미지는 최대 5장까지 업로드할 수 있습니다. (기존 이미지 " + existingAdditionalPathsArray.length + "장)");
            this.value = ""; // 파일 선택 초기화
            return;
        }
        files.forEach(file => {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.createElement('img');
                img.src = e.target.result;
                img.className = "w-24 h-24 object-cover rounded border";
                newAdditionalImagePreviewContainer.appendChild(img);
            };
            reader.readAsDataURL(file);
        });
    });
}




if (editDestForm) {
    editDestForm.addEventListener('submit', function(event) {
        event.preventDefault();
        const formData = new FormData(editDestForm);

        formData.set('existingAdditionalImgUrls', existingAdditionalPathsArray.join(','));

        console.log('여행지 수정 데이터 (FormData):');
        for (let [key, value] of formData.entries()) {
            console.log(key, value);
        }

        // AJAX로 서버에 수정 요청 (파일 포함)
        fetch('<c:url value="/admin/destinations/editActionWithFiles"/>', {
            method: 'POST',
            body: formData 
            
        })
        .then(response => {
            if (!response.ok) return response.json().then(err => { throw new Error(err.message || '서버 응답 오류') }); // 여기서 에러 발생 시 바로 catch로 감
            return response.json(); 
        })
       .then(data => {
           console.log('여행지 정보 수정 성공:', data);
           editDestModal.classList.add('hidden');
           Toast.fire({icon: "success", title: data.message || "여행지 정보가 성공적으로 수정되었습니다."});
           setTimeout(() => location.reload(), 1500);
       })
       .catch(error => { 
           console.error('여행지 정보 수정 실패:', error);
           
           Toast.fire({icon: "error", title: "여행지 정보 수정 중 오류: " + error.message});
       });
    });
}



if (closeEditDestModalButton) {
    closeEditDestModalButton.addEventListener('click', function() {
        editDestModal.classList.add('hidden');
    });
}


if (cancelEditDestButton) {
    cancelEditDestButton.addEventListener('click', function() {
        editDestModal.classList.add('hidden');
    });
}

// 모달 외부 클릭 시 닫기
if (editDestModal) {
    editDestModal.addEventListener('click', function(event) {
        if (event.target === editDestModal) { 
            editDestModal.classList.add('hidden');
        }
    });
}




</script>