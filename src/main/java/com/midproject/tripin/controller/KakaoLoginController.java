package com.midproject.tripin.controller;

import java.util.UUID;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.UserServiceImpl;

@Controller
@RequestMapping("/auth/kakao")
public class KakaoLoginController {

  
    private final String KAKAO_CLIENT_ID = "5d59b6cf66ed8cb62ea73a8550abec37"; // 실제 REST API 키로 변경!

    private final String KAKAO_REDIRECT_URI = "http://localhost:8080/tripin2/auth/kakao/callback"; // 실제 Redirect URI

    @Autowired
    private UserServiceImpl userService; // UserService 인터페이스 타입으로 주입 권장

    // 카카오 인증 후 호출될 Redirect URI 처리
    @GetMapping("/callback")
    public String kakaoCallback(@RequestParam("code") String code,
                                // @RequestParam(value = "state", required = false) String returnedState, // state 사용 시
                                HttpSession session,
                                RedirectAttributes redirectAttributes) {

        // state 값 검증 로직 (만약 사용했다면) ...

        // 1. 인가 코드로 액세스 토큰 요청
        String accessToken = getAccessToken(code);
        if (accessToken == null) {
            redirectAttributes.addFlashAttribute("loginError", "카카오 토큰 발급에 실패했습니다. 다시 시도해주세요.");
            return "redirect:/"; // 로그인 페이지로
        }
        System.out.println("Kakao Access Token: " + accessToken);


        // 2. 액세스 토큰으로 사용자 정보 요청
        UserVO kakaoUserInfo = getUserInfoFromKakao(accessToken);
        if (kakaoUserInfo == null) {
            redirectAttributes.addFlashAttribute("loginError", "카카오 사용자 정보 조회에 실패했습니다.");
            return "redirect:/";
        }
        System.out.println("Kakao User Info: " + kakaoUserInfo);


        // 3. 사용자 정보로 회원가입 또는 로그인 처리
        try {
            UserVO loggedInUser = userService.processKakaoUser(kakaoUserInfo); // 서비스 계층에 위임

            if (loggedInUser != null && loggedInUser.getUser_id() != null) {
                session.setAttribute("user", loggedInUser);
                session.setMaxInactiveInterval(1800); // 30분
                redirectAttributes.addFlashAttribute("loginSuccessMessage", loggedInUser.getUser_name() + "님, 카카오 계정으로 로그인되었습니다!");
                System.out.println("카카오 로그인 성공: " + loggedInUser.getLogin_id());
                return "redirect:/mainpage"; // 메인 페이지로
            } else {
                throw new Exception("카카오 사용자 처리 중 오류 발생 (loggedInUser is null or ID is null)");
            }
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("loginError", "카카오 로그인 처리 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/";
        }
    }

    private String getAccessToken(String code) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "authorization_code");
        params.add("client_id", KAKAO_CLIENT_ID);
        params.add("redirect_uri", KAKAO_REDIRECT_URI);
        params.add("code", code);
        // 카카오 로그인 시 client_secret은 필수가 아님 (보안 강화를 위해 설정했다면 추가)

        HttpEntity<MultiValueMap<String, String>> kakaoTokenRequest = new HttpEntity<>(params, headers);

        try {
            ResponseEntity<String> response = rt.exchange(
                    "https://kauth.kakao.com/oauth/token",
                    HttpMethod.POST,
                    kakaoTokenRequest,
                    String.class
            );
            if (response.getStatusCode() == HttpStatus.OK) {
                ObjectMapper objectMapper = new ObjectMapper();
                JsonNode jsonNode = objectMapper.readTree(response.getBody());
                return jsonNode.get("access_token").asText();
            } else {
                System.err.println("Failed to get Kakao access token: " + response.getBody());
            }
        } catch (Exception e) {
            System.err.println("Error while getting Kakao access token: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    private UserVO getUserInfoFromKakao(String accessToken) {
        RestTemplate rt = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", "Bearer " + accessToken);
        headers.add("Content-type", "application/x-www-form-urlencoded;charset=utf-8");

        HttpEntity<MultiValueMap<String, String>> kakaoProfileRequest = new HttpEntity<>(headers);

        try {
            ResponseEntity<String> response = rt.exchange(
                    "https://kapi.kakao.com/v2/user/me",
                    HttpMethod.POST,
                    kakaoProfileRequest,
                    String.class
            );
            if (response.getStatusCode() == HttpStatus.OK) {
                ObjectMapper objectMapper = new ObjectMapper();
                JsonNode jsonNode = objectMapper.readTree(response.getBody());

                long id = jsonNode.get("id").asLong();
                JsonNode kakaoAccount = jsonNode.get("kakao_account");
                UserVO user = new UserVO();
                user.setSocial_id(String.valueOf(id));
                user.setLogin_provider("KAKAO");

                if (kakaoAccount != null) {
                    if (kakaoAccount.has("profile") && kakaoAccount.get("profile") != null) {
                        JsonNode profile = kakaoAccount.get("profile");
                        if (profile.has("nickname")) {
                            user.setUser_name(profile.get("nickname").asText());
                        }
                    }
                    // 이메일 동의 항목을 설정하고 사용자가 동의한 경우
                    if (kakaoAccount.has("email") && kakaoAccount.get("has_email").asBoolean() &&
                        kakaoAccount.has("email_needs_agreement") && !kakaoAccount.get("email_needs_agreement").asBoolean() &&
                        kakaoAccount.has("is_email_valid") && kakaoAccount.get("is_email_valid").asBoolean() &&
                        kakaoAccount.has("is_email_verified") && kakaoAccount.get("is_email_verified").asBoolean()) {
                        user.setLogin_id("kakao_" + kakaoAccount.get("email").asText()); // 또는 email 필드에 저장
                       
                    }
                }
                // 사용자 이름이 없다면 기본값 설정
                if (user.getUser_name() == null || user.getUser_name().isEmpty()) {
                    user.setUser_name("KakaoUser_" + id);
                }
                // 내부 시스템용 로그인 ID (이메일이 없다면 카카오 ID 기반으로 생성)
                if (user.getLogin_id() == null || user.getLogin_id().isEmpty()) {
                    user.setLogin_id("kakao_" + id);
                }
                // 카카오 로그인은 비밀번호가 없으므로, 임시값 또는 null 처리 (DB NOT NULL 제약에 따라)
                user.setPassword(UUID.randomUUID().toString()); // 실제 로그인에는 사용 안 함

                return user;
            } else {
                 System.err.println("Failed to get Kakao user info: " + response.getBody());
            }
        } catch (Exception e) {
            System.err.println("Error while getting Kakao user info: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}