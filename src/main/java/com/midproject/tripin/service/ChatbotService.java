package com.midproject.tripin.service;

import java.util.List;

import com.midproject.tripin.model.ChatbotRecommendationVO;
import com.midproject.tripin.model.FAQVO;
import com.midproject.tripin.model.InquiriesVO;

public interface ChatbotService {
	List<ChatbotRecommendationVO> getChatList(Integer user_id);
	void insertChat(ChatbotRecommendationVO vo);
	FAQVO inquireResponseSelect(Integer inquiry_id);
	void insertInqChat(InquiriesVO vo);
	List<InquiriesVO> getInquiriesList(Integer user_id);
}
