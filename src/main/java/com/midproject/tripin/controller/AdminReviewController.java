package com.midproject.tripin.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.model.AdminReviewVO;
import com.midproject.tripin.service.impl.AdminReviewServiceImpl;

@Controller
@RequestMapping("/admin/reviews")
public class AdminReviewController {
	   @Autowired
	    private AdminReviewServiceImpl reviewService;

	    @GetMapping("")
	    public String reviewManagementPage(Model model, HttpServletRequest request) {
	        // 로그인 체크
	        HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            return "redirect:/admin/login";
	        }
		       AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
		       model.addAttribute("currentAdmin", admin);
	        List<AdminReviewVO> reviewList = reviewService.getAllReviewsForAdmin();
	        model.addAttribute("reviewList", reviewList);
	        model.addAttribute("pageTitle", "리뷰 관리");
	        model.addAttribute("contentPage", "content_reviewManagement.jsp");
	        return "admin/_layout";
	    }
	    
	    @GetMapping("/api/detail")
	    @ResponseBody 
	    public AdminReviewVO getDetailReview(@RequestParam("review_id") Long reviewId) {
	        return reviewService.getDetailReview(reviewId); 
	    }
	    
	    @GetMapping("/delete")
	    public String deleteUser(@RequestParam("reviewId") Long reviewId, RedirectAttributes redirectAttributes, HttpServletRequest request) {
	    	HttpSession session = request.getSession(false);
    	    if (session == null || session.getAttribute("loggedInAdmin") == null) {
    	        redirectAttributes.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
    	        return "redirect:/admin/login";
    	    }
    	    AdminVO performingAdmin = (AdminVO) session.getAttribute("loggedInAdmin");

    	    try {
    	        boolean deleteSuccess = reviewService.deleteReview(reviewId, performingAdmin);
    	        if (deleteSuccess) {
    	            redirectAttributes.addFlashAttribute("successMessage", "리뷰(ID: " + reviewId + ")가 성공적으로 삭제되었습니다.");
    	        } else {
    	            redirectAttributes.addFlashAttribute("errorMessage", "리뷰(ID: " + reviewId + ") 삭제에 실패했거나 해당 리뷰가 존재하지 않습니다.");
    	        }
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	        redirectAttributes.addFlashAttribute("errorMessage", "리뷰 삭제 중 오류가 발생했습니다: " + e.getMessage());
    	    }
    	    return "redirect:/admin/reviews";
	    }

}
