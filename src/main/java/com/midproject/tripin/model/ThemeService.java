package com.midproject.tripin.model;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.repositiory.ThemeRepo;

@Service
public class ThemeService {
	
	@Autowired
	private ThemeRepo themeRepo;

	public List<ThemeVO> getThemeDateForChart(){
		return themeRepo.getThemeCountsForChart();
	}
}
