package com.midproject.tripin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class PageController {
	
	@RequestMapping(value="chatbot")
	public String chatbotPage() {

	return "chatbot";
	}

	@RequestMapping(value="login")
	public String loginPage() {

	return "login";
	}


}
