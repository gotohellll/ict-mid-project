package com.midproject.tripin.controller;

import java.util.HashMap;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.midproject.tripin.model.PlaceThemesVO;
import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.PlaceViewService;

@Controller
public class PlaceViewController {
	@Autowired
	private PlaceViewService placeViewService;
	
	private List<PlaceVO> fetchFilterdPlaces(String searchKeyword, Integer theme_id, String sort){

		HashMap<String, Object> map = new HashMap<>();
		map.put("searchKeyword", searchKeyword);
		map.put("theme_id", theme_id);
		map.put("sort", sort);
		
		List<PlaceVO> result = placeViewService.getAllPlaces(map);		

		return result;	
	}

	
	
	//초기 로딩 화면 시 데이터 목록 /검색
	@GetMapping("place_list")
	public String placeList(Model m,@RequestParam(required = false)String searchKeyword,HttpSession session 
							,@RequestParam(required = false)Integer theme_id
							,@RequestParam(required = false) String sort) {
		
		  UserVO user = (UserVO) session.getAttribute("user");
		  m.addAttribute("user", user);
		  Integer userId = user.getUser_id(); // 또는 getUser_id()
		
		
		  List<PlaceVO> result = fetchFilterdPlaces(searchKeyword, theme_id, sort);
			
			
		m.addAttribute("placeList", result);
			

		
		return "place_list";
		
	}
	
	//Ajax 필터용
		@GetMapping("place_list/json")
		@ResponseBody
		public List<PlaceVO> getPlaceByFilter(@RequestParam(required = false) String searchKeyword
											,@RequestParam(required = false) Integer theme_id
											,@RequestParam(required = false) String sort){
			
			return fetchFilterdPlaces(searchKeyword, theme_id, sort);
		}
		
		//조회수 증가 
		@PostMapping("place_list/updateViewCnt")
		@ResponseBody
		public int updateViewcnt(@RequestParam("theme_id") int theme_id) {
			
			return placeViewService.updateViewCnt(theme_id);
		}
		
	}

