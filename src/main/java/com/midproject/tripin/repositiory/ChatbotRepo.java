package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.web.bind.annotation.PathVariable;

import com.midproject.tripin.model.ChatbotRecommendationVO;
import com.midproject.tripin.model.FAQVO;
import com.midproject.tripin.model.InquiriesVO;

@Mapper
public interface ChatbotRepo {
	List<ChatbotRecommendationVO> getChatList(Integer user_id);
	void insertChat(ChatbotRecommendationVO vo);
	
	FAQVO inquireResponseSelect(Integer inquiry_id);
	List<InquiriesVO> getInquiriesList(@PathVariable Integer user_id);
	void insertInqChat(InquiriesVO vo);
}
