<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div class="bg-white rounded shadow p-6">
    <div class="flex justify-between items-center mb-6">
        <h3 class="text-lg font-medium text-gray-700">리뷰 목록</h3>
    </div>

    <table id="reviewTable" class="w-full text-sm text-left">
    <thead class="text-xs text-white uppercase bg-primary dark:bg-gray-700 dark:text-gray-400">
            <tr>
                <th class="px-4 py-2 text-left">리뷰ID</th>
                <th class="px-4 py-2 text-left">여행지명</th>
                <th class="px-4 py-2 text-left">작성자</th>
                <th class="px-4 py-2 text-left">평점</th>
                <th class="px-4 py-2 text-left">내용(일부)</th>
                <th class="px-4 py-2 text-left">작성일</th>
                <th class="px-4 py-2 text-left">관리</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="review" items="${reviewList}">
                <tr>
                    <td class="border px-4 py-2" style="background : white">${review.review_id}
                              <c:if test="${review.report_count >= 3}">
	                <i class="ri-flag-fill text-red-500 ml-1" title="신고 ${review.report_count}회 누적"></i>
	           		 </c:if>
                    
                    </td>
                    <td class="border px-4 py-2" style="background : white">${review.dest_name}</td> <%-- JOIN 결과 --%>
                    <td class="border px-4 py-2" style="background : white">${review.user_name}</td> <%-- JOIN 결과 --%>
                    <td class="border px-4 py-2" style="background : white">${review.rating}</td>
                    <td class="border px-4 py-2" style="background : white">
                        <c:choose>
                            <c:when test="${review.content != null && review.content.length() > 30}">
                                ${review.content.substring(0, 30)}...
                            </c:when>
                            <c:otherwise>
                                ${review.content}
                            </c:otherwise>
                        </c:choose>
                    </td>
                    <td class="border px-4 py-2" style="background : white"><fmt:formatDate value="${review.created_at}" pattern="yyyy-MM-dd HH:mm"/></td>
                    <td class="border px-4 py-2" style="background : white">
                        <a href="javascript:void(0);"
               class="font-medium text-indigo-600 hover:text-indigo-800 mr-2 view-review-btn" <%-- 상세보기 버튼 클래스 --%>
               data-review-id="${review.review_id}" <%-- 리뷰 ID를 data 속성으로 전달 --%>
               title="상세보기">
               <i class="ri-eye-line"></i>
            </a>
                        <a href="<c:url value='/admin/reviews/delete?reviewId=${review.review_id}'/>"
                           onclick="return confirm('정말 이 리뷰를 삭제하시겠습니까?');"
                           class="text-red-600 hover:text-red-800" title="삭제"><i class="ri-delete-bin-line"></i></a>
                        <%-- 리뷰 상태 변경 버튼 등 추가 가능 --%>
                    </td>
                </tr>
            </c:forEach>
     
            <c:if test="${empty reviewList}">
                <tr><td colspan="7" class="text-center py-4">등록된 리뷰가 없습니다.</td></tr>
            </c:if>
        </tbody>
    </table>
</div>

<!-- 리뷰 상세 보기 모달 -->
<div id="viewReviewModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white mb-10">
        <!-- 모달 헤더 -->
        <div class="flex justify-between items-center pb-3 border-b">
            <p class="text-2xl font-bold text-gray-700">리뷰 상세 정보</p>
            <div id="closeViewReviewModal" class="cursor-pointer z-50 p-1 hover:bg-gray-200 rounded-full">
                <i class="ri-close-line ri-xl text-gray-500"></i>
            </div>
        </div>

        <!-- 모달 바디 (리뷰 상세 내용 표시) -->
        <div class="mt-5 max-h-[70vh] overflow-y-auto pr-2 space-y-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-3">
                    <div>
                        <label class="block text-sm font-medium text-gray-500">리뷰 ID</label>
                        <p id="detailReviewId_modal" class="mt-1 text-gray-900"></p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">작성일시</label>
                        <p id="detailReviewCreatedAt_modal" class="mt-1 text-gray-900"></p>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-3">
                    <div>
                        <label class="block text-sm font-medium text-gray-500">작성자</label>
                        <p id="detailReviewUserName_modal" class="mt-1 text-gray-900"></p>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-500">여행지</label>
                        <p id="detailReviewDestName_modal" class="mt-1 text-gray-900"></p>
                    </div>
                </div>
			<div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-3">
				<div>
					<label class="block text-sm font-medium text-gray-500">평점</label>
					<p id="detailReviewRating_modal" class="mt-1 text-gray-900"></p>
				</div>
				<div>
					<label class="block text-sm font-medium text-gray-500">신고된
						횟수</label>
					<p id="detailReviewReportCount_modal"
						class="mt-1 text-gray-900 font-semibold"></p>
				</div>
			</div>
			<div class="mb-4">
                    <label class="block text-sm font-medium text-gray-500">리뷰 내용</label>
                    <div id="detailReviewContent_modal" class="mt-1 p-3 text-gray-900 bg-gray-50 rounded-md min-h-[120px] whitespace-pre-wrap break-words border"></div>
                </div>
			<div class="mb-4">
			    <label class="block text-sm font-medium text-gray-500">첨부 사진</label>
			    <div id="detailImagePath_modal" class="mt-2 grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2">
			 
			    </div>
			</div>
        </div>
        <!-- 모달 푸터 -->
        <div class="pt-4 border-t flex justify-end">
            <button type="button" id="closeViewReviewModalButton" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition duration-150">닫기</button>
        </div>
    </div>
</div>


<!-- 이미지 확대 보기 모달 -->
<div id="enlargedImageModal" class="fixed inset-0 bg-black bg-opacity-75 overflow-y-auto h-full w-full hidden z-[60] flex justify-center items-center p-4">
    <div class="relative bg-white p-2 rounded-lg shadow-xl max-w-3xl max-h-[90vh]">
        <!-- 모달 헤더 (닫기 버튼만) -->
        <div class="absolute top-2 right-2 z-10">
            <button id="closeEnlargedImageModal" type="button"
                    class="p-2 bg-gray-700 bg-opacity-50 text-white rounded-full hover:bg-opacity-75 focus:outline-none">
                <i class="ri-close-line ri-lg"></i>
            </button>
        </div>
        <!-- 모달 바디 (확대 이미지) -->
        <div class="w-full h-full flex justify-center items-center">
            <img id="enlargedImageElement" src="" alt="확대된 리뷰 이미지" class="max-w-full max-h-[85vh] object-contain rounded">
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#reviewTable').DataTable({
        responsive: true,
        language: {            emptyTable: "데이터가 없습니다.",
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

const viewReviewModal = document.getElementById('viewReviewModal');
const closeViewReviewModalIcon = document.getElementById('closeViewReviewModal');
const closeViewReviewModalButton = document.getElementById('closeViewReviewModalButton');

// "상세보기" 버튼(.view-review-btn) 클릭 시 이벤트 처리 (이벤트 위임)
document.addEventListener('click', function(event) {
    const viewButton = event.target.closest('.view-review-btn');
    if (viewButton) {
        event.preventDefault();
        const reviewId = viewButton.dataset.reviewId;

        fetch('<c:url value="/admin/reviews/api/detail"/>?review_id=' + reviewId)
            .then(response => {
                if (!response.ok) {
                    throw new Error('리뷰 정보를 가져오는데 실패했습니다. 상태: ' + response.status);
                }
                return response.json();
            })
            .then(reviewData => {
                if (reviewData) {
                    populateViewReviewModal(reviewData);
                    viewReviewModal.classList.remove('hidden');
                } else {
                    alert('리뷰 정보를 찾을 수 없습니다 (ID: ' + reviewId + ').');
                }
            })
            .catch(error => {
                console.error('Error fetching review data:', error);
                alert(error.message);
            });
    }
});

// 모달에 가져온 리뷰 데이터 채우는 함수
function populateViewReviewModal(review) {
    
    const detailReviewIdEl = document.getElementById('detailReviewId_modal');
    if (detailReviewIdEl) detailReviewIdEl.textContent = review.review_id || '-';

    const detailReviewUserNameEl = document.getElementById('detailReviewUserName_modal');
    if (detailReviewUserNameEl) detailReviewUserNameEl.textContent = review.user_name || '-';

    const detailReviewDestNameEl = document.getElementById('detailReviewDestName_modal');
    if (detailReviewDestNameEl) detailReviewDestNameEl.textContent = review.dest_name || '-';

    const detailReviewRatingEl = document.getElementById('detailReviewRating_modal');
    if (detailReviewRatingEl) detailReviewRatingEl.textContent = review.rating !== null ? review.rating.toFixed(1) + '점' : '-';
   
    const reportCountEl = document.getElementById('detailReviewReportCount_modal');
    if (reportCountEl) {
        const reportCount = review.report_count !== null ? review.report_count : 0;
        reportCountEl.textContent = reportCount + ' 회';
        if (reportCount >= 3) { // 신고 횟수가 3회 이상이면
            reportCountEl.classList.add('text-red-600', 'font-bold'); 
        } else {
            reportCountEl.classList.remove('text-red-600', 'font-bold');
        }
    }
    const imageContainer = document.getElementById('detailImagePath_modal');
    console.log(review.image_path);
    if (imageContainer) {
        imageContainer.innerHTML = ''; 

        if (review.image_path && typeof review.image_path === 'string' && review.image_path.trim() !== '') {
            const imagePaths = review.image_path.split(',')
                                     .map(path => path.trim())
                                     .filter(path => path);

            if (imagePaths.length > 0) {
                imagePaths.forEach(imgPath => {
                    const imgDiv = document.createElement('div');
                    imgDiv.className = 'photo-thumbnail w-24 h-24 rounded overflow-hidden border bg-gray-100';

                    const imgElement = document.createElement('img');

                    let imageSrc = contextPath + imgPath;
                    imgElement.src = imageSrc;
                    imgElement.alt = "리뷰 첨부 사진";
                    imgElement.className = "w-full h-full object-cover cursor-pointer review-modal-trigger";
                    imgElement.dataset.fullImage = imageSrc;

                    imgElement.addEventListener('click', function() {
                        openEnlargedImageModal(this.dataset.fullImage);
                    });

                    imgDiv.appendChild(imgElement);
                    imageContainer.appendChild(imgDiv);
                });
            } else {
                imageContainer.innerHTML = '<p class="text-sm text-gray-500 col-span-full">첨부된 사진 정보가 올바르지 않습니다.</p>';
            }
        } else {
            imageContainer.innerHTML = '<p class="text-sm text-gray-500 col-span-full">첨부된 사진이 없습니다.</p>';
        }
    }
    
    
    let createdAtFormatted = '-';
    if (review.created_at) {
        try {
            const date = new Date(review.created_at);
            createdAtFormatted = date.getFullYear() + '-' +
                                 String(date.getMonth() + 1).padStart(2, '0') + '-' +
                                 String(date.getDate()).padStart(2, '0') + ' ' +
                                 String(date.getHours()).padStart(2, '0') + ':' +
                                 String(date.getMinutes()).padStart(2, '0');
        } catch (e) { console.error("날짜 변환 오류(createdAt):", review.created_at, e); }
    }
    
    const detailReviewCreatedAtEl = document.getElementById('detailReviewCreatedAt_modal');
    if (detailReviewCreatedAtEl) detailReviewCreatedAtEl.textContent = createdAtFormatted;

    const contentDiv = document.getElementById('detailReviewContent_modal');
    if (contentDiv) {
        contentDiv.innerHTML = ''; // 기존 내용 비우기
        if (review.content) {
            contentDiv.innerHTML = review.content.replace(/\n/g, '<br>');
        } else {
            contentDiv.textContent = '(내용 없음)';
        }
    }

    const detailReviewStatusEl = document.getElementById('detailReviewStatus_modal');
    if (detailReviewStatusEl) {
        let statusText = review.review_status || '알 수 없음';
        // 한글 상태명으로 변환 
        if (review.review_status === 'PENDING') statusText = '승인 대기';
        else if (review.review_status === 'APPROVED') statusText = '승인';
        else if (review.review_status === 'REJECTED') statusText = '거부';
        else if (review.review_status === 'HIDDEN') statusText = '숨김';
        detailReviewStatusEl.textContent = statusText;

        // 상태에 따라 스타일 변경 
        detailReviewStatusEl.className = 'mt-1 text-gray-900'; // 기본 클래스
        if (review.review_status === 'APPROVED') {
            detailReviewStatusEl.classList.add('text-green-600', 'font-semibold');
        } else if (review.review_status === 'PENDING') {
            detailReviewStatusEl.classList.add('text-yellow-600', 'font-semibold');
        } else if (review.review_status === 'REJECTED' || review.review_status === 'HIDDEN') {
            detailReviewStatusEl.classList.add('text-red-600', 'font-semibold');
        }
    }


}

// 모달 닫기 버튼 (X 아이콘)
if (closeViewReviewModalIcon) {
    closeViewReviewModalIcon.addEventListener('click', function() {
        viewReviewModal.classList.add('hidden');
    });
}

// 모달 푸터 "닫기" 버튼
if (closeViewReviewModalButton) {
    closeViewReviewModalButton.addEventListener('click', function() {
        viewReviewModal.classList.add('hidden');
    });
}

// 모달 바깥 영역 클릭 시 닫기
if (viewReviewModal) {
    viewReviewModal.addEventListener('click', function(event) {
        if (event.target === viewReviewModal) {
            viewReviewModal.classList.add('hidden');
        }
    });
}


const enlargedImageModal = document.getElementById('enlargedImageModal');
const closeEnlargedImageModalButton = document.getElementById('closeEnlargedImageModal');
const enlargedImageElement = document.getElementById('enlargedImageElement');

function openEnlargedImageModal(imageUrl) {
    if (enlargedImageModal && enlargedImageElement) {
        if (imageUrl) {
            enlargedImageElement.src = imageUrl;
            enlargedImageModal.classList.remove('hidden');
            document.body.classList.add('overflow-hidden'); // 모달 열렸을 때 배경 스크롤 방지 (선택적)
        } else {
            console.error("Cannot open enlarged image modal: imageUrl is missing.");
        }
    } else {
        console.error("Enlarged image modal elements not found.");
    }
}

// 모달 닫기 버튼 (X 아이콘)
if (closeEnlargedImageModalButton && enlargedImageModal) {
    closeEnlargedImageModalButton.addEventListener('click', function() {
        enlargedImageModal.classList.add('hidden');
        document.body.classList.remove('overflow-hidden'); 
        if(enlargedImageElement) enlargedImageElement.src = ""; 
    });
}

// 모달 바깥 영역 클릭 시 닫기
if (enlargedImageModal) {
    enlargedImageModal.addEventListener('click', function(event) {
        if (event.target === enlargedImageModal) {
            enlargedImageModal.classList.add('hidden');
            document.body.classList.remove('overflow-hidden');
            if(enlargedImageElement) enlargedImageElement.src = "";
        }
    });
}

// (선택적) ESC 키로 모달 닫기
document.addEventListener('keydown', function(event) {
    if (event.key === "Escape" && enlargedImageModal && !enlargedImageModal.classList.contains('hidden')) {
        enlargedImageModal.classList.add('hidden');
        document.body.classList.remove('overflow-hidden');
        if(enlargedImageElement) enlargedImageElement.src = "";
    }
});




</script>