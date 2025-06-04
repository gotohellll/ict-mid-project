package com.midproject.tripin.controller;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.ReviewVO;
import com.midproject.tripin.service.PlaceViewService;
import com.midproject.tripin.service.ReviewService;

@Controller
public class MainPageController {

    @Autowired
    private PlaceViewService placeViewService;

    @Autowired
    private ReviewService reviewService;  // ★ 리뷰 서비스 주입

    // 기상청 서비스 키 (실제 키로 교체)
    private final String serviceKey = "zN45JM7OAXI87vMwdJTfpW5sL25TQ6E1AQ5RZ6lYAGahXZg2Aqeu9I04fGg/7Oyc5x21dHHMGT9tRRVMePPLpA==";

    @GetMapping("/randomDestinations")
    @ResponseBody
    public List<PlaceVO> getRandomDestinations() {
        return placeViewService.getRandomTop5Places();
    }

    @GetMapping("/mainpage")
    public String mainPage(Model model) {
        System.out.println("MainPageController: /mainpage 요청 진입");

        // 1) 날씨 정보 가져오기
        try {
            String baseDate = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String baseTime = getRecentBaseTime();

            List<Map<String, String>> locations = Arrays.asList(
                Map.of("name", "서울", "nx", "60", "ny", "127"),
                Map.of("name", "부산", "nx", "98", "ny", "76"),
                Map.of("name", "강원", "nx", "92", "ny", "131"),
                Map.of("name", "인천", "nx", "55", "ny", "124"),
                Map.of("name", "대구", "nx", "89", "ny", "90"),
                Map.of("name", "울산", "nx", "102", "ny", "84"),
                Map.of("name", "광주", "nx", "58", "ny", "74"),
                Map.of("name", "제주", "nx", "52", "ny", "38")
            );

            RestTemplate restTemplate = new RestTemplate();
            List<Map<String, String>> weatherList = new ArrayList<>();

            for (Map<String, String> loc : locations) {
                String nx = loc.get("nx");
                String ny = loc.get("ny");
                String regionName = loc.get("name");

                String url = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"
                        + "?serviceKey=" + serviceKey
                        + "&numOfRows=10&pageNo=1&dataType=JSON"
                        + "&base_date=" + baseDate
                        + "&base_time=" + baseTime
                        + "&nx=" + nx + "&ny=" + ny;

                try {
                    String result = restTemplate.getForObject(url, String.class);
                    JSONObject jsonResponse = new JSONObject(result);

                    String resultCode = jsonResponse
                            .getJSONObject("response")
                            .getJSONObject("header")
                            .getString("resultCode");
                    if (!"00".equals(resultCode)) {
                        weatherList.add(createDefaultWeather(regionName, "-", "-", "정보 없음", "정보 없음"));
                        continue;
                    }

                    JSONArray items = jsonResponse
                            .getJSONObject("response")
                            .getJSONObject("body")
                            .getJSONObject("items")
                            .getJSONArray("item");

                    Map<String, String> weather = new HashMap<>();
                    weather.put("region", regionName);
                    weather.put("temp", "N/A");
                    weather.put("humidity", "N/A");
                    weather.put("pty", "정보 없음");
                    weather.put("sky", "정보 없음");

                    for (int i = 0; i < items.length(); i++) {
                        JSONObject item = items.getJSONObject(i);
                        String category = item.getString("category");
                        String value = item.optString("obsrValue", "N/A");
                        switch (category) {
                            case "T1H":
                                weather.put("temp", value);
                                break;
                            case "REH":
                                weather.put("humidity", value);
                                break;
                            case "PTY":
                                weather.put("pty", getPtyText(value));
                                break;
                            case "SKY":
                                weather.put("sky", getSkyText(value));
                                break;
                        }
                    }

                    weatherList.add(weather);

                } catch (Exception e) {
                    weatherList.add(createDefaultWeather(regionName, "오류", "오류", "오류", "오류"));
                }
            }

            model.addAttribute("weatherList", weatherList);

        } catch (Exception e) {
            model.addAttribute("weatherList", new ArrayList<>());
            model.addAttribute("weatherError", "날씨 정보를 가져오는 데 실패했습니다.");
        }

        // 2) 랜덤 리뷰 가져와서 모델에 담기 ★
		
		  List<ReviewVO> randomReviews = reviewService.getRandomReviews(); 
		  if (randomReviews == null) {
		  randomReviews = Collections.emptyList(); 
		  } 
		  System.out.println("▶ 리뷰 개수: " +randomReviews.size()); 
		  model.addAttribute("randomReviews", randomReviews);
		 

        return "mainpage";
    }

    // ───────────────────────────────────────────────────────────────────
    // helper methods
    // ───────────────────────────────────────────────────────────────────

    private String getRecentBaseTime() {
        LocalTime now = LocalTime.now();
        int hour = now.getHour();
        if (now.getMinute() < 45) {
            hour = (hour == 0) ? 23 : hour - 1;
        }
        return String.format("%02d00", hour);
    }

    private String getPtyText(String code) {
        if (code == null || code.equals("N/A")) return "정보 없음";
        switch (code) {
            case "0": return "맑음";
            case "1": return "비";
            case "2": return "비/눈";
            case "3": return "눈";
            case "4": return "소나기";
            case "5": return "빗방울";
            case "6": return "빗방울눈날림";
            case "7": return "눈날림";
            default: return "기타(" + code + ")";
        }
    }

    private String getSkyText(String code) {
        if (code == null || code.equals("N/A")) return "정보 없음";
        switch (code) {
            case "1": return "맑음";
            case "3": return "구름많음";
            case "4": return "흐림";
            default: return "기타(" + code + ")";
        }
        
        
    }
    

    private Map<String, String> createDefaultWeather(
            String region, String temp, String humidity, String pty, String sky) {
        Map<String, String> w = new HashMap<>();
        w.put("region", region);
        w.put("temp", temp);
        w.put("humidity", humidity);
        w.put("pty", pty);
        w.put("sky", sky);
        return w;
    }
}
