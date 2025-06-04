package com.midproject.tripin.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.ChatbotRecommendationVO;
import com.midproject.tripin.model.FAQVO;
import com.midproject.tripin.model.InquiriesVO;
import com.midproject.tripin.repositiory.ChatbotRepo;
import com.midproject.tripin.service.ChatbotService;

@Service
public class ChatbotServiceImpl implements ChatbotService {
	
	@Autowired
	private ChatbotRepo chatbotRepo;
	
	
	public List<ChatbotRecommendationVO> getChatList(Integer user_id) {
		return chatbotRepo.getChatList(user_id);
	}
	public void insertChat(ChatbotRecommendationVO vo) {
		chatbotRepo.insertChat(vo);
	}
	public FAQVO inquireResponseSelect(Integer inquiry_id) {
		return chatbotRepo.inquireResponseSelect(inquiry_id);
	}
	
	public void insertInqChat(InquiriesVO vo) {
		chatbotRepo.insertInqChat(vo);
	}
	
	public List<InquiriesVO> getInquiriesList(Integer user_id){
		return chatbotRepo.getInquiriesList(user_id);
	}
}
