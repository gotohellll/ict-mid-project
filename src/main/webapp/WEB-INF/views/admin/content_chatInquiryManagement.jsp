<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="bg-white rounded shadow p-6">
    <div class="flex flex-col sm:flex-row justify-between items-center mb-6 gap-4">
        <h3 class="text-lg font-medium text-gray-700">챗봇 문의 관리</h3>
        <form method="get" action="<c:url value='/admin/chat-inquiries'/>" class="flex flex-wrap gap-2 items-center">
            <select name="inquiryStatus" class="p-2 border rounded-md text-sm focus:ring-primary focus:border-primary">
                <option value="">상태 전체</option>
                <option value="OPEN" ${currentStatusFilter == 'OPEN' ? 'selected' : ''}>답변 대기 (OPEN)</option>
                <option value="ASSIGNED" ${currentStatusFilter == 'ASSIGNED' ? 'selected' : ''}>담당자 배정</option>
                <option value="IN_PROGRESS" ${currentStatusFilter == 'IN_PROGRESS' ? 'selected' : ''}>처리 중</option>
                <option value="RESOLVED" ${currentStatusFilter == 'RESOLVED' ? 'selected' : ''}>답변 완료</option>
                <option value="CLOSED" ${currentStatusFilter == 'CLOSED' ? 'selected' : ''}>종결</option>
                <option value="NEEDS_MORE_INFO" ${currentStatusFilter == 'NEEDS_MORE_INFO' ? 'selected' : ''}>추가 정보 필요</option>
            </select>
            <input type="text" name="searchKeyword" value="${fn:escapeXml(currentSearchKeyword)}" placeholder="사용자명/문의내용 검색" class="p-2 border rounded-md text-sm focus:ring-primary focus:border-primary">
            <button type="submit" class="bg-primary text-white px-4 py-2 rounded-md text-sm hover:bg-primary/90">검색</button>
        </form>
    </div>

    <div class="overflow-x-auto">
        <table id="chatInquiryTable" class="w-full text-sm text-left min-w-[1000px]">
            <thead class="text-xs text-gray-700 uppercase">
                <tr>
                    <th class="px-6 py-3">문의ID</th>
                    <th class="px-6 py-3">사용자</th>
                    <th class="px-6 py-3">문의유형</th>
                    <th class="px-6 py-3">문의요청일시</th>
                    <th class="px-6 py-3">상태</th>
                    <th class="px-6 py-3">우선순위</th>
                    <th class="px-6 py-3">담당자</th>
                    <th class="px-6 py-3">답변</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="inquiry" items="${inquiryList}">
                    <tr>
                        <td class="px-6 py-4" style="background: white">${inquiry.chat_inq_id}</td>
                        <td class="px-6 py-4" style="background: white">${not empty inquiry.user_name ? inquiry.user_name : 'ID:'} ${inquiry.user_id}</td>
                        <td class="px-6 py-4" style="background: white">${inquiry.inquiry_category}</td>
                        <td class="px-6 py-4" style="background: white"><fmt:formatDate value="${inquiry.conv_at}" pattern="yyyy-MM-dd HH:mm"/></td>
                 <td class="px-6 py-4" style="background: white">
    <span class="px-2 py-1 text-xs font-medium rounded-full
        <c:choose>
            <c:when test="${inquiry.inquiry_status == 'OPEN'}">bg-red-100 text-red-800</c:when>
            <c:when test="${inquiry.inquiry_status == 'ASSIGNED'}">bg-blue-100 text-blue-800</c:when>
            <c:when test="${inquiry.inquiry_status == 'IN_PROGRESS'}">bg-yellow-100 text-yellow-800</c:when>
            <c:when test="${inquiry.inquiry_status == 'RESOLVED'}">bg-green-100 text-green-800</c:when>
            <c:when test="${inquiry.inquiry_status == 'CLOSED'}">bg-gray-200 text-gray-700</c:when>
            <c:when test="${inquiry.inquiry_status == 'NEEDS_MORE_INFO'}">bg-purple-100 text-purple-800</c:when>
            <c:otherwise>bg-gray-100 text-gray-500</c:otherwise> 
        </c:choose>
    ">

        <c:choose>
            <c:when test="${inquiry.inquiry_status == 'OPEN'}">답변 대기</c:when>
            <c:when test="${inquiry.inquiry_status == 'ASSIGNED'}">담당자 배정</c:when>
            <c:when test="${inquiry.inquiry_status == 'IN_PROGRESS'}">처리 중</c:when>
            <c:when test="${inquiry.inquiry_status == 'RESOLVED'}">답변 완료</c:when>
            <c:when test="${inquiry.inquiry_status == 'CLOSED'}">종결</c:when>
            <c:when test="${inquiry.inquiry_status == 'NEEDS_MORE_INFO'}">추가 정보 필요</c:when>
            <c:otherwise>${fn:escapeXml(inquiry.inquiry_status)}</c:otherwise> 
        </c:choose>
    </span>
</td>
                        <td class="px-6 py-4" style="background: white">
                            <c:choose>
                                <c:when test="${inquiry.priority == 1}">높음</c:when>
                                <c:when test="${inquiry.priority == 2}">보통</c:when>
                                <c:when test="${inquiry.priority == 3}">낮음</c:when>
                                <c:otherwise>-</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="px-6 py-4" style="background: white">${not empty inquiry.assigned_admin_name ? inquiry.assigned_admin_name : '-'}</td>
                        <td class="px-6 py-4" style="background: white">
                         ${inquiry.chat_inq_id}
                            <a class="font-medium text-primary hover:underline respond-chatinquiry-btn"
                                    data-chatinq-id="${inquiry.chat_inq_id}">
                                <i class="ri-chat-upload-fill"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty inquiryList}">
                    <tr><td colspan="8" class="text-center py-10 text-gray-500">접수된 챗봇 문의가 없습니다.</td></tr>
                </c:if>
            </tbody>
        </table>
    </div>
</div>

<!-- 챗봇 문의 상세 보기 및 답변 모달-->
<div id="chatInquiryModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full hidden z-50">
    <div class="relative top-5 mx-auto p-5 border w-full max-w-3xl shadow-lg rounded-md bg-white mb-5">
        <div class="flex justify-between items-center pb-3 border-b">
            <p class="text-2xl font-bold text-gray-700">챗봇 문의 답변</p>
            <div id="closeChatInquiryModal" class="cursor-pointer z-50 p-1 hover:bg-gray-200 rounded-full">
                <i class="ri-close-line ri-xl text-gray-500"></i>
            </div>
        </div>
        <div class="mt-3 max-h-[80vh] overflow-y-auto pr-2">
            <form id="chatInquiryResponseForm">
               <input type="hidden" id="modal_chatInqId_chat" name="chat_inq_id">

                <div class="space-y-3 mb-4 p-3 border rounded-md bg-slate-50">
                    <h4 class="text-md font-semibold text-gray-800 border-b pb-1 mb-2">문의 접수 내용</h4>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-x-4 gap-y-1 text-sm">
                        <div><strong class="text-gray-600 w-24 inline-block">문의ID:</strong> <span id="modal_detailChatInqId"></span></div>
                        <div><strong class="text-gray-600 w-24 inline-block">요청일시:</strong> <span id="modal_detailChatConvAt"></span></div>
                        <div><strong class="text-gray-600 w-24 inline-block">사용자:</strong> <span id="modal_detailChatUserName"></span> (ID: <span id="modal_detailChatUserId"></span>)</div>
                        <div><strong class="text-gray-600 w-24 inline-block">문의유형:</strong> <span id="modal_detailChatInquiryCategory"></span></div>
                        <div><strong class="text-gray-600 w-24 inline-block">우선순위:</strong> <span id="modal_detailChatPriority"></span></div>
                        <div><strong class="text-gray-600 w-24 inline-block">현재상태:</strong> <span id="modal_detailChatInquiryStatus" class="font-semibold"></span></div>
                    </div>
                     <div class="mt-2">
                        <strong class="block text-gray-600 text-sm mb-1">사용자 초기 질문 (챗봇):</strong>
                        <div id="modal_detailChatUserQuery" class="p-2 text-sm border bg-white rounded-sm min-h-[60px] whitespace-pre-wrap break-words"></div>
                    </div>
                    <div class="mt-2">
                        <strong class="block text-gray-600 text-sm mb-1">챗봇 최종 응답 (문맥):</strong>
                        <div id="modal_detailChatbotResp" class="p-2 text-sm border bg-white rounded-sm min-h-[60px] whitespace-pre-wrap break-words"></div>
                    </div>
                    <div class="mt-2">
                        <strong class="block text-gray-600 text-sm mb-1">사용자 상세 문의 내용:</strong>
                        <div id="modal_detailChatInquiryDetail" class="p-2 text-sm border bg-white rounded-sm min-h-[100px] whitespace-pre-wrap break-words"></div>
                    </div>
                </div>

                <hr class="my-5">
                <h4 class="text-md font-semibold text-gray-800 mb-2">관리자 답변</h4>

                <div class="mb-4">
                    <label for="modal_chatAdminResponse" class="block text-sm font-medium text-gray-700 mb-1">답변 내용</label>
                    <textarea id="modal_chatAdminResponse" name="admin_response" rows="5"
                              class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm"
                              placeholder="답변 내용을 입력하세요..."></textarea>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                        <label for="modal_chatInquiryStatusUpdate" class="block text-sm font-medium text-gray-700">답변 후 상태 변경</label>
                        <select name="inquiry_status" id="modal_chatInquiryStatusUpdate" class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary focus:border-primary sm:text-sm rounded-md bg-white">
                            <option value="OPEN">답변 대기</option>
                            <option value="ASSIGNED">담당자 배정</option>
                            <option value="IN_PROGRESS">처리 중</option>
                            <option value="RESOLVED">답변 완료</option>
                            <option value="CLOSED">종결</option>
                            <option value="NEEDS_MORE_INFO">추가 정보 필요</option>
                        </select>
                    </div>
                    <div>
                        <label for="modal_chatPriorityUpdate" class="block text-sm font-medium text-gray-700">우선순위 변경</label>
                        <select name="priority" id="modal_chatPriorityUpdate" class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary focus:border-primary sm:text-sm rounded-md bg-white">
                            <option value="1">높음</option>
                            <option value="2" selected>보통</option>
                            <option value="3">낮음</option>
                        </select>
                    </div>
                </div>
                 <div class="mb-4">
                    <label for="modal_chatInquiryCategoryUpdate" class="block text-sm font-medium text-gray-700">문의 유형 (필요시 변경)</label>
                    <input type="text" name="inquiry_category" id="modal_chatInquiryCategoryUpdate"
                           class="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary focus:border-primary sm:text-sm">
                </div>


                <div class="pt-4 border-t flex justify-end space-x-2">
                    <button type="button" id="cancelChatInquiryResponse" class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300">취소</button>
                    <button type="submit" class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90">답변/상태 저장</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>

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
    // DataTables 초기화
    $(document).ready(function() {
        $('#chatInquiryTable').DataTable({
            responsive: true,
            order: [[ 3, "desc" ]], // 문의 요청일시 내림차순
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
                    previous: "이전" }}
        });
    });

    // --- 챗봇 문의 모달 관련 스크립트 ---
    const chatInquiryModal = document.getElementById('chatInquiryModal');
    const closeChatInquiryModalButton = document.getElementById('closeChatInquiryModal');
    const cancelChatInquiryResponseButton = document.getElementById('cancelChatInquiryResponse');
    const chatInquiryResponseForm = document.getElementById('chatInquiryResponseForm');

    document.addEventListener('click', function(event) {
        const respondButton = event.target.closest('.respond-chatinquiry-btn');
        if (respondButton) {
            event.preventDefault();
            const chatInqId = respondButton.dataset.chatinqId;

            fetch('<c:url value="/admin/chat-inquiries/api/detail"/>?chat_inq_id=' + chatInqId)
                .then(response => response.json())
                .then(data => {
                    if (data && !data.message) { 
                        populateChatInquiryModal(data);
                        chatInquiryModal.classList.remove('hidden');
                    } else {
                        alert(data.message || '문의 정보를 가져오는데 실패했습니다.');
                    }
                })
                .catch(error => {
                    console.error('Error fetching chat inquiry details:', error);
                    alert('오류가 발생했습니다.');
                });
        }
    });

    function populateChatInquiryModal(inquiry) {
    	  const chatInqIdEl = document.getElementById('modal_chatInqId_chat');
    	    if (chatInqIdEl) {
    	        console.log("Populating modal_chatInqId_chat. inquiry.chat_inq_id:", inquiry.chat_inq_id, "Type:", typeof inquiry.chat_inq_id); // 상세 로그 추가

    	        // inquiry.chat_inq_id가 유효한 값인지 철저히 확인하고 설정
    	        if (inquiry && (typeof inquiry.chat_inq_id === 'number' || (typeof inquiry.chat_inq_id === 'string' && inquiry.chat_inq_id.trim() !== '' && !isNaN(Number(inquiry.chat_inq_id))))) {
    	            chatInqIdEl.value = inquiry.chat_inq_id;
    	        } else {
    	            chatInqIdEl.value = ''; // 유효하지 않으면 빈 문자열로 설정 (또는 에러 처리)
    	            console.warn("modal_chatInqId_chat will be empty because inquiry.chat_inq_id is invalid:", inquiry.chat_inq_id);
    	        }
    	        console.log("Value set to hidden input 'modal_chatInqId_chat':", chatInqIdEl.value);
    	    }
        document.getElementById('modal_chatInqId_chat').value = inquiry.chat_inq_id;

        document.getElementById('modal_detailChatInqId').textContent = inquiry.chat_inq_id || '-';
        document.getElementById('modal_detailChatUserName').textContent = inquiry.user_name || '(정보 없음)';
        document.getElementById('modal_detailChatUserId').textContent = inquiry.user_id || '-';
        document.getElementById('modal_detailChatInquiryCategory').textContent = inquiry.inquiry_category || '-';
        document.getElementById('modal_detailChatUserQuery').innerHTML = (inquiry.user_query || '(내용 없음)').replace(/\n/g, '<br>');
        document.getElementById('modal_detailChatbotResp').innerHTML = (inquiry.chatbot_resp || '(내용 없음)').replace(/\n/g, '<br>');
        document.getElementById('modal_detailChatInquiryDetail').innerHTML = (inquiry.inquiry_detail || '(내용 없음)').replace(/\n/g, '<br>');

        let convAtFormatted = '-';
        if (inquiry.conv_at) {
            try { convAtFormatted = new Date(inquiry.conv_at).toLocaleString('ko-KR'); } catch(e){}
        }
        document.getElementById('modal_detailChatConvAt').textContent = convAtFormatted;

        document.getElementById('modal_detailChatPriority').textContent =
            (inquiry.priority === 1 ? '높음' : inquiry.priority === 2 ? '보통' : inquiry.priority === 3 ? '낮음' : '-');

        document.getElementById('modal_detailChatInquiryStatus').textContent = inquiry.inquiry_status || '-';

        document.getElementById('modal_chatAdminResponse').value = inquiry.admin_response || '';
        document.getElementById('modal_chatInquiryStatusUpdate').value = inquiry.inquiry_status || 'RESOLVED';
        document.getElementById('modal_chatPriorityUpdate').value = inquiry.priority || '2';
        document.getElementById('modal_chatInquiryCategoryUpdate').value = inquiry.inquiry_category || '';
    }

    // 모달 닫기
    if(closeChatInquiryModalButton) closeChatInquiryModalButton.addEventListener('click', () => chatInquiryModal.classList.add('hidden'));
    if(cancelChatInquiryResponseButton) cancelChatInquiryResponseButton.addEventListener('click', () => chatInquiryModal.classList.add('hidden'));
    if(chatInquiryModal) chatInquiryModal.addEventListener('click', (e) => {
        if (e.target === chatInquiryModal) chatInquiryModal.classList.add('hidden');
    });

    // 답변 저장 폼 제출
    if (chatInquiryResponseForm) {
        chatInquiryResponseForm.addEventListener('submit', function(event) {
            event.preventDefault();
            const formData = new FormData(chatInquiryResponseForm);
            const inquiryData = {};
            formData.forEach((value, key) => {
                inquiryData[key] = value;
            });
            	
            const idKey = "chat_inq_id"; // HTML input의 name 속성
            if (inquiryData.hasOwnProperty(idKey)) { // 해당 키가 있는지 먼저 확인
                const idValue = inquiryData[idKey];

                if (idValue === "undefined" || idValue === "" || idValue === null || isNaN(parseInt(idValue, 10))) {
                    inquiryData[idKey] = null;
                    console.warn(`"${idKey}" was invalid ('${idValue}'), set to null for server.`);
                } else {
                    inquiryData[idKey] = parseInt(idValue, 10); // 유효한 숫자면 숫자로 변환
                }
            } else {
                console.error(`"${idKey}" not found in FormData. Check hidden input name attribute.`);
                alert("오류: 문의 ID를 찾을 수 없습니다.");
                return;
            }
            
            // priority도 숫자로 변환
            if (inquiryData.priority && (inquiryData.priority === "undefined" || inquiryData.priority === "" || isNaN(parseInt(inquiryData.priority, 10)))) {
                inquiryData.priority = null; 
            } else if (inquiryData.priority) {
                inquiryData.priority = parseInt(inquiryData.priority, 10);
            }


            fetch('<c:url value="/admin/chat-inquiries/respond"/>', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(inquiryData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    chatInquiryModal.classList.add('hidden');
                    Toast.fire({ icon: 'success', title: data.message || '처리되었습니다.' });
                    setTimeout(() => location.reload(), 1500);
                } else {
                    Toast.fire({ icon: 'error', title: data.message || '오류가 발생했습니다.' });
                }
            })
            .catch(error => {
                console.error('Error responding to chat inquiry:', error);
                Toast.fire({ icon: 'error', title: '통신 중 오류가 발생했습니다.' });
            });
        });
    }
</script>