<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="bg-white rounded shadow p-6">
    <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
        <h3 class="text-lg font-medium text-gray-700">관리자 활동 로그</h3>
        <div class="flex flex-wrap gap-2">
            <input type="date" id="logStartDate" class="p-2 border rounded-md text-sm focus:ring-primary focus:border-primary">
            <span class="self-center">~</span>
            <input type="date" id="logEndDate" class="p-2 border rounded-md text-sm focus:ring-primary focus:border-primary">
            <select id="logTargetTypeFilter" class="p-2 border rounded-md text-sm focus:ring-primary focus:border-primary">
                <option value="">대상 전체</option>
                <option value="USER">사용자</option>
                <option value="DESTINATION">여행지</option>
                <option value="REVIEW">리뷰</option>
            </select>
            <input type="text" id="logAdminFilter" placeholder="관리자 ID/이름" class="p-2 border rounded-md text-sm focus:ring-primary focus:border-primary">
            <button id="filterLogsBtn" class="bg-primary text-white px-4 py-2 rounded-md text-sm hover:bg-primary/90">검색</button>,
        </div>
    </div>

    <div class="overflow-x-auto">
        <table id="adminLogTable" class="w-full text-sm text-left min-w-[1000px]">
            <thead>
                <tr>
                    <th scope="col" class="px-6 py-3">로그ID</th>
                    <th scope="col" class="px-6 py-3">수행 관리자</th>
                    <th scope="col" class="px-6 py-3">작업 일시</th>
                    <th scope="col" class="px-6 py-3">대상 유형</th>
                    <th scope="col" class="px-6 py-3">대상 ID</th>
                    <th scope="col" class="px-6 py-3">작업 종류</th>
                    <th scope="col" class="px-6 py-3">결과</th>
                    <th scope="col" class="px-6 py-3">상세</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="log" items="${adminActivityLogList}">
                    <tr>
                        <td class="px-6 py-4" style="background: white">${log.log_id}</td>
                        <td class="px-6 py-4" style="background: white">${log.admin_name}</td> <%-- AdminVO JOIN 가정 --%>
                        <td class="px-6 py-4" style="background: white"><fmt:formatDate value="${log.action_timestamp}" pattern="yyyy-MM-dd HH:mm:ss"/></td>
                        <td class="px-6 py-4" style="background: white">${log.target_type}</td>
                        <td class="px-6 py-4" style="background: white">${log.target_id}</td>
                        <td class="px-6 py-4" style="background: white">${log.action_type}</td>
                        <td class="px-6 py-4" style="background: white">
                            <span class="${log.result_status == '성공' ? 'text-green-600' : 'text-red-600'} font-semibold">
                                ${log.result_status}
                            </span>
                        </td>
                        <td class="px-6 py-4" style="background: white">
                            <button class="text-sm text-blue-600 hover:underline view-log-details-btn"
                                    data-log-id="${log.log_id}" data-details="${fn:escapeXml(log.action_details)}"
                                    >
                                <i class="ri-search-line"></i>
                            </button>
                        </td>
                    </tr>
                </c:forEach>
                 <c:if test="${empty adminActivityLogList}">
                    <tr><td colspan="9" class="text-center py-10 text-gray-500">활동 로그가 없습니다.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
    <%-- 페이지네이션 --%>
</div>

<!-- 로그 상세 보기 모달 (간단 예시) -->
<div id="logDetailModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
    <div class="relative top-20 mx-auto p-5 border w-full max-w-lg shadow-lg rounded-md bg-white">
        <div class="flex justify-between items-center pb-3 border-b">
            <p class="text-xl font-bold">로그 상세 정보</p>
            <button id="closeLogDetailModal" class="p-1"><i class="ri-close-line ri-lg"></i></button>
        </div>
        <div class="mt-3">
            <pre id="logDetailContent" class="text-sm bg-gray-100 p-3 rounded-md whitespace-pre-wrap break-all max-h-96 overflow-y-auto"></pre>
        </div>
    </div>
</div>

<script>
$(document).ready(function() {
    $('#adminLogTable').DataTable({
        responsive: true,
        order: [[ 2, "desc" ]], // 작업일시 내림차순
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

    // 로그 상세 보기 모달
    const logDetailModal = document.getElementById('logDetailModal');
    const closeLogDetailModalButton = document.getElementById('closeLogDetailModal');
    const logDetailContent = document.getElementById('logDetailContent');

    document.querySelectorAll('.view-log-details-btn').forEach(button => {
        button.addEventListener('click', function() {
            const details = this.dataset.details;
            try {
                const parsedDetails = JSON.parse(details);
                logDetailContent.textContent = JSON.stringify(parsedDetails, null, 2);
            } catch (e) {
                logDetailContent.textContent = details;
            }
            logDetailModal.classList.remove('hidden');
        });
    });

    if(closeLogDetailModalButton) closeLogDetailModalButton.addEventListener('click', () => logDetailModal.classList.add('hidden'));
    if(logDetailModal) logDetailModal.addEventListener('click', (e) => { if(e.target === logDetailModal) logDetailModal.classList.add('hidden'); });

    // 필터링 버튼 클릭 시 서버에 요청 보내는 로직 (AJAX 또는 폼 제출)
    $('#filterLogsBtn').on('click', function() {
        const startDate = $('#logStartDate').val();
        const endDate = $('#logEndDate').val();
        const targetType = $('#logTargetTypeFilter').val();
        const adminFilter = $('#logAdminFilter').val();
        console.log("Filter criteria:", {startDate, endDate, targetType, adminFilter});
        alert("필터링 기능 구현 필요");
    });
});
</script>