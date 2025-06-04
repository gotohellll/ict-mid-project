package com.midproject.tripin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.midproject.tripin.model.AdminActionLogVO;
import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.service.impl.AdminActionLogService;

@Controller
@RequestMapping("/admin/logs")
public class AdminActionLogController {
	
	@Autowired
	    private AdminActionLogService activityLogService;

	    @GetMapping("") // /admin/logs
	    public String activityLogPage(
	            @RequestParam(required = false) String startDate,
	            @RequestParam(required = false) String endDate,
	            @RequestParam(required = false) String targetType,
	            @RequestParam(required = false) String adminFilter,
	            @RequestParam(required = false) String searchKeyword,
	            // @RequestParam(defaultValue = "1") int page, // 페이징 처리 시
	            Model model, HttpServletRequest request) {

	        // 로그인 체크
	        HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            return "redirect:/admin/login";
	        }
		       AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
		       model.addAttribute("currentAdmin", admin);

	        Map<String, Object> params = new HashMap<>();
	        params.put("startDate", startDate);
	        params.put("endDate", endDate);
	        params.put("targetType", targetType);
	        params.put("adminFilter", adminFilter); // 관리자 ID 또는 이름으로 검색
	        params.put("searchKeyword", searchKeyword); // 대상 ID 또는 상세 내용 검색

	        // 페이징 처리 로직 추가 필요
	        // int pageSize = 10;
	        // params.put("offset", (page - 1) * pageSize);
	        // params.put("limit", pageSize);

	        List<AdminActionLogVO> logList = activityLogService.getLogs(params);
	        // int totalCount = activityLogService.getTotalLogCount(params);
	        // PageVO pageVO = new PageVO(totalCount, page, pageSize); // 페이징 정보 객체

	        model.addAttribute("adminActivityLogList", logList);
	        // model.addAttribute("paging", pageVO);
	        model.addAttribute("filterParams", params); // 검색 조건 유지를 위해

	        model.addAttribute("pageTitle", "관리자 활동 로그");
	        model.addAttribute("contentPage", "content_adminActivityLog.jsp");
	        return "admin/_layout";
	    }

	    // 로그 상세 정보 조회 API (모달용)
	    @GetMapping("/api/detail")
	    @ResponseBody
	    public AdminActionLogVO getLogDetailForApi(@RequestParam("log_id") Long logId) {
	        return activityLogService.getLogById(logId);
	        // 또는 Map<String, Object> 형태로 반환하여 에러 처리 등을 포함할 수 있음
	    }
	}