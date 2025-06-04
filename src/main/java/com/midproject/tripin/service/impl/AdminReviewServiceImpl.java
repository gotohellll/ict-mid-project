package com.midproject.tripin.service.impl;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.midproject.tripin.model.AdminActionLogVO;
import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.model.AdminReviewVO;
import com.midproject.tripin.repositiory.AdminReviewRepo;

@Service
public class AdminReviewServiceImpl {
	
	@Autowired
	private AdminReviewRepo reviewRepo;
	
	@Autowired
	private AdminActionLogService activityLogService;
	
	
	 public List<AdminReviewVO> getAllReviewsForAdmin() {
	        return reviewRepo.getAllReviewsForAdmin();
	    }
	 public long getTotalReviewCount() {
		    return reviewRepo.getTotalReviewCount(); // reviewMapper에 해당 ID의 selectOne 쿼리 추가
		}
	 
	 @Transactional
	 public boolean deleteReview(Long reviewId,  AdminVO performingAdmin) {
		 AdminReviewVO reviewToDelete = reviewRepo.getDetailReview(reviewId);    
		 if (reviewToDelete == null) {
	        	AdminActionLogVO log = new AdminActionLogVO();
	            log.setAdmin_id(performingAdmin.getAdmin_id());
	            log.setAction_timestamp(new Date());
	            log.setTarget_type("리뷰");
	            log.setTarget_id(String.valueOf(reviewId));
	            log.setAction_type("리뷰 삭제 시도");
	            log.setAction_details("{\"error\":\"Target user for deletion not found\"}");
	            log.setResult_status("실패"); 
	            activityLogService.recordActivity(log);
	            System.err.println("삭제 대상 리뷰가 존재하지 않습니다. ID: " + reviewId);
	            return false; 
	        }

	        // 2. 실제 사용자 삭제 실행
	        int deletedRows = reviewRepo.deleteReview(reviewId);

	        // 3. 로그 기록
	        AdminActionLogVO log = new AdminActionLogVO();
	        log.setAdmin_id(performingAdmin.getAdmin_id());
	        log.setAction_timestamp(new Date());
	        log.setTarget_type("리뷰");
	        log.setTarget_id(String.valueOf(reviewId));
	        log.setAction_type("리뷰 삭제");

	        if (deletedRows > 0) {
	            String details = createDeletedReviewDetails(reviewToDelete);
	            log.setAction_details(details);
	            log.setResult_status("성공");
	            activityLogService.recordActivity(log);
	            System.out.println("리뷰 삭제 성공. ID: " + reviewId);
	            return true;
	        } else {
	            log.setAction_details("{\"error\":\"User deletion failed in DB, no rows affected\"}");
	            log.setResult_status("실패"); // 또는 "FAILURE"
	            activityLogService.recordActivity(log);
	            System.err.println("리뷰 삭제 실패 (0 rows affected). ID: " + reviewId);
	            return false;
	        }
	 }
	 
	 
	 
	 public AdminReviewVO getDetailReview(Long reviewId) {
		 return reviewRepo.getDetailReview(reviewId);
	 }
	
	 private String createDeletedReviewDetails(AdminReviewVO deletedReview) {
	        if (deletedReview == null) return "{\"message\":\"리뷰 정보 없음\"}";
	        Map<String, Object> detailsMap = new HashMap<>();
	        detailsMap.put("deletedReviewId", deletedReview.getReview_id());
	        detailsMap.put("deletedUserName", deletedReview.getUser_name());
	        detailsMap.put("deletedReviewText", deletedReview.getContent());
	        // 필요한 다른 정보도 추가 가능
	        try {
	            ObjectMapper objectMapper = new ObjectMapper();
	            return objectMapper.writeValueAsString(detailsMap);
	        } catch (JsonProcessingException e) {
	            return "{\"error\":\"삭제된 리뷰 정보 요약 생성 실패\"}";
	        }
	    }	 
	 
	 
}
