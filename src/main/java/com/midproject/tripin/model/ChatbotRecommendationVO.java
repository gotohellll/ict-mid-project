package com.midproject.tripin.model;

import lombok.Data;

@Data
public class ChatbotRecommendationVO {
	
	private Integer conv_id;
	private Integer user_id;
	private String user_query;
	private String chatbot_resp;
	private String conv_at;
	
}
