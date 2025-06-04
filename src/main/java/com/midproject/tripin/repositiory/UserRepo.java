package com.midproject.tripin.repositiory;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.midproject.tripin.model.UserVO;

@Mapper
public interface UserRepo {
	UserVO selectUser(Integer user_id);
	List<UserVO> selectAllUser();
	void insertUser();
	void deleteUser();
	void updateUser(UserVO user);
	UserVO findByEmailForAuth(@Param("email") String email);
	int insertUser(UserVO user);
	UserVO findBySocialIdAndProvider(@Param("social_id") String social_id, @Param("login_provider") String login_provider);
	void updateUserSocialInfo(UserVO existingNormalUserWithSameLoginId);
	List<Map<String, Object>> getUserCountByLoginProvider();
}
