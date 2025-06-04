package com.midproject.tripin.service.impl;

import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.repositiory.UserRepo;
import com.midproject.tripin.service.UserService;

@Service
public class UserServiceImpl implements UserService {
	
	@Autowired
	private UserRepo userRepo;
	
    @Autowired
    private PasswordEncoder passwordEncoder;

	@Override
	public UserVO selectUser(Integer user_id) {
		return userRepo.selectUser(user_id);
	}

	@Override
	public List<UserVO> selectAllUser() {
		return userRepo.selectAllUser();
	}

	@Override
	public void insertUser() {
		
		
	}

	@Override
	public void deleteUser() {
		
		
	}

	@Override
	public void updateUser(UserVO user) {
		userRepo.updateUser(user);
	}
	
	public UserVO authenticateUser(String loginId, String rawPassword) {
        if (loginId == null || loginId.trim().isEmpty() || rawPassword == null || rawPassword.isEmpty()) {
            return null; // 기본 유효성 검사
        }

        UserVO user = userRepo.findByEmailForAuth(loginId); // DB에서 사용자 정보 조회

        if (user != null) {
            if (passwordEncoder.matches(rawPassword, user.getPassword())) {
                user.setPassword(null); 
                return user;
            }
        }
        return null;
    }
	@Transactional
	public boolean registerUser(UserVO user) throws Exception {
	
	 System.out.println(user);
	 if (user == null || user.getLogin_id() == null || user.getPassword() == null) {
		        throw new IllegalArgumentException("필수 사용자 정보가 누락되었습니다."); 
		 }

	    if (isLoginIdDuplicate(user.getLogin_id())) {
	        // Controller에서 이 예외를 잡거나, false를 반환받아 처리
	        throw new Exception("이미 사용 중인 아이디(이메일)입니다.");
	    }

	    // 비밀번호 해싱
	    user.setPassword(passwordEncoder.encode(user.getPassword()));

	    // DB에 사용자 정보 삽입
	    int insertedRows = userRepo.insertUser(user);
	    return insertedRows > 0;
	}

	   public boolean isLoginIdDuplicate(String loginId) {
	        return userRepo.findByEmailForAuth(loginId) != null;
	    }
	   @Transactional
	   public UserVO processKakaoUser(UserVO kakaoUserInfo) throws Exception {
	       System.out.println("[UserService] processKakaoUser 시작. 전달받은 kakaoUserInfo: " + kakaoUserInfo);

	       // 1. socialId와 loginProvider로 기존 카카오 연동 사용자 조회
	       UserVO existingSocialUser = userRepo.findBySocialIdAndProvider(kakaoUserInfo.getSocial_id(), "KAKAO");
	       System.out.println("[UserService] existingSocialUser (카카오 ID로 조회): " + existingSocialUser);

	       if (existingSocialUser != null) {
	           System.out.println("[UserService] 기존 카카오 사용자 로그인: " + existingSocialUser.getLogin_id());
	           existingSocialUser.setPassword(null);
	           return existingSocialUser;
	       } else {
	           System.out.println("[UserService] 신규 카카오 사용자 처리 시작.");
	           String kakaoLoginId = kakaoUserInfo.getLogin_id();
	           System.out.println("[UserService] 카카오 정보 기반 LOGIN_ID (중복 체크 대상): " + kakaoLoginId);

	           if (kakaoLoginId == null || kakaoLoginId.trim().isEmpty()) {
	               System.err.println("[UserService] 경고: 카카오 정보에서 LOGIN_ID로 사용할 유효한 값이 없습니다. 카카오 ID 기반으로 생성합니다.");
	               kakaoLoginId = "kakao_" + kakaoUserInfo.getSocial_id();
	               kakaoUserInfo.setLogin_id(kakaoLoginId);
	           }

	           UserVO userWithSameLoginId = userRepo.findByEmailForAuth(kakaoLoginId); // findByEmailForAuth 대신 findByLoginId 사용 (일관성)
	           System.out.println("[UserService] userWithSameLoginId (LOGIN_ID로 조회): " + userWithSameLoginId);

	           if (userWithSameLoginId != null) {
	               // LOGIN_ID가 이미 존재함!
	               // 이 사용자가 카카오 연동이 안 되어 있고, 다른 소셜 연동도 안 되어 있다면 (또는 정책에 따라)
	               // 현재 카카오 계정을 이 기존 계정에 연동할 수 있음.
	               if (userWithSameLoginId.getSocial_id() == null || userWithSameLoginId.getSocial_id().isEmpty() ||
	                   (userWithSameLoginId.getLogin_provider() != null && !"KAKAO".equals(userWithSameLoginId.getLogin_provider()))) { // 다른 소셜이 이미 연동된 경우는 정책 필요

	                   System.out.println("[UserService] 기존 계정(" + userWithSameLoginId.getLogin_id() + ")에 카카오 정보 연동 시도.");
	                   userWithSameLoginId.setSocial_id(kakaoUserInfo.getSocial_id());
	                   userWithSameLoginId.setLogin_provider("KAKAO"); // 로그인 제공자를 KAKAO로 업데이트
	                   // 필요시 userWithSameLoginId의 다른 정보(예: userName)도 kakaoUserInfo의 값으로 업데이트
	                   // userWithSameLoginId.setUser_name(kakaoUserInfo.getUser_name());
	                   userRepo.updateUserSocialInfo(userWithSameLoginId); // 이 메소드는 social_id, login_provider 등을 업데이트
	                   userWithSameLoginId.setPassword(null);
	                   return userWithSameLoginId;
	               } else if ("KAKAO".equals(userWithSameLoginId.getLogin_provider()) &&
	                          !userWithSameLoginId.getSocial_id().equals(kakaoUserInfo.getSocial_id())) {
	                   // LOGIN_ID는 같지만 다른 카카오 계정으로 이미 연동된 경우 (이메일은 같지만 다른 카카오 계정)
	                   // 이 경우는 에러 처리 또는 사용자에게 안내 필요
	                   System.err.println("[UserService] 오류: 해당 이메일(LOGIN_ID)은 이미 다른 카카오 계정과 연동되어 있습니다.");
	                   throw new Exception("해당 이메일(LOGIN_ID)은 이미 다른 카카오 계정과 연동되어 있습니다.");
	               } else {
	                   // 그 외의 경우 (예: LOGIN_ID는 같지만 이미 현재 카카오 계정으로 연동된 경우 - 이 경우는 첫 번째 existingSocialUser에서 걸렸어야 함)
	                   // 이 경우는 사실상 발생하기 어려우나, 방어적으로 로깅 및 에러 처리
	                   System.err.println("[UserService] 알 수 없는 LOGIN_ID 중복 상태입니다: " + kakaoLoginId);
	                   throw new Exception("LOGIN_ID 중복 처리 중 알 수 없는 오류가 발생했습니다.");
	               }
	           }

	           // 3. 위에서 중복이 아니라고 판단되면 (userWithSameLoginId가 null이면) 신규 사용자 정보 DB에 삽입
	           System.out.println("[UserService] 최종 INSERT 시도할 kakaoUserInfo: " + kakaoUserInfo);
	           kakaoUserInfo.setJoined_at(new Date());
	           // kakaoUserInfo.setLogin_provider("KAKAO"); // 컨트롤러에서 이미 설정되었는지 확인, 안 되었다면 여기서 설정

	           int insertedRows = userRepo.insertUser(kakaoUserInfo); // 이 호출 후 kakaoUserInfo.user_id에 값이 채워져야 함
	           System.out.println("[UserService] insertedRows: " + insertedRows);
	           System.out.println("[UserService] UserVO after insert (should have ID): " + kakaoUserInfo);

	           if (insertedRows > 0 && kakaoUserInfo.getUser_id() != null) { // ID가 채워졌는지 확인
	               UserVO newUser = new UserVO(); // 반환용 새 객체 또는 kakaoUserInfo 재활용
	               newUser.setLogin_id(kakaoUserInfo.getLogin_id());
	               newUser.setUser_name(kakaoUserInfo.getUser_name());
	               newUser.setSocial_id(kakaoUserInfo.getSocial_id());
	               newUser.setLogin_provider(kakaoUserInfo.getLogin_provider());
	               newUser.setPassword(null); // 비밀번호는 null로 설정
	               return newUser;
	           } else {
	               throw new Exception("카카오 사용자 정보 DB 저장 실패 또는 ID를 가져오지 못했습니다.");
	           }
	       }
	   }
	   
	   @Transactional
	   public UserVO processGoogleUser(UserVO googleUserInfo) throws Exception {
	       // 1. socialId와 loginProvider로 기존 사용자 조회
	       UserVO existingUser = userRepo.findBySocialIdAndProvider(googleUserInfo.getSocial_id(), "GOOGLE");

	       if (existingUser != null) {
	           // 이미 가입된 사용자 -> 로그인 처리
	           System.out.println("기존 Google 사용자 로그인: " + existingUser.getLogin_id()); // 또는 getLogin_id()
	           // 필요시 사용자 정보 업데이트
	           existingUser.setPassword(null);
	           return existingUser;
	       } else {
	           // 신규 사용자 -> 회원가입 처리
	           // Google에서 받은 이메일을 loginId로 사용, 만약 이 loginId가 이미 일반 가입자로 존재한다면 처리 필요
	           UserVO userWithSameLoginId = userRepo.findByEmailForAuth(googleUserInfo.getLogin_id()); // 또는 getLogin_id()
	           if (userWithSameLoginId != null && ("NORMAL".equals(userWithSameLoginId.getLogin_provider()) || userWithSameLoginId.getLogin_provider() == null) ) {
	               // 기존 일반 계정에 Google 정보 연동
	               System.out.println("기존 일반 가입 계정(" + userWithSameLoginId.getLogin_id() + ")에 Google 정보 연동 시도.");
	               userWithSameLoginId.setSocial_id(googleUserInfo.getSocial_id());
	               userWithSameLoginId.setLogin_provider("GOOGLE");
	               // userWithSameLoginId.setUserName(googleUserInfo.getUserName()); // 닉네임 업데이트 등
	               userRepo.updateUserSocialInfo(userWithSameLoginId); // 매퍼에 이 메소드 필요
	               userWithSameLoginId.setPassword(null);
	               return userWithSameLoginId;
	           } else if (userWithSameLoginId != null) {
	               // LOGIN_ID는 같지만 다른 소셜(예: 카카오)로 이미 연동된 경우 또는 알 수 없는 충돌
	               System.err.println("오류: 해당 이메일(LOGIN_ID)은 이미 다른 계정과 연동되어 있거나 사용할 수 없습니다.");
	               throw new Exception("해당 이메일(LOGIN_ID)은 이미 다른 계정과 연동되어 있거나 사용할 수 없습니다.");
	           }


	           System.out.println("신규 Google 사용자 회원가입 시도: " + googleUserInfo.getLogin_id());
	           googleUserInfo.setJoined_at(new Date());
	           // googleUserInfo.setLoginProvider("GOOGLE"); // 컨트롤러에서 이미 설정됨

	           int insertedRows = userRepo.insertUser(googleUserInfo);
	           if (insertedRows > 0) {
	               UserVO newUser = userRepo.findBySocialIdAndProvider(googleUserInfo.getSocial_id(), "GOOGLE");
	               if (newUser != null) {
	                   newUser.setPassword(null);
	               }
	               return newUser;
	           } else {
	               throw new Exception("Google 사용자 정보 DB 저장 실패");
	           }
	       }
	   }

}
