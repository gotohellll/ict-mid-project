package com.midproject.tripin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.model.AdminFAQVO;
import com.midproject.tripin.service.impl.AdminChatInquiryService;

@Controller
@RequestMapping("/admin/chat-inquiries")
public class AdminInquiriesController {
	
	  @Autowired
	    private AdminChatInquiryService chatInquiryService;

	    // 문의 목록 페이지
	    @GetMapping("")
	    public String chatInquiryListPage(
	            @RequestParam(required = false) String inquiryStatus,
	            @RequestParam(required = false) String searchKeyword,
	            Model model, HttpServletRequest request) {

	        HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            return "redirect:/admin/login";
	        }

	        Map<String, Object> params = new HashMap<>();
	        if (inquiryStatus != null && !inquiryStatus.isEmpty()) {
	            params.put("inquiryStatus", inquiryStatus);
	        }
	        if (searchKeyword != null && !searchKeyword.isEmpty()) {
	            params.put("searchKeyword", searchKeyword);
	        }
	        // 페이징 파라미터 추가
	        // params.put("offset", (page - 1) * 10); // 예시: 페이지당 10개
	        // params.put("limit", 10);
		       AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
		       model.addAttribute("currentAdmin", admin);

	        List<AdminFAQVO> inquiryList = chatInquiryService.getChatInquiriesForAdmin(params);
	        // int totalCount = chatInquiryService.getTotalChatInquiriesForAdmin(params);
	        // PageVO pageVO = new PageVO(totalCount, page, 10);

	        model.addAttribute("inquiryList", inquiryList);
	        // model.addAttribute("paging", pageVO);
	        model.addAttribute("currentStatusFilter", inquiryStatus); // 현재 필터 값 유지를 위해
	        model.addAttribute("currentSearchKeyword", searchKeyword);

	        model.addAttribute("pageTitle", "챗봇 문의 관리");
	        model.addAttribute("contentPage", "content_chatInquiryManagement.jsp"); // 이 JSP 파일 필요
	        return "admin/_layout";
	    }

	    // 문의 상세 정보 조회
	    @GetMapping("/api/detail")
	    @ResponseBody
	    public ResponseEntity<?> getChatInquiryDetail(@RequestParam("chat_inq_id") Long chatInqId) {
	    	AdminFAQVO inquiry = chatInquiryService.getChatInquiryDetails(chatInqId);
	        if (inquiry != null) {
	            return ResponseEntity.ok(inquiry);
	        } else {
	            Map<String, String> errorResponse = new HashMap<>();
	            errorResponse.put("message", "문의 정보를 찾을 수 없습니다.");
	            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
	        }
	    }

	    // 관리자 답변 등록/수정 및 상태 변경 처리
	    @PostMapping("/respond")
	    @ResponseBody
	    public ResponseEntity<Map<String, Object>> respondToChatInquiry(
	            @RequestBody AdminFAQVO inquiryDataFromModal, // 모달에서 받은 데이터 (chatInqId, adminResponse, inquiryStatus 등)
	            HttpServletRequest request, RedirectAttributes redirectAttributes) {

	        HttpSession session = request.getSession(false);
	        Map<String, Object> responseBody = new HashMap<>();

	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            responseBody.put("success", false);
	            responseBody.put("message", "관리자 로그인이 필요합니다.");
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(responseBody);
	        }
	        AdminVO performingAdmin = (AdminVO) session.getAttribute("loggedInAdmin");

	        try {

	            boolean success = chatInquiryService.respondToChatInquiry(
	                inquiryDataFromModal.getChat_inq_id(),
	                inquiryDataFromModal.getAdmin_response(),
	                performingAdmin.getAdmin_id(), 
	                inquiryDataFromModal.getInquiry_status(), 
	                inquiryDataFromModal.getPriority(), 
	                inquiryDataFromModal.getInquiry_category() 
	            );

	            if (success) {
	                responseBody.put("success", true);
	                responseBody.put("message", "답변이 성공적으로 처리되었습니다.");
	                return ResponseEntity.ok().body(responseBody);
	            } else {
	                responseBody.put("success", false);
	                responseBody.put("message", "답변 처리에 실패했습니다 (해당 문의를 찾을 수 없거나 업데이트 실패).");
	                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responseBody);
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	            responseBody.put("success", false);
	            responseBody.put("message", "답변 처리 중 서버 오류 발생: " + e.getMessage());
	            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
	        }
	    }
	

	
}
