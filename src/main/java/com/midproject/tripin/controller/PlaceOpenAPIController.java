package com.midproject.tripin.controller;


import java.util.HashMap;
import java.util.Map;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.service.PlaceOpenAPIService;
import com.midproject.tripin.service.PlaceViewService;

@Controller
public class PlaceOpenAPIController {
	
	@Autowired
	private PlaceOpenAPIService placeOpenAPIService;
	
	@Autowired
	private PlaceViewService placeViewService;
	
	
//	@RequestMapping("/{step}.do")
//	public String searchPlace(@PathVariable String step) {
//		
//		return step;
//	}
	
	@GetMapping("admin/fetch")
	public String fetchPlaces(Model m) {
		int count = placeOpenAPIService.fetchAndSavePlaces();
		m.addAttribute("savedCount", count);
		
		return "redirect:/admin/destinations"; 	
	}
	
	
	/*
	 * @GetMapping("/placeDetail.do") public String
	 * detailView(@RequestParam("dest_id") int dest_id, Model m) { PlaceVO place =
	 * placeViewService.getPlaceByDestId(dest_id);
	 * 
	 * if(place == null) { System.out.println("error"+dest_id); }
	 * 
	 * JSONObject detail = placeOpenAPIService.getPlaceDetail( place.getDest_id(),
	 * place.getContent_type());
	 * 
	 * //JsonObject -> Map 변환(jsp EL이 JSONObject인식 못함) Map<String, Object> detailMap
	 * = new HashMap<>(); for (String key : detail.keySet()) { detailMap.put(key,
	 * detail.get(key)); };
	 * 
	 * 
	 * m.addAttribute("place", place); m.addAttribute("detail", detailMap);
	 * 
	 * return "destinationdetail"; }
	 * 
	 */
	
	
	
//	@GetMapping("place_list/json?={selectedTheme}")
//	@ResponseBody
//	public void getPlaceByTheme() {
//		
//	}
	
	
	
	
	
}
