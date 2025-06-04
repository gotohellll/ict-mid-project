package com.midproject.tripin.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import com.midproject.tripin.model.ChatbotRecommendationVO;
import com.midproject.tripin.model.FAQVO;
import com.midproject.tripin.model.InquiriesVO;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.impl.ChatbotServiceImpl;

@RestController
public class ChatbotController {
	
	@Autowired
	private ChatbotServiceImpl chatbotServiceImpl;
	  
	// ********추천챗봇***********
	  @GetMapping(value="selectByUser")
	  public List<ChatbotRecommendationVO> getChatList(Integer user_id, Model m, HttpSession session) {
		  UserVO user = (UserVO) session.getAttribute("user");
		    m.addAttribute("user", user);
		    Integer userId = user.getUser_id(); // 또는 getUser_id()

		  List<ChatbotRecommendationVO> chatList = chatbotServiceImpl.getChatList(userId);
		  m.addAttribute("chatList", chatList);
		  return chatList;

		  
		  
	  }
	  
	  @PostMapping(value="insertChat")
	  public void insertChat(Integer user_id, ChatbotRecommendationVO vo,Model m, HttpSession session){
		  UserVO user = (UserVO) session.getAttribute("user");
		    m.addAttribute("user", user);
		    Integer userId = user.getUser_id(); 
		    vo.setUser_id(userId);
		  chatbotServiceImpl.insertChat(vo);
	  }
	  
	  
	// ********문의챗봇***********
	  @GetMapping(value="inquiry")
	  public FAQVO inquireResponseSelect(Integer inquiry_id,Model m, HttpSession session) {
		  UserVO user = (UserVO) session.getAttribute("user");
		   m.addAttribute("user", user);
		   Integer userId = user.getUser_id(); 
		  FAQVO faqVO = chatbotServiceImpl.inquireResponseSelect(inquiry_id);
		  return faqVO;
	  }
	  
	  @GetMapping(value="inquiries")
	  public List<InquiriesVO> getInquiriesList(Integer user_id,Model m, HttpSession session){
		  UserVO user = (UserVO) session.getAttribute("user");
		    m.addAttribute("user", user);
		    Integer userId = user.getUser_id(); 
		  List<InquiriesVO> inquiriesList = chatbotServiceImpl.getInquiriesList(userId);
		  return inquiriesList;
	  }
	  
	  @PostMapping(value="insertInqChat")
	  public void insertInqChat(Integer user_id, InquiriesVO vo,Model m, HttpSession session){
		  UserVO user = (UserVO) session.getAttribute("user");
		    m.addAttribute("user", user);
		    Integer userId = user.getUser_id(); 
		    vo.setUser_id(userId);
		  chatbotServiceImpl.insertInqChat(vo);
	  }
	  
	  
}
