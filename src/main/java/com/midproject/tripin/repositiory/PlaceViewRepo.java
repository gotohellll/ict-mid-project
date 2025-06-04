package com.midproject.tripin.repositiory;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.PlaceVO;

@Mapper
public interface PlaceViewRepo {
	public List<PlaceVO> getAllPlaces(HashMap map);
	
//	public List<PlaceVO> getPlaceByFilter(int theme_id);
	
	public int updateViewCnt(int theme_id);
	
	public PlaceVO getPlaceByDestId(int dest_id);
	
	List<PlaceVO> getRandomTop5Places();

	
}
