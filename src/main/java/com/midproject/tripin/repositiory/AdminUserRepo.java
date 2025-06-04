package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.AdminUserVO;

@Mapper
public interface AdminUserRepo {
	 List<AdminUserVO> getUserList();
	    AdminUserVO getUserById(Long userId);
	    int insertUser(AdminUserVO user);
	    int updateUser(AdminUserVO user);
	    int deleteUser(Long userId);
		long getTotalUserCount();
}
