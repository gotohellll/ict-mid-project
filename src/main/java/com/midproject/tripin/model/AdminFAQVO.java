package com.midproject.tripin.model;

import java.util.Date;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Data
@ToString
@Getter
@Setter
public class AdminFAQVO {
	  	private Long chat_inq_id;         // CHAT_INQ_ID
	    private Long user_id;            // USER_ID
	    private String user_name;        // JOIN해서 가져올 사용자 이름 (목록 표시에 유용)
	    private String user_query;       // USER_QUERY (CLOB -> String)
	    private String chatbot_resp;     // CHATBOT_RESP (CLOB -> String)
	    private Date conv_at;            // CONV_AT
	    private String inquiry_category;   // INQUIRY_CATEGORY
	    private String inquiry_detail;     // INQUIRY_DETAIL (CLOB -> String)
	    private String inquiry_status;     // INQUIRY_STATUS
	    private Long assigned_admin_id;   // ASSIGNED_ADMIN_ID
	    private String assigned_admin_name; // JOIN해서 가져올 담당 관리자 이름 (목록 표시에 유용)
	    private String admin_response;     // ADMIN_RESPONSE (CLOB -> String)
	    private Date responded_at;       // RESPONDED_AT
	    private Integer priority;         // PRIORITY (NUMBER(1) -> Integer)
}
