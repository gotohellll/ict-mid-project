package com.midproject.tripin.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.UserServiceImpl;

@Controller 
@RequestMapping("/api/users")
public class UserApiController {

    @Autowired
    private UserServiceImpl userService;

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$"
    );


    // 회원가입 처리 API (모달에서 AJAX로 호출)
    @PostMapping("/register")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> processRegistration(@RequestBody UserVO user) { // @Valid 및 BindingResult 제외
        Map<String, Object> response = new HashMap<>();
        Map<String, String> errors = new HashMap<>();


        try {
            // 이메일(로그인 ID) 중복 체크
            if (userService.isLoginIdDuplicate(user.getLogin_id())) {
                response.put("success", false);
                response.put("message", "이미 사용 중인 이메일 주소입니다."); // 전체 메시지
                errors.put("loginId", "이미 사용 중인 이메일 주소입니다."); // 필드별 메시지
                response.put("errors", errors);
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response); // 409 Conflict
            }

            boolean registrationSuccess = userService.registerUser(user); // 여기서 예외가 발생하지 않는다고 가정

            if (registrationSuccess) {
                response.put("success", true);
                response.put("message", "회원가입이 성공적으로 완료되었습니다. 로그인해주세요.");
                return ResponseEntity.status(HttpStatus.CREATED).body(response);
            } else {
                // registerUser가 false를 반환하는 경우는 거의 없어야 함 (보통 예외로 처리)
                response.put("success", false);
                response.put("message", "알 수 없는 오류로 회원가입에 실패했습니다.");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
            }
        } catch (IllegalArgumentException iae) {
            response.put("success", false);
            response.put("message", iae.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "회원가입 처리 중 서버 오류가 발생했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}