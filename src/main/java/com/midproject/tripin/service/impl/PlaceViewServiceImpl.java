package com.midproject.tripin.service.impl;

import java.util.HashMap;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.repositiory.PlaceViewRepo;
import com.midproject.tripin.service.PlaceViewService;

@Service("placeViewService")
public class PlaceViewServiceImpl implements PlaceViewService{
	
	@Autowired
	private PlaceViewRepo placeViewRepo;
	
	public List<PlaceVO> getAllPlaces(HashMap map){
		return placeViewRepo.getAllPlaces(map);
	}
	
//	public List<PlaceVO> getPlaceByFilter(int theme_id){
//		return placeViewRepo.getPlaceByFilter(theme_id);
//	}
	
	public int updateViewCnt(int theme_id) {
		return placeViewRepo.updateViewCnt(theme_id);
	}
	
	public PlaceVO getPlaceByDestId(int dest_id) {
		return placeViewRepo.getPlaceByDestId(dest_id);
	}
	
	 @Override
	    public List<PlaceVO> getRandomTop5Places() {
	        return placeViewRepo.getRandomTop5Places(); 
	    }

	
}
