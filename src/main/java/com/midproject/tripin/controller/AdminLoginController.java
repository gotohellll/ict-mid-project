package com.midproject.tripin.controller;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes; // RedirectAttributes 추가

import com.google.gson.Gson;
import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.model.ThemeService;
import com.midproject.tripin.model.ThemeVO;
import com.midproject.tripin.service.VisitService;
import com.midproject.tripin.service.impl.AdminChatInquiryService;
import com.midproject.tripin.service.impl.AdminLoginService;
import com.midproject.tripin.service.impl.AdminReviewServiceImpl;
import com.midproject.tripin.service.impl.AdminServiceImpl;
import com.midproject.tripin.service.impl.AdminStatisticsServiceImpl;


@Controller
@RequestMapping("/admin")
public class AdminLoginController {
	
	@Autowired
	private AdminLoginService adminLoginService;
	
	@Autowired
	private AdminServiceImpl userService;
	
	@Autowired
	private AdminReviewServiceImpl reviewService;
	
	@Autowired
	private AdminChatInquiryService chatInquiryService;
	
	@Autowired
	private AdminStatisticsServiceImpl statisticService;
	
	@Autowired
	 private ThemeService themeService;
	
    @Autowired
    private VisitService visitService;
	
	 private static final String[] CHART_COLORS = {
		        "rgba(54, 162, 235, 0.8)",  // 파랑
		        "rgba(75, 192, 192, 0.8)",  // 청록
		        "rgba(255, 206, 86, 0.8)",  // 노랑
		        "rgba(255, 99, 132, 0.8)",   // 빨강
		        "rgba(153, 102, 255, 0.8)", // 보라
		        "rgba(255, 159, 64, 0.8)",  // 주황
		        "rgba(201, 203, 207, 0.8)"  // 회색
		    };
	
	

    // 로그인 페이지 보여주기
    @GetMapping("/login")
    public String loginPage(Model model, HttpServletRequest request) {
        // RedirectAttributes로 전달된 플래시 메시지가 있다면 모델에 추가
        if (model.containsAttribute("loginError")) {
            // loginError는 RedirectAttributes에서 자동으로 모델에 추가됨
        }
        // 로그아웃 파라미터 처리 (JSP에서 param.logout으로 직접 처리해도 됨)
        if ("true".equals(request.getParameter("logout"))) {
            model.addAttribute("logoutMessage", "성공적으로 로그아웃되었습니다.");
        }
        return "admin/admin_login"; // 로그인 페이지 JSP 경로
    }

    @PostMapping("/loginAction")
    public String loginAction(@RequestParam("admin_id") String adminId, 
                              @RequestParam("password") String password,
                              HttpServletRequest request,
                              RedirectAttributes redirectAttributes) {

        AdminVO authenticatedAdmin = adminLoginService.login(adminId, password);

        if (authenticatedAdmin != null) {
            // 로그인 성공
            HttpSession session = request.getSession(); // 세션 가져오기 (없으면 생성)
            session.setAttribute("loggedInAdmin", authenticatedAdmin); // 세션에 관리자 정보 저장
            session.setMaxInactiveInterval(30 * 60); // 세션 유효 시간 (예: 30분)
            
            redirectAttributes.addFlashAttribute("loginSuccessMessage", "성공적으로 로그인되었습니다, " + authenticatedAdmin.getAdmin_name() + "님!");

            System.out.println("관리자 로그인 성공: " + authenticatedAdmin.getLogin_id());
            return "redirect:/admin/dashboard"; // 관리자 메인 대시보드로 리다이렉트
        } else {
            // 로그인 실패
            System.out.println("관리자 로그인 실패: " + adminId);
            redirectAttributes.addFlashAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
            redirectAttributes.addAttribute("adminId", adminId); // 실패 시 ID 값 유지 (선택적)
            return "redirect:/admin/login"; // 로그인 페이지로 리다이렉트
        }
    }

    // 로그아웃 처리
    @GetMapping("/logout")
    public String logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
            if (admin != null) {
                System.out.println("관리자 로그아웃: " + admin.getLogin_id());
            }
            session.invalidate();
        }
        return "redirect:/admin/login?logout=true";
    }
    
    // 관리자 로그인 정보 대시보드에 출력
    @GetMapping("/dashboard")
    public String mainDashboard(Model model, HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInAdmin") == null) {
            return "redirect:/admin/login"; // 로그인 안했으면 로그인 페이지로
        }
        AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
        model.addAttribute("currentAdmin", admin);
        
        // 요약 카드 데이터 (실제 서비스 호출)
        Random random = new Random();
        model.addAttribute("visitorsToday", 50 + random.nextInt(150)); //더미데이터
        model.addAttribute("visitorsToday", visitService.getTotalVisitCount()); // 오늘 방문자 수(조회수)
        model.addAttribute("totalUsers", userService.getTotalUserCount());
        model.addAttribute("totalApprovedReviews", reviewService.getTotalReviewCount()); // 승인된 리뷰 수
        model.addAttribute("openInquiries", chatInquiryService.getOpenInquiryCount()); // 답변 대기 문의 수

        // --- "여행지 카테고리별 조회수" 도넛 차트 더미 데이터 ---
        List<ThemeVO> themeDataFromDB = themeService.getThemeDateForChart();
        List<Map<String, Object>> categoryViewDataForJson = new ArrayList<>();

        if (themeDataFromDB != null && !themeDataFromDB.isEmpty()) {
            int colorIndex = 0;
            for (ThemeVO theme : themeDataFromDB) {
                Map<String, Object> chartItem = new HashMap<>();
                chartItem.put("label", theme.getTheme_name());
                chartItem.put("value", theme.getTheme_cnt());
                // 미리 정의된 색상 배열에서 순차적으로 색상 할당
                chartItem.put("color", CHART_COLORS[colorIndex % CHART_COLORS.length]);
                categoryViewDataForJson.add(chartItem);
                colorIndex++;
            }
            model.addAttribute("categoryViewDataJson", new Gson().toJson(categoryViewDataForJson));
        } else {
            model.addAttribute("categoryViewDataJson", "[]"); // 데이터 없으면 빈 배열 문자열
        }
        
        // --- "사용자 유입 경로" 차트 더미 데이터 ---
        List<Map<String, Object>> userOriginDataFromService = statisticService.getUserOriginStatsForChart(); // 서비스 호출
        if (userOriginDataFromService == null || userOriginDataFromService.isEmpty()) {
            model.addAttribute("userOriginChartDataJson", "[]"); // 데이터 없으면 빈 배열
        } else {
            model.addAttribute("userOriginChartDataJson", new Gson().toJson(userOriginDataFromService));
        }
        
        
        List<String> monthlyVisitorLabels = new ArrayList<>();
        List<Integer> monthlyVisitorDataPoints = new ArrayList<>();

        // 현재 연도의 5월부터 10월까지 차트 생성
        YearMonth currentYear = YearMonth.now();
                                           
        DateTimeFormatter monthFormatter = DateTimeFormatter.ofPattern("M월");

        for (int month = 5; month <= 10; month++) {
            monthlyVisitorLabels.add(currentYear.withMonth(month).format(monthFormatter));
            if (month == 5) {
                monthlyVisitorDataPoints.add(visitService.getTotalVisitCount());
            } else if(month == 6) {
            	monthlyVisitorDataPoints.add(visitService.getTotalVisitCount());
            }
            else {
                monthlyVisitorDataPoints.add(0);
            }
        }

        Map<String, Object> monthlyVisitorChartData = new HashMap<>();
        monthlyVisitorChartData.put("labels", monthlyVisitorLabels);
        monthlyVisitorChartData.put("data", monthlyVisitorDataPoints);
        model.addAttribute("monthlyVisitorDataJson", new Gson().toJson(monthlyVisitorChartData));
        
        
        
        model.addAttribute("pageTitle", "메인 대시보드");
        model.addAttribute("contentPage", "content_mainDashboard.jsp");
        return "admin/_layout";
    }
}
