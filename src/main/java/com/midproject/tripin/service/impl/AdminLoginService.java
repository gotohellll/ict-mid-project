package com.midproject.tripin.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.repositiory.AdminRepo;

@Service
public class AdminLoginService {
	
	@Autowired
	private AdminRepo adminRepo;
	
	@Autowired(required = false)
	private PasswordEncoder password;
	
	public AdminVO login(String loginId, String Password) {
		AdminVO admin = adminRepo.adminLogin(loginId);
		
		if (admin != null) {
            // DB에 저장된 해시된 비밀번호와 입력된 평문 비밀번호를 비교
            if (password != null) { // PasswordEncoder 빈이 주입되었다면 사용
                if (password.matches(Password, admin.getPassword())) {
                    admin.setPassword(null); // 세션에 저장 시 비밀번호는 제거
                    return admin;
                }
            } else {
                // 경고: PasswordEncoder 없이 평문 비교는 매우 위험합니다.
                // 임시 테스트용 또는 해싱 미적용 시 (절대 프로덕션에 사용 금지)
                if (Password.equals(admin.getPassword())) {
                    System.err.println("경고: 비밀번호가 평문으로 비교되고 있습니다. 보안에 매우 취약합니다!");
                    admin.setPassword(null);
                    return admin;
                }
            }
        }
        return null; // 사용자가 없거나 비밀번호 불일치
    }
		
	}

