package com.midproject.tripin.repositiory;

import org.apache.ibatis.annotations.Mapper;
import com.midproject.tripin.model.PlaceDestThemesVO;
import com.midproject.tripin.model.PlaceVO;

@Mapper
public interface PlaceOpenAPIRepo {

	PlaceVO selectPlaceById(int dest_id);

	void insertPlace(PlaceVO place);

	Integer selectThemeIdByName(String themeName);

	void insertDestTheme(PlaceDestThemesVO vo);
	
	
}
