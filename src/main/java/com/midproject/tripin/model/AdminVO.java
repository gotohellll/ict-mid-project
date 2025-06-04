package com.midproject.tripin.model;

import java.util.Date;

import lombok.Data;

@Data
public class AdminVO {
	
	private Long admin_id;
	private String login_id;
	private String password;
	private String admin_name;
	private String email;
	private Date created_at;

}
