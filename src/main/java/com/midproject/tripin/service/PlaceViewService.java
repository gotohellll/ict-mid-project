package com.midproject.tripin.service;

import java.util.HashMap;
import java.util.List;

import com.midproject.tripin.model.PlaceVO;

public interface PlaceViewService {
	List<PlaceVO> getAllPlaces(HashMap map);

//	List<PlaceVO> getPlaceByFilter(int theme_id);
	
	int updateViewCnt(int theme_id);
	
	PlaceVO getPlaceByDestId(int dest_id);
	
	List<PlaceVO> getRandomTop5Places(); 
	
}
