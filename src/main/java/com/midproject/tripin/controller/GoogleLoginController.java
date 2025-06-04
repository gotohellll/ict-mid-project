package com.midproject.tripin.controller;

import java.util.Collections;
import java.util.UUID;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken.Payload;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.UserServiceImpl;

@Controller
@RequestMapping("/auth/google")
public class GoogleLoginController {

    private final String GOOGLE_CLIENT_ID = "240873906518-2qdjidtfg7epvjuq7ejsgppcutmq99bl.apps.googleusercontent.com"; // 실제 클라이언트 ID

    @Autowired
    private UserServiceImpl userService;

    @PostMapping("/callback")
    public String googleCallback(@RequestParam("credential") String idTokenString, // Google이 보내는 ID 토큰 이름 (기본 'credential')
                                 HttpSession session,
                                 RedirectAttributes redirectAttributes) {
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                .setAudience(Collections.singletonList(GOOGLE_CLIENT_ID))
                .build();

        GoogleIdToken idToken = null;
        try {
            idToken = verifier.verify(idTokenString);
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("loginError", "Google ID 토큰 검증에 실패했습니다.");
            return "redirect:/";
        }

        if (idToken != null) {
            Payload payload = idToken.getPayload();

            // 페이로드에서 사용자 정보 가져오기
            String userId = payload.getSubject(); // Google 사용자의 고유 ID
            String email = payload.getEmail();
            boolean emailVerified = Boolean.valueOf(payload.getEmailVerified());
            String name = (String) payload.get("name");
            // String pictureUrl = (String) payload.get("picture");
            // String locale = (String) payload.get("locale");
            // String familyName = (String) payload.get("family_name");
            // String givenName = (String) payload.get("given_name");

            if (!emailVerified) {
                redirectAttributes.addFlashAttribute("loginError", "Google 계정의 이메일이 확인되지 않았습니다.");
                return "redirect:/";
            }

            UserVO googleUserInfo = new UserVO();
            googleUserInfo.setSocial_id(userId);
            googleUserInfo.setLogin_provider("GOOGLE");
            googleUserInfo.setLogin_id(email); // 이메일을 로그인 ID로 사용 (정책에 따라)
            googleUserInfo.setUser_name(name != null ? name : "GoogleUser_" + userId.substring(0, 5));
            googleUserInfo.setPassword(UUID.randomUUID().toString()); // 임시 비밀번호

            // 사용자 정보로 회원가입 또는 로그인 처리
            try {
                UserVO loggedInUser = userService.processGoogleUser(googleUserInfo); // 서비스 계층에 위임

                if (loggedInUser != null && loggedInUser.getUser_id() != null) { // UserVO의 실제 ID 필드명 사용
                    session.setAttribute("user", loggedInUser);
                    session.setMaxInactiveInterval(1800);
                    redirectAttributes.addFlashAttribute("loginSuccessMessage", loggedInUser.getUser_name() + "님, Google 계정으로 로그인되었습니다!");
                    System.out.println("Google 로그인 성공: " + loggedInUser.getLogin_id());
                    return "redirect:/mainpage"; // 메인 페이지로
                } else {
                    throw new Exception("Google 사용자 처리 중 오류 발생 (loggedInUser is null or ID is null)");
                }
            } catch (Exception e) {
                e.printStackTrace();
                redirectAttributes.addFlashAttribute("loginError", "Google 로그인 처리 중 오류가 발생했습니다: " + e.getMessage());
                return "redirect:/";
            }

        } else {
            redirectAttributes.addFlashAttribute("loginError", "유효하지 않은 Google ID 토큰입니다.");
            return "redirect:/";
        }
    }
}