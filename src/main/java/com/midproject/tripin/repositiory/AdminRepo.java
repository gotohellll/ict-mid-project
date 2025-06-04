package com.midproject.tripin.repositiory;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.midproject.tripin.model.AdminVO;

@Mapper
public interface AdminRepo {
	
	AdminVO adminLogin(@Param("login_id") String loginId);
	

}
