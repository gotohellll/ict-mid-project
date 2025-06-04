package com.midproject.tripin.repositiory;

import java.util.List;
import java.util.Map;

import com.midproject.tripin.model.AdminActionLogVO;

public interface AdminActionLogRepo {
	
	int insertLog(AdminActionLogVO log);
	List<AdminActionLogVO> getLogs(Map<String, Object> params);
	AdminActionLogVO getLogById(Long logid);
	int getTotalLogCount(Map<String, Object> params);

}
