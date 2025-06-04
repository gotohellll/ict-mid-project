package com.midproject.tripin.repositiory;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.PlaceVO;

@Mapper
public interface PlaceRepo {
	 List<PlaceVO> selectPlaceByUser(Integer user_id);
	 void bookmarkPlace(Map<String, Object> paramMap);
	 void deleteBookmark(Map<String, Object> paramMap);
}
