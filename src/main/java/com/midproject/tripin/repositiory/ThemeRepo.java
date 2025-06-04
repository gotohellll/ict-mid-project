package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.ThemeVO;

@Mapper
public interface ThemeRepo {
	 List<ThemeVO> getThemeCountsForChart();
}
