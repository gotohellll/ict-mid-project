package com.midproject.tripin.service.impl;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.midproject.tripin.model.AdminActionLogVO;
import com.midproject.tripin.model.AdminFAQVO;
import com.midproject.tripin.repositiory.AdminChatInquiryRepo;

@Service
public class AdminChatInquiryService {

	    @Autowired
	    private AdminChatInquiryRepo chatInquiryRepo;

	    @Autowired // 관리자 활동 로그 기록을 위해
	    private AdminActionLogService activityLogService;

	    @Transactional
	    public AdminFAQVO submitInquiryFromChat(AdminFAQVO inquiry) {
	        // USER_ID는 챗봇에서 로그인된 사용자 정보를 기반으로 설정되어야 함
	        // INQUIRY_CATEGORY, INQUIRY_DETAIL 등도 챗봇에서 수집하여 inquiry 객체에 담겨야 함
	        inquiry.setConv_at(new Date()); // 서버 시간으로 문의 접수 시간 기록
	        inquiry.setInquiry_status("OPEN"); // 초기 상태
	        inquiry.setPriority(2); // 기본 우선순위 (보통)

	        chatInquiryRepo.insertChatInquiry(inquiry);
	        // 생성된 inquiry 객체에는 트리거에 의해 CHAT_INQ_ID가 채워져 있을 것임 (useGeneratedKeys 설정 시)
	        // 또는 insert 후 ID를 다시 조회해야 할 수도 있음
	        return inquiry; // 생성된 문의 객체 반환 (ID 포함)
	    }
	    
	    public long getOpenInquiryCount() {
	        // ChatInquirySearchVO를 사용하거나, Map 또는 직접 파라미터 전달
	        AdminFAQVO searchVO = new AdminFAQVO();
	        searchVO.setInquiry_status("OPEN");
	        return chatInquiryRepo.getCountByStatus(searchVO);
	        // 또는 chatInquiryRepo.getCountByStatus("OPEN"); 같은 메소드 추가
	    }

	    @Transactional
	    public boolean respondToChatInquiry(Long chatInqId, String adminResponseText, Long performingAdminId, String newStatus, Integer priority, String category) {
	        // 1. 대상 문의 조회
	        AdminFAQVO inquiryToUpdate = chatInquiryRepo.getChatInquiryById(chatInqId); // 반환 타입을 ChatInquiryVO로 가정
	        if (inquiryToUpdate == null) {
	            System.err.println("답변 대상 문의를 찾을 수 없습니다. ID: " + chatInqId);
	            // (선택적) 실패 로그 기록
	            AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdminId); // 파라미터로 받은 adminId 사용
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("문의");
	            log.setTarget_id(String.valueOf(chatInqId));
	            log.setAction_type("문의 답변");
	            log.setAction_details("{\"error\":\"Target inquiry not found\"}");
	            log.setResult_status("실패");
	            activityLogService.recordActivity(log);
	            return false;
	        }

	        // 2. 문의 정보 업데이트
	        inquiryToUpdate.setAdmin_response(adminResponseText);
	        inquiryToUpdate.setAssigned_admin_id(performingAdminId); // 답변하는 관리자를 담당자로 설정
	        inquiryToUpdate.setResponded_at(new Date());
	        inquiryToUpdate.setInquiry_status(newStatus != null && !newStatus.isEmpty() ? newStatus : "RESOLVED"); // 기본적으로 '답변 완료'
	        if (priority != null) {
	            inquiryToUpdate.setPriority(priority);
	        }
	        if (category != null && !category.isEmpty()) {
	            inquiryToUpdate.setInquiry_category(category);
	        }

	        int updatedRows = chatInquiryRepo.updateChatInquiryByAdmin(inquiryToUpdate); // 업데이트 실행

	        // 3. 관리자 활동 로그 기록
	        AdminActionLogVO log = new AdminActionLogVO();
	        log.setAdmin_id(performingAdminId); // 파라미터로 받은 adminId 사용
	        log.setAction_timestamp(new Date());
	        log.setTarget_type("문의"); // 로그 대상 유형 명확히
	        log.setTarget_id(String.valueOf(chatInqId)); // 대상 문의 ID
	        log.setAction_type("문의 답변"); // 액션 유형

	        if (updatedRows > 0) {
	            // 성공 로그 상세 내용 (예: 어떤 상태로 변경되었는지 등)
	            String details = createChatInquiryResponseDetails(inquiryToUpdate, adminResponseText, newStatus);
	            log.setAction_details(details);
	            log.setResult_status("성공");
	            activityLogService.recordActivity(log);
	            System.out.println("챗봇 문의 답변 성공. ID: " + chatInqId);
	            return true;
	        } else {
	            // 실패 로그 (DB 업데이트가 실제로 이루어지지 않은 경우)
	            log.setAction_details("{\"error\":\"Chat inquiry update failed in DB, no rows affected\", \"targetStatus\":\"" + (newStatus != null ? newStatus : "RESOLVED") + "\"}");
	            log.setResult_status("실패");
	            activityLogService.recordActivity(log);
	            System.err.println("챗봇 문의 답변 실패 (0 rows affected). ID: " + chatInqId);
	            return false;
	        }
	    }

	    // 챗봇 문의 답변 상세 내용 생성 헬퍼 메소드 (JSON 형태 권장)
	    private String createChatInquiryResponseDetails(AdminFAQVO inquiry, String responseText, String newStatus) {
	        Map<String, Object> detailsMap = new HashMap<>();
	        detailsMap.put("inquiryId", inquiry.getChat_inq_id());
	        detailsMap.put("userId", inquiry.getUser_id()); // 문의한 사용자 ID
	        detailsMap.put("previousStatus", inquiry.getInquiry_status()); // 변경 전 상태 (DB에서 조회한 inquiry 객체 활용)
	        detailsMap.put("newStatus", newStatus != null ? newStatus : "RESOLVED");
	        detailsMap.put("responseProvided", responseText != null && !responseText.isEmpty());
	        // 필요시 답변 내용 일부도 포함 가능 (너무 길면 요약)
	        // detailsMap.put("responseSummary", responseText != null && responseText.length() > 50 ? responseText.substring(0, 50) + "..." : responseText);

	        try {
	            ObjectMapper objectMapper = new ObjectMapper(); // Jackson 라이브러리
	            return objectMapper.writeValueAsString(detailsMap);
	        } catch (JsonProcessingException e) {
	            return "{\"error\":\"상세 내용 JSON 생성 실패\"}";
	        }
	    }

	    public AdminFAQVO getChatInquiryDetails(Long chatInqId) {
	        return chatInquiryRepo.getChatInquiryById(chatInqId);
	    }

	    public List<AdminFAQVO> getChatInquiriesForAdmin(Map<String, Object> params) {
	        // 페이징 로직 추가
	        return chatInquiryRepo.getChatInquiriesForAdmin(params);
	    }

	    public int getTotalChatInquiriesForAdmin(Map<String, Object> params) {
	        return chatInquiryRepo.getTotalChatInquiriesForAdmin(params);
	    }

	    public List<AdminFAQVO> getMyChatInquiries(Long userId) {
	        return chatInquiryRepo.getChatInquiriesByUserId(userId);
	    }
	    

}
