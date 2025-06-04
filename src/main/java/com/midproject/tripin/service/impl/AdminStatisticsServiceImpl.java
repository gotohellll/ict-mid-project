package com.midproject.tripin.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.repositiory.UserRepo;

@Service
public class AdminStatisticsServiceImpl {
	 
	@Autowired
	  private UserRepo userRepo; 
	 
	 private static final String[] LOGIN_PROVIDER_CHART_COLORS = {
		        "rgba(75, 192, 192, 0.7)",  // 홈페이지 가입 (청록)
		        "rgba(255, 222, 0, 0.8)",  // 카카오 로그인 (노랑)
		        "rgba(234, 67, 53, 0.7)",   // 구글 로그인 (빨강)
		        "rgba(153, 102, 255, 0.7)", // 기타1 (보라)
		        "rgba(255, 159, 64, 0.7)"   // 기타2 (주황)
		    };

		    public List<Map<String, Object>> getUserOriginStatsForChart() {
		        List<Map<String, Object>> dbData = userRepo.getUserCountByLoginProvider();
		        List<Map<String, Object>> chartData = new ArrayList<>();

		        if (dbData != null) {
		            int colorIndex = 0;
		            for (Map<String, Object> row : dbData) {
		                Map<String, Object> item = new HashMap<>();
		                // MyBatis가 반환한 Map의 키는 DB 컬럼명 또는 SQL 별칭을 따름 (대소문자 주의)
		                // 위 매퍼에서는 "label", "value"로 별칭을 주었음
		                String label = (String) row.get("label"); // 또는 row.get("LOGIN_PROVIDER")
		                // COUNT(*) 결과는 BigDecimal 등으로 올 수 있으므로 Number로 받고 intValue() 사용
		                int value = row.get("value") != null ? ((Number) row.get("value")).intValue() : 0;

		                // LOGIN_PROVIDER 값에 따라 레이블 한글화 (선택적)
		                if ("NORMAL".equalsIgnoreCase(label)) {
		                    item.put("label", "홈페이지 가입");
		                } else if ("KAKAO".equalsIgnoreCase(label)) {
		                    item.put("label", "카카오 로그인");
		                } else if ("GOOGLE".equalsIgnoreCase(label)) {
		                    item.put("label", "구글 로그인");
		                } else {
		                    item.put("label", label != null ? label : "기타");
		                }

		                item.put("value", value);
		                item.put("color", LOGIN_PROVIDER_CHART_COLORS[colorIndex % LOGIN_PROVIDER_CHART_COLORS.length]);
		                chartData.add(item);
		                colorIndex++;
		            }
		        }
		        return chartData;
		    }
}
