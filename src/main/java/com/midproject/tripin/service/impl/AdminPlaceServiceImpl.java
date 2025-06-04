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
import com.midproject.tripin.model.AdminPlaceVO;
import com.midproject.tripin.repositiory.AdminPlaceRepo;

@Service
public class AdminPlaceServiceImpl {
	
	@Autowired
	private AdminPlaceRepo placeRepo;
	
	@Autowired
	private AdminActionLogService activityLogService;
	
	public List<AdminPlaceVO> getAllDestinationsForAdmin(){
		return placeRepo.getAllDestinationsForAdmin();
	}
	
	@Transactional
    public boolean deleteDest(Long destId, AdminVO performingAdmin) {
		AdminPlaceVO destToDelete = placeRepo.getDetailDest(destId); // 이 메소드가 UserMapper에 있다고 가정

        if (destToDelete == null) {
        	AdminActionLogVO log = new AdminActionLogVO();
            log.setAdmin_id(performingAdmin.getAdmin_id());
            log.setAction_timestamp(new Date());
            log.setTarget_type("여행지");
            log.setTarget_id(String.valueOf(destId));
            log.setAction_type("여행지 삭제 시도");
            log.setAction_details("{\"error\":\"Target user for deletion not found\"}");
            log.setResult_status("실패"); 
            activityLogService.recordActivity(log);
            System.err.println("삭제 대상 여행지가 존재하지 않습니다. ID: " + destId);
            return false; 
        }

        // 2. 실제 사용자 삭제 실행
        int deletedRows = placeRepo.deleteDest(destId);

        // 3. 로그 기록
        AdminActionLogVO log = new AdminActionLogVO();
        log.setAdmin_id(performingAdmin.getAdmin_id());
        log.setAction_timestamp(new Date());
        log.setTarget_type("여행지");
        log.setTarget_id(String.valueOf(destId));
        log.setAction_type("여행지 삭제");

        if (deletedRows > 0) {
            // 삭제 성공 로그
            // 삭제된 사용자 정보를 JSON으로 기록 (선택적)
            String details = createDeletedDestDetails(destToDelete); // 삭제된 사용자 정보 요약 함수
            log.setAction_details(details);
            log.setResult_status("성공");
            activityLogService.recordActivity(log);
            System.out.println("여행지 삭제 성공. ID: " + destId);
            return true;
        } else {
            log.setAction_details("{\"error\":\"User deletion failed in DB, no rows affected\"}");
            log.setResult_status("실패"); // 또는 "FAILURE"
            activityLogService.recordActivity(log);
            System.err.println("여행지 삭제 실패 (0 rows affected). ID: " + destId);
            return false;
        }
    }
    public AdminPlaceVO getDetailDest(Long destId){
    	return placeRepo.getDetailDest(destId);
    }
    
    
    @Transactional
    public boolean updateDest(AdminPlaceVO destinationData , AdminVO performingAdmin) {
    	 AdminPlaceVO beforeDest = placeRepo.getDetailDest(destinationData.getDest_id());
	        if (beforeDest == null) {
	            AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdmin.getAdmin_id());
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("여행지");
	            log.setTarget_id(String.valueOf(destinationData.getDest_id()));
	            log.setAction_type("여행지 정보 변경");
	            log.setAction_details("{\"error\":\"Target user not found\"}");
	            log.setResult_status("실패");
	            activityLogService.recordActivity(log);
	            return false;
	        }

	        int updatedRows = placeRepo.updateDest(destinationData);

	        if (updatedRows > 0) {
	        	AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdmin.getAdmin_id());
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("여행지");
	            log.setTarget_id(String.valueOf(destinationData.getDest_id()));
	            log.setAction_type("여행지 정보 변경");

	            String details = createChangeDetailsForDest(beforeDest, destinationData);
	            log.setAction_details(details);
	            log.setResult_status("성공");

	            activityLogService.recordActivity(log);
	            return true;
	        } else {
	        	AdminActionLogVO log = new AdminActionLogVO();
	             log.setAdmin_id(performingAdmin.getAdmin_id());
	             log.setAction_timestamp(new Date());
	             log.setTarget_type("여행지");
	             log.setTarget_id(String.valueOf(destinationData.getDest_id()));
	             log.setAction_type("여행지 정보 변경");
	             log.setAction_details("{\"message\":\"No rows updated in DB\"}");
	             log.setResult_status("실패");
	             activityLogService.recordActivity(log);
	            return false;
	        }
	    }
    
    //업데이트 로그 합수
    private String createChangeDetailsForDest(AdminPlaceVO before, AdminPlaceVO after) {
        Map<String, Object> changes = new HashMap<>();
        if (!Objects.equals(before, after)) {
             changes.put("destName", Map.of("before", before, "after", after));
        }
        if (changes.isEmpty()) return "변경된 내용 없음";
        try {
            ObjectMapper objectMapper = new ObjectMapper(); // 
            return objectMapper.writeValueAsString(changes);
        } catch (JsonProcessingException e) {
            return "{\"error\":\"상세 내용 생성 실패\"}";
        }
    }
    
    //삭제 로그 함수
    private String createDeletedDestDetails(AdminPlaceVO deletedDest) {
        if (deletedDest == null) return "{\"message\":\"사용자 정보 없음\"}";
        Map<String, Object> detailsMap = new HashMap<>();
        detailsMap.put("deletedDestId", deletedDest.getDest_id());
        detailsMap.put("deletedDestName", deletedDest.getDest_name());
        // 필요한 다른 정보도 추가 가능
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.writeValueAsString(detailsMap);
        } catch (JsonProcessingException e) {
            return "{\"error\":\"삭제된 여행지 정보 요약 생성 실패\"}";
        }
    }
    
    
    
    
    

}
