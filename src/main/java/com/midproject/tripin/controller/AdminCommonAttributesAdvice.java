package com.midproject.tripin.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.AdminChatInquiryService;
import com.midproject.tripin.service.impl.InquiryServiceImpl;
import com.midproject.tripin.service.impl.UserServiceImpl;

@ControllerAdvice(basePackages = "com.midproject.tripin.controller") 
public class AdminCommonAttributesAdvice {

 @Autowired(required = false) // ChatInquiryService가 아직 Bean으로 등록 안됐을 수도 있으므로, 일단 false로 (실제로는 true여야 함)
 private AdminChatInquiryService chatInquiryService;
 
 @Autowired(required = false)
 private InquiryServiceImpl inquiryService;
 
	@Autowired
	private UserServiceImpl userServiceImpl;


 @ModelAttribute("currentAdminGlobal") // JSP에서 사용할 모델 어트리뷰트 이름
 public AdminVO addCurrentAdminToModel(HttpServletRequest request) {
     HttpSession session = request.getSession(false);
     if (session != null && session.getAttribute("loggedInAdmin") != null) {
         return (AdminVO) session.getAttribute("loggedInAdmin");
     }
     return null;
 }

 @ModelAttribute("openInquiriesCountGlobal") // JSP에서 사용할 모델 어트리뷰트 이름
 public long addOpenInquiriesCountToModel(HttpServletRequest request) {
     HttpSession session = request.getSession(false);
     // 관리자 페이지에만 이 로직이 필요하므로, 로그인 여부 등을 추가로 확인할 수 있습니다.
     // 예를 들어, 로그인한 관리자가 있을 때만 실제 카운트를 가져오도록 합니다.
     if (session != null && session.getAttribute("loggedInAdmin") != null) {
         if (chatInquiryService != null) {
             // 실제 서비스에서는 특정 상태('OPEN')의 문의만 카운트하는 메소드 사용
             // return chatInquiryService.getOpenInquiryCount(); // 예시 메소드
             // 임시로 더미 값 반환 (ChatInquiryService 구현 전)
             // Map<String, Object> params = new HashMap<>();
             // params.put("inquiryStatus", "OPEN");
             // return chatInquiryService.getTotalChatInquiriesForAdmin(params);
             // 지금은 ChatInquiryService에 getOpenInquiryCount()가 있다고 가정
             try {
                 return chatInquiryService.getOpenInquiryCount();
             } catch (Exception e) {
                 // 서비스 호출 중 예외 발생 시 (예: DB 연결 문제)
                 System.err.println("Error fetching open inquiry count in ControllerAdvice: " + e.getMessage());
                 return 0; // 또는 -1 등으로 오류 표시
             }
         } else {
             System.err.println("ChatInquiryService is not wired in GlobalAdminAttributesAdvice.");
             return 0; // ChatInquiryService가 주입되지 않은 경우
         }
     }
     return 0; // 로그인하지 않았거나 일반 사용자 페이지에서는 0 반환
 }
 


 @ModelAttribute("uncheckedInquiryCount") // JSP에서 사용할 모델 어트리뷰트 이름
 public int addUncheckedInquiryCountToModel(HttpServletRequest request,Model m) {
     HttpSession session = request.getSession(false);
     // --- 실제 알림 카운트를 위한 로직 ---
     if (session != null && session.getAttribute("user") != null) { // "loggedInUser"는 실제 로그인 시 세션에 저장된 사용자 객체 이름으로 가정
         UserVO loggedInUser = (UserVO) session.getAttribute("user");
         if (loggedInUser != null && loggedInUser.getUser_id() != null) { // 필드명이 userId라고 가정
             try {
                 // inquiryService가 null이 아닌지 확인하는 것이 좋음 (Autowired 되었는지)
                 if (inquiryService != null) {
                     return inquiryService.getUncheckedResponseCount(loggedInUser.getUser_id());
                 } else {
                     System.err.println("ControllerAdvice: inquiryService is null.");
                     return 0;
                 }
             } catch (Exception e) {
                 System.err.println("Error fetching unchecked inquiry count for user: " + e.getMessage());
                 return 0;
             }
         } else {
             System.err.println("ControllerAdvice: loggedInUser or its ID is null.");
             return 0; // 로그인된 사용자 정보나 ID가 없는 경우
         }
     }
     return 0; // 세션이 없거나 로그인하지 않은 경우
 }
 
}