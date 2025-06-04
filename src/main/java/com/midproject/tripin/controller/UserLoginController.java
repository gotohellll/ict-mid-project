package com.midproject.tripin.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.UserServiceImpl;

@Controller
//@RequestMapping("/auth") // 선택적: /auth/login, /auth/loginAction 형태로 URL 구성 시
public class UserLoginController {

 @Autowired
 private UserServiceImpl userService; // UserService 인터페이스 사용 권장

 // 로그인 페이지를 보여주는 메소드
 @GetMapping("/index") // 예시 URL: /tripin2/login
 public String loginPage(Model model, @RequestParam(value = "error", required = false) String error,
                         @RequestParam(value = "logout", required = false) String logout) {
     if (error != null) {
         model.addAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
     }
     if (logout != null) {
         model.addAttribute("logoutSuccessMessage", "성공적으로 로그아웃되었습니다."); // Toast 알림용
     }
     return "index"; // 로그인 페이지 JSP 경로 (예: /WEB-INF/views/user/login.jsp)
 }

 // 로그인 처리를 하는 메소드
 @PostMapping("/loginAction") // 예시 URL: /tripin2/loginAction
 public String processLogin(@RequestParam("email") String email, // JSP 폼 input의 name과 일치
                            @RequestParam("password") String password,
                            HttpServletRequest request,
                            RedirectAttributes redirectAttributes) {

     UserVO loggedInUser = userService.authenticateUser(email, password);

     if (loggedInUser != null) {
         // 로그인 성공
         HttpSession session = request.getSession(); // 새 세션 생성 또는 기존 세션 반환
         session.setAttribute("user", loggedInUser); // "loggedInUser" 이름으로 세션에 사용자 정보 저장
         session.setMaxInactiveInterval(1800); // 세션 유효 시간 (초 단위, 예: 30분)

         redirectAttributes.addFlashAttribute("loginSuccessMessage", loggedInUser.getUser_name() + "님, 환영합니다!");

         return "redirect:/mainpage"; // 예시: 애플리케이션 루트 (메인 페이지)로 리다이렉트
     } else {
         // 로그인 실패
         redirectAttributes.addFlashAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
         // 실패 시 입력했던 아이디를 다시 보여주기 위해 (선택적)
         // redirectAttributes.addAttribute("loginId", loginId);
         return "redirect:index?error"; // 로그인 페이지로 리다이렉트하며 에러 파라미터 전달
     }
 }

 // 로그아웃 처리
 @GetMapping("/logout")
 public String logout(HttpSession session) {
     session.invalidate(); // 세션 무효화
     return "redirect:/?logout"; // 로그아웃 후 로그인 페이지로, 로그아웃 파라미터 전달
 }
 
 
 
 @ModelAttribute("user") // JSP에서 ${currentUser.userName} 등으로 사용
 public UserVO addCurrentUserToModel(HttpServletRequest request) {
     HttpSession session = request.getSession(false);
     if (session != null && session.getAttribute("user") != null) {
         return (UserVO) session.getAttribute("user");
     }
     return null; // 로그인 안 된 경우 null
 }
 
}