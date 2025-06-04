package com.midproject.tripin.service;

import java.util.List;
import java.util.Map;

import com.midproject.tripin.model.PlaceVO;

public interface PlaceService {
	 List<PlaceVO> selectPlaceByUser(Integer user_id);
	 void bookmarkPlace(Map<String, Object> paramMap);
	 void deleteBookmark(Map<String, Object> paramMap);
}
