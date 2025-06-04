package com.midproject.tripin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.midproject.tripin.model.InquiriesVO;
import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.ReviewVO;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.InquiryServiceImpl;
import com.midproject.tripin.service.impl.PlaceServiceImpl;
import com.midproject.tripin.service.impl.ReviewServiceImpl;
import com.midproject.tripin.service.impl.UserServiceImpl;

@Controller
public class MyPageController {
	
	@Autowired
	private UserServiceImpl userServiceImpl;
	@Autowired
	private ReviewServiceImpl reviewServiceImpl;
	@Autowired
	private PlaceServiceImpl placeServiceImpl;
	@Autowired
	private InquiryServiceImpl inquiryServiceImpl;

	@RequestMapping(value="mypage")
	public void mypage(Model m, HttpSession session,HttpServletRequest request) {
		// 밑에 세줄 나중에 로그인 컨트롤러에서 설정해야됨.
		

	    UserVO user = (UserVO) session.getAttribute("user");
	    m.addAttribute("user", user);
	    if (user == null) {
	        System.err.println("MyPageController: loggedInUser is NULL from session. Redirecting to login.");

	    }
	    System.out.println("MyPageController: loggedInUser from session: " + user); // loggedInUser 객체 내용 확인

	    Integer userId = user.getUser_id(); // 또는 getUser_id()
	    System.out.println("MyPageController: Extracted userId: " + userId); // userId 값 확인

	    if (userId == null) {
	        System.err.println("MyPageController: userId is NULL. Redirecting to login or error page.");
	        m.addAttribute("errorMessage", "사용자 ID 정보를 가져올 수 없습니다.");
	       
	    }

	    // --- 여기가 원래 48번째 라인 근처일 것으로 예상되는 부분 ---
	    // 각 서비스 호출 전에 서비스 객체가 null인지 확인 (디버깅용)
	    if (placeServiceImpl == null) System.err.println("placeServiceImpl is NULL!");

		
//		System.out.println("========user_id:"+user_ex.getUser_id());
		
		// 유저별 저장한 여행지, 마이페이지 jsp에서 forEach 돌림
		List<PlaceVO> placeListByUser = placeServiceImpl.selectPlaceByUser(userId);
		m.addAttribute("places", placeListByUser);
		
		// 유저별 리뷰 저장, 마이페이지 jsp에서 forEach 돌림
		List<ReviewVO> rivewListByUser = reviewServiceImpl.selectReviewByUser(user.getUser_id());
		m.addAttribute("reviews", rivewListByUser);
		
		// 유저의 전체 리뷰 갯수 Integer 반환 m에 저장해야함
		Integer reviewCount = reviewServiceImpl.reviewCountByUser(user.getUser_id());
		m.addAttribute("reviewCount", reviewCount);
		
		
		int markedCount = inquiryServiceImpl.markAllResponsesAsCheckedForUser(user.getUser_id());
	    System.out.println("Controller: Marked " + markedCount + " responses as checked for user ID: " + user.getUser_id());
		
		// 여행지 전체리뷰수(dest 객체 가져와야함)
//		Integer reviewCountByDest = reviewServiceImpl.reviewCountByDest(dest.getDest_id());
//		m.addAttribute("reviewCountByDest", reviewCountByDest);
		
		// 여행지 리뷰평점(dest 객체 가져와야함)
//		Float reviewAvgByDest = reviewServiceImpl.reviewAvgByDest(dest.getDest_id());
//		m.addAttribute("reviewAvgByDest", reviewAvgByDest);
		
		// 내 문의 리스트 보이기 jsp에서 forEach 돌려야함
		List<InquiriesVO> inquiries = inquiryServiceImpl.selectInquiryListByUser(userId);
		m.addAttribute("inquiries", inquiries);
			
	}
	
	@RequestMapping("deletereview")
	@ResponseBody
	public void deleteReview(Integer review_id){
		reviewServiceImpl.deleteReview(review_id);
	}
	
	@PostMapping("updateUser")
	public String updateUser(UserVO user) {
		System.out.println(user.toString());
		userServiceImpl.updateUser(user);
		return "redirect: mypage.do";
	}
	@RequestMapping("bookmarkPlace")
	@ResponseBody
	public void bookmarkPlace(Integer user_id, Integer dest_id) {
	Map<String, Object> paramMap = new HashMap<>();
	paramMap.put("user_id", user_id);
	paramMap.put("dest_id", dest_id);
	placeServiceImpl.bookmarkPlace(paramMap);
	}

	// 북마크 지웟을 때 delete(mypage, 테마 검색에서)
	@RequestMapping("deleteBookmark")
	@ResponseBody
	public void deleteBookmark(Integer user_id, Integer dest_id) {
	Map<String, Object> paramMap = new HashMap<>();
	paramMap.put("user_id", user_id);
	paramMap.put("dest_id", dest_id);
	placeServiceImpl.deleteBookmark(paramMap);
	}
	
	
}
