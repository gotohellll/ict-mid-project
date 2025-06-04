package com.midproject.tripin.util;

import java.util.ArrayList;
import java.util.List;

public class PlaceThemeSort {
	public static List<String> mapTheme(String cat1, String cat2, String cat3) {
		List<String> themes = new ArrayList<>();
		
		if("A01".equals(cat1)) themes.add("자연"); //1
		if ("A02".equals(cat1) && "A0201".equals(cat2)) themes.add("문화"); //2
		if ("A02".equals(cat1) && "A0203".equals(cat2)) themes.add("문화"); //2
		if ("A02".equals(cat1) && "A0204".equals(cat2)) themes.add("문화"); //2
		if ("A02".equals(cat1) && "A0206".equals(cat2)) themes.add("문화"); //2
		if ("A02".equals(cat1) && "A0208".equals(cat2)) themes.add("문화"); //2
        if ("A02".equals(cat1) && "A0202".equals(cat2)) themes.add("레저"); //3
        if ("A03".equals(cat1)) themes.add("레저"); //3
        if ("A05".equals(cat1)) themes.add("맛집"); //4
        if ("B02".equals(cat1)) themes.add("숙소"); //5
        if ("A04".equals(cat1)) themes.add("쇼핑"); //6
        if ("A02".equals(cat1) && "A0207".equals(cat2)) themes.add("축제"); //7
		
		return themes;
	}
}
