package com.midproject.tripin.service.impl;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.AdminActionLogVO;
import com.midproject.tripin.repositiory.AdminActionLogRepo;

@Service
public class AdminActionLogService {
	
	 @Autowired
	    private AdminActionLogRepo adminActivityLogRepo;

	    public void recordActivity(AdminActionLogVO log) {
	        adminActivityLogRepo.insertLog(log);
	    }

	    public List<AdminActionLogVO> getLogs(Map<String, Object> params) {
	        // 페이징 로직 추가 필요
	        return adminActivityLogRepo.getLogs(params);
	    }

	    public int getTotalLogCount(Map<String, Object> params) {
	        return adminActivityLogRepo.getTotalLogCount(params);
	    }

	    public AdminActionLogVO getLogById(Long logId) {
	        return adminActivityLogRepo.getLogById(logId);
	    }

}
