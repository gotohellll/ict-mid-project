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
import com.midproject.tripin.model.AdminUserVO;
import com.midproject.tripin.service.impl.AdminServiceImpl;


@Controller
	@RequestMapping("/admin/users")
	public class AdminUserController {

	    @Autowired
	    private AdminServiceImpl userService;

	    // 사용자 목록 페이지
	    @GetMapping("")
	    public String userManagementPage(Model model, HttpServletRequest request) {
	        // 로그인 체크 
	        HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            return "redirect:/admin/login";
	        }
		       AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
		       model.addAttribute("currentAdmin", admin);
	        
	        List<AdminUserVO> userList = userService.getAllUsers();
	        model.addAttribute("userList", userList);
	        model.addAttribute("pageTitle", "사용자 관리");
	        model.addAttribute("contentPage", "content_userManagement.jsp"); 
	    
	        return "admin/_layout";
	    }

	    @GetMapping("/delete")
	    public String deleteUser(@RequestParam("user_id") Long userId, RedirectAttributes redirectAttributes, HttpServletRequest request) {
	    	System.out.println(userId);
	    
	    	 HttpSession session = request.getSession(false);
	    	    if (session == null || session.getAttribute("loggedInAdmin") == null) {
	    	        redirectAttributes.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
	    	        return "redirect:/admin/login";
	    	    }
	    	    AdminVO performingAdmin = (AdminVO) session.getAttribute("loggedInAdmin"); // 현재 로그인한 관리자 정보 가져오기

	    	    try {
	    	        boolean deleteSuccess = userService.deleteUser(userId, performingAdmin);
	    	        if (deleteSuccess) {
	    	            redirectAttributes.addFlashAttribute("successMessage", "사용자(ID: " + userId + ")가 성공적으로 삭제되었습니다.");
	    	        } else {
	    	            redirectAttributes.addFlashAttribute("errorMessage", "사용자(ID: " + userId + ") 삭제에 실패했거나 해당 사용자가 존재하지 않습니다.");
	    	        }
	    	    } catch (Exception e) {
	    	        e.printStackTrace();
	    	        redirectAttributes.addFlashAttribute("errorMessage", "사용자 삭제 중 오류가 발생했습니다: " + e.getMessage());
	    	    }
	    	    return "redirect:/admin/users";
	    	}
	    
	    @GetMapping("/api/detail")
	    @ResponseBody 
	    public AdminUserVO getUserDetailForApi(@RequestParam("user_id") Long userId) {

	        return userService.getUserById(userId); 
	    }
	    
	    @PostMapping("/editAction")
	    @ResponseBody 
	    public ResponseEntity<Map<String, Object>> updateUserAction(@RequestBody AdminUserVO user, HttpServletRequest request) {
	        HttpSession session = request.getSession(false);
	        Map<String, Object> responseBody = new HashMap<>();
	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            responseBody.put("message", "관리자 로그인이 필요합니다.");
	            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(responseBody);
	        }
	        AdminVO performingAdmin = (AdminVO) session.getAttribute("loggedInAdmin");


	        try {
	        
	            boolean updateSuccess = userService.updateUser(user, performingAdmin);

	            if (updateSuccess) {
	                responseBody.put("message", "사용자 정보가 성공적으로 수정되었습니다.");
	                responseBody.put("userId", user.getUser_id());
	                return ResponseEntity.ok().body(responseBody);
	            } else {
	                responseBody.put("message", "사용자 정보 수정에 실패했거나 변경된 내용이 없습니다.");
	                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(responseBody);
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	            responseBody.put("message", "사용자 정보 수정 중 서버 오류 발생: " + e.getMessage());
	            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(responseBody);
	        }
	    }
}
