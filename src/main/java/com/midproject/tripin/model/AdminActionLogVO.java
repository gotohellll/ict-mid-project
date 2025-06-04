package com.midproject.tripin.model;

import java.util.Date;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class AdminActionLogVO {
	
	private Long log_id;
	private Long admin_id;
	private String admin_name;
	private Date action_timestamp;
	private String target_type;
	private String target_id;
	private String target_name;
	private String action_type;
	private String action_details;
	private String ip_address;
	private String result_status;
	
	

}
