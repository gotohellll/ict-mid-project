package com.midproject.tripin.model;

import java.util.Date;

import lombok.Data;

@Data
public class UserVO {
	private Integer user_id;
	private Date joined_at;
	private String login_id;
	private String password;
	private String user_name;
	private String address;
	private String phone_num;
	private String birth_date;
	private String is_modified;
	private String social_id;
	private String login_provider;
}
