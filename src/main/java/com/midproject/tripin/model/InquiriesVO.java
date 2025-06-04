package com.midproject.tripin.model;

import lombok.Data;

@Data
public class InquiriesVO {
	private Integer chat_inq_id;
	private Integer user_id;
	private String user_query;
	private String chatbot_resp;
	private String conv_at;
	private String inquiry_category;
	private String inquiry_detail;
	private String inquiry_satus;
	private Integer assigned_admin_id;
	private String admin_response;
	private String responded_at;
	private String priority;
}
