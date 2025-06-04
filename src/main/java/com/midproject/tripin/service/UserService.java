package com.midproject.tripin.service;

import java.util.List;

import com.midproject.tripin.model.UserVO;

public interface UserService {
	
	UserVO selectUser(Integer user_id);
	List<UserVO> selectAllUser();
	void insertUser();
	void deleteUser();
	void updateUser(UserVO user);
	
}
