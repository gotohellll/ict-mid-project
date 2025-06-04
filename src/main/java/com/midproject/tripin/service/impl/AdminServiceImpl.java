package com.midproject.tripin.service.impl;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.midproject.tripin.model.AdminActionLogVO;
import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.model.AdminUserVO;
import com.midproject.tripin.repositiory.AdminUserRepo;

@Service("adminService")
public class AdminServiceImpl {
	  
		@Autowired
	    private AdminUserRepo userMapper;
		
		@Autowired
		private AdminActionLogService activityLogService;
		
	    // @Autowired
	    // private PasswordEncoder passwordEncoder; // 비밀번호 해싱을 위해 주입 (Spring Security 사용 시)

	    public List<AdminUserVO> getAllUsers() {
	        return userMapper.getUserList();
	    }
	    public long getTotalUserCount() {
	        return userMapper.getTotalUserCount(); // userMapper에 해당 ID의 selectOne 쿼리 추가
	    }

	    public AdminUserVO getUserById(Long userId) {
	        return userMapper.getUserById(userId);
	    }

	    public void registerUser(AdminUserVO user) {
	        userMapper.insertUser(user);
	    }
	    
	    @Transactional
	    public boolean updateUser(AdminUserVO userToUpdate, AdminVO performingAdmin /*, HttpServletRequest request */) {
	        AdminUserVO beforeUser = userMapper.getUserById(userToUpdate.getUser_id());
	        if (beforeUser == null) {
	            AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdmin.getAdmin_id());
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("사용자");
	            log.setTarget_id(String.valueOf(userToUpdate.getUser_id()));
	            log.setAction_type("사용자 정보 변경");
	            log.setAction_details("{\"error\":\"Target user not found\"}");
	            log.setResult_status("실패");
	            activityLogService.recordActivity(log);
	            return false;
	        }

	        int updatedRows = userMapper.updateUser(userToUpdate);

	        if (updatedRows > 0) {
	        	AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdmin.getAdmin_id());
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("사용자");
	            log.setTarget_id(String.valueOf(userToUpdate.getUser_id()));
	            log.setAction_type("사용자 정보 변경");

	            String details = createChangeDetailsForUser(beforeUser, userToUpdate);
	            log.setAction_details(details);
	            log.setResult_status("성공");

	            activityLogService.recordActivity(log);
	            return true;
	        } else {
	        	AdminActionLogVO log = new AdminActionLogVO();
	             log.setAdmin_id(performingAdmin.getAdmin_id());
	             log.setAction_timestamp(new Date());
	             log.setTarget_type("사용자");
	             log.setTarget_id(String.valueOf(userToUpdate.getUser_id()));
	             log.setAction_type("사용자 정보 변경");
	             log.setAction_details("{\"message\":\"No rows updated in DB\"}");
	             log.setResult_status("실패");
	             activityLogService.recordActivity(log);
	            return false;
	        }
	    }

	    
	    @Transactional
	    public boolean deleteUser(Long userIdToDelete, AdminVO performingAdmin) {
	    	AdminUserVO userToDelete = userMapper.getUserById(userIdToDelete); // 이 메소드가 UserMapper에 있다고 가정

	        if (userToDelete == null) {
	        	AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdmin.getAdmin_id());
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("사용자");
	            log.setTarget_id(String.valueOf(userIdToDelete));
	            log.setAction_type("사용자 삭제 시도");
	            log.setAction_details("{\"error\":\"Target user for deletion not found\"}");
	            log.setResult_status("실패"); 
	            activityLogService.recordActivity(log);
	            System.err.println("삭제 대상 사용자가 존재하지 않습니다. ID: " + userIdToDelete);
	            return false; 
	        }

	        // 2. 실제 사용자 삭제 실행
	        int deletedRows = userMapper.deleteUser(userIdToDelete);

	        // 3. 로그 기록
	        AdminActionLogVO log = new AdminActionLogVO();
	        log.setAdmin_id(performingAdmin.getAdmin_id());
	        log.setAction_timestamp(new Date());
	        log.setTarget_type("사용자");
	        log.setTarget_id(String.valueOf(userIdToDelete));
	        log.setAction_type("사용자 삭제");

	        if (deletedRows > 0) {
	            // 삭제 성공 로그
	            // 삭제된 사용자 정보를 JSON으로 기록 (선택적)
	            String details = createDeletedUserDetails(userToDelete); // 삭제된 사용자 정보 요약 함수
	            log.setAction_details(details);
	            log.setResult_status("성공");
	            activityLogService.recordActivity(log);
	            System.out.println("사용자 삭제 성공. ID: " + userIdToDelete);
	            return true;
	        } else {
	            log.setAction_details("{\"error\":\"User deletion failed in DB, no rows affected\"}");
	            log.setResult_status("실패"); // 또는 "FAILURE"
	            activityLogService.recordActivity(log);
	            System.err.println("사용자 삭제 실패 (0 rows affected). ID: " + userIdToDelete);
	            return false;
	        }
	    }
	    
	    
	    
	    private String createChangeDetailsForUser(AdminUserVO before, AdminUserVO after) {
	        Map<String, Object> changes = new HashMap<>();
	        if (!Objects.equals(before, after)) {
	             changes.put("userName", Map.of("before", before, "after", after));
	        }
	        if (changes.isEmpty()) return "변경된 내용 없음";
	        try {
	            ObjectMapper objectMapper = new ObjectMapper(); // 
	            return objectMapper.writeValueAsString(changes);
	        } catch (JsonProcessingException e) {
	            return "{\"error\":\"상세 내용 생성 실패\"}";
	        }
	    }
	    
	    private String createDeletedUserDetails(AdminUserVO deletedUser) {
	        if (deletedUser == null) return "{\"message\":\"사용자 정보 없음\"}";
	        Map<String, Object> detailsMap = new HashMap<>();
	        detailsMap.put("deletedUserId", deletedUser.getUser_id());
	        detailsMap.put("deletedLoginId", deletedUser.getLogin_id());
	        detailsMap.put("deletedUserName", deletedUser.getUser_name());
	        // 필요한 다른 정보도 추가 가능
	        try {
	            ObjectMapper objectMapper = new ObjectMapper();
	            return objectMapper.writeValueAsString(detailsMap);
	        } catch (JsonProcessingException e) {
	            return "{\"error\":\"삭제된 사용자 정보 요약 생성 실패\"}";
	        }
	    }
}
