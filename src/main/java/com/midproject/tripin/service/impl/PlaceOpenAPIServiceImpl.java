package com.midproject.tripin.service.impl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.stream.Collectors;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.PlaceDestThemesVO;
import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.repositiory.PlaceOpenAPIRepo;
import com.midproject.tripin.service.PlaceOpenAPIService;
import com.midproject.tripin.util.PlaceThemeSort;



@Service("placeOpenAPIService")
public class PlaceOpenAPIServiceImpl implements PlaceOpenAPIService{
	//로그 출력
	private static final Logger logger = LoggerFactory.getLogger(PlaceOpenAPIServiceImpl.class);
	//api값 db 최대 저장 갯수
	private static final int MAX_SAVED_COUNT = 100;
	//api요청 시 한 페이지 몇 개 데이터 가져올지 
	private static final int DEFAULT_NUM_OF_ROWS = 10;
	private static final int MAX_PAGES = 10;
	
	@Autowired
	private PlaceOpenAPIRepo placeOpenAPIRepo;


	private final String serviceKey = "It/GnlGdSEN8rTI9utdTTht/odchebqCirUx8t7QCttJazG+r1gS/frN6Ku1kIdVfr3Carf+PVow7NpHVG5jpg==";
	private final String encodedServiceKey = URLEncoder.encode(serviceKey, StandardCharsets.UTF_8);
	
	//api에서 여행지 데이터 가져와서 DB로 저장
	public int fetchAndSavePlaces() {
		//지금까지 저장한 여행지 개수 카운트하는 변수
		int totalSavedCount = 0;
		//지역 코드
		int[] areaCodes = {1,2,3,4,5,6,7,8,31,32,33,34,35,36,37,38,39};
		// 12관광지, 14행사, 15축제, 28레저, 32숙박, 38쇼핑, 39음식
		int[] contentTypes = {12, 14, 15, 28, 32, 38, 39};

		//지역x콘텐츠타입 조합으로 데이터 로딩
		try {
			for(int area : areaCodes) {
				for (int contentType : contentTypes) {
					int savedCount = 0;
					savedCount = processContentType(area, contentType, savedCount);
												//해당지역, 콘텐츠타입에 대한 api호출, 데이터 저장 실행
					//저장한 데이터 수가 max_saved_count 이상이면 조기 종료
					if (savedCount >= MAX_SAVED_COUNT) return savedCount;
				}
			}
		} catch (Exception e) {
			logger.error("Error fetching and saving places", e);
		}
		//모든 처리가 끝나거나 조기 종료되면 저장한 장소 개수 반환
		return totalSavedCount;
	};
	
	//지역, 콘텐츠타입에 대해 여러 페이지의 데이터를 불러와 저장
	private int processContentType(int area, int contentType, int savedCount) {
		//api의 페이지 번호
		int pageNo = 1;
		
		//저장 개수가 max_saved_count보다 적고 PageNo가 max_pages보다 작거나 같을 때만 api요청 반복 
		while (savedCount < MAX_SAVED_COUNT && pageNo <= MAX_PAGES) {
			try {
				//fetchFromAPI메서드 호출 : 해당 지역,타입,페이지의 JSON응답 받아옴 
				String apiResponse = fetchFromAPI(area, contentType, pageNo);
				if (apiResponse == null) break;
				
				//JSON구조 중 body 추출 
				JSONObject body = new JSONObject(apiResponse)
					.getJSONObject("response")
					.optJSONObject("body");
				if (body == null) break;
				
				//JSON 파싱해서 DB에 저장하는 함수
				savedCount = processAPIResponse(body, savedCount);
				//전체 아이템 개수
				int totalCount = body.optInt("totalCount",0);
				//전체 페이지 수 계산
				int totalPages = (int)Math.ceil((double) totalCount / DEFAULT_NUM_OF_ROWS);
				
				//현재 페이지가 마지막 페이지면 반복 중단
				if (pageNo >= totalPages) break;
				pageNo++;
				
			} catch (Exception e) {
				logger.error("Error processing contentType={} area={}", contentType, area);
				logger.error("Exception stack trace:", e);
			}
		}
		return savedCount;
	}
	
	//지정된 지역,콘텐츠타입,페이지번호에 해당하는 api요청 보내고 응답(JSON문자열)받아오는 기능
	private String fetchFromAPI (int area, int contentType, int pageNo) {
		//buildAPIUrl메서드 호출해 api요청용 url문자열 생성
		String urlStr = buildAPIUrl(area, contentType, pageNo);
		
		
		try(BufferedReader br = new BufferedReader(
				new InputStreamReader(createConnection(urlStr).getInputStream())) ){
			return br.lines().collect(Collectors.joining());
		}catch (IOException e){
			logger.error("Error fetching from API", e);
			return null;
		}
	};
	
	//api요청을 위한 네트워크 설정
	private HttpURLConnection createConnection (String urlStr) throws IOException{
		URL url = new URL(urlStr);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setRequestMethod("GET");
		return conn;
	};
	
	//api요청을 위한 URL문자열 생성
	private String buildAPIUrl(int area, int contentType, int pageNo) {
		return String.format("https://apis.data.go.kr/B551011/KorService2/areaBasedList2"
				+ "?serviceKey=%s"
	            + "&numOfRows=%d"
	            + "&pageNo=%d"
	            + "&MobileOS=ETC"
	            + "&MobileApp=Tripin"
	            + "&contentTypeId=%d"
	            + "&areaCode=%d"
	            + "&arrange=D"
	            + "&_type=json", 
	            encodedServiceKey, DEFAULT_NUM_OF_ROWS, pageNo, contentType, area);
	};
	
	//JSON응답 파싱해 db에 저장할 데이터 추출 & db중복검사 후 저장
	private int processAPIResponse(JSONObject body, int savedCount) {
		//응답구조에서 items객체 추출
		JSONObject itemsObj = body.optJSONObject("items");
		if (itemsObj == null) return savedCount;
		
		//item배열 추출
		JSONArray items = itemsObj.optJSONArray("item");
		if (items == null) return savedCount;
		
		//배열 순회하며 하나씩 추출 
		for (int i=0; i < items.length() && savedCount < MAX_SAVED_COUNT; i++) {
			//i번째 관광지 JSON객체 추출
			JSONObject obj = items.getJSONObject(i);
			//PlaceVO 객체로 변환
			PlaceVO place = createPlaceFromJson(obj);
			
			//DB 중복 검사
			if(placeOpenAPIRepo.selectPlaceById(place.getDest_id()) == null) {
				savePlaceAndThemes(place);
				savedCount++;
			}
		}
		return savedCount;
	};
	
	//api에서 받은 JSON데이터를 PlaceVO 객체로 변환
	private PlaceVO createPlaceFromJson(JSONObject obj) {
		//PlaceVO 객체 생성 
		PlaceVO place = new PlaceVO();
		place.setDest_id		(obj.getInt		("contentid"      ));
        place.setDest_name		(obj.getString	("title"		  ));
        place.setDest_type		(obj.optString	("cat2"        ,""));
        place.setFull_address	(obj.optString	("addr1"       ,""));
        place.setContact_num	(obj.optString	("tel"         ,""));
        place.setRepr_img_url	(obj.optString	("firstimage"  ,""));
        place.setOrig_json_data	(obj.toString	(				  ));
        place.setCreated_time	(obj.optString	("createdtime" ,""));
        place.setContent_type	(obj.optInt		("contenttypeid"  ));
        place.setCat1			(obj.optString	("cat1"		   ,""));
        place.setCat2			(obj.optString	("cat2"		   ,""));
        place.setCat3			(obj.optString	("cat3"        ,""));
		
        //JSON 정보를 담은 객체 반환
		return place;
	};
	
	//테마정보 매핑
	private void savePlaceAndThemes(PlaceVO place) {
		try {
			//장소 정보 dests테이블(db)에 저장 
			placeOpenAPIRepo.insertPlace(place);
			//테마명 리스트 생성
			List<String> themeNames = PlaceThemeSort.mapTheme(place.getCat1(), place.getCat2(), place.getCat3());
			
			for(String theme : themeNames) {
				//테마명을 테마테이블에서 찾아 theme_id 조회
				Integer theme_id = placeOpenAPIRepo.selectThemeIdByName(theme);
				if(theme_id != null) {
					PlaceDestThemesVO vo = new PlaceDestThemesVO();
					vo.setDest_id(place.getDest_id());
					vo.setTheme_id(theme_id);
					placeOpenAPIRepo.insertDestTheme(vo);
				}
			}
			
		}catch(Exception e){
			logger.error("Error saving place and themes",e);
		}
	}
					
	//***********************************************************
	//contentid별 여행지 상세정보 불러오기(db저장 x)
	private static final String DETAIL_API_URL = "https://apis.data.go.kr/B551011/KorService2/detailIntro2";
	
	//컨텐츠타입
	private static final int CONTENT_TYPE_TOUR = 12;
	private static final int CONTENT_TYPE_CULTURE = 14;
    private static final int CONTENT_TYPE_FESTIVAL = 15;
    private static final int CONTENT_TYPE_LEPORTS = 28;
    private static final int CONTENT_TYPE_LODGING = 32;
    private static final int CONTENT_TYPE_SHOPPING = 38;
    private static final int CONTENT_TYPE_FOOD = 39;
    
    
    //특정 dest_id와 content_type으로 api에서 상세정보 요청
	@Override
	public JSONObject getPlaceDetail(int dest_id, int content_type) {
		logger.info("getPlaceDetail 서비스 메소드 진입!");
		try {
			//api응답 받아오기
			String apiResponse = fetchDetailFromAPI(dest_id, content_type);
			if(apiResponse == null) {
				logger.error("Failed to fetch details for dest_id: {}, content_type: {}", dest_id, content_type);
				return null;
			}
			//JSON파싱
			JSONObject item = parseApiResponse(apiResponse);
			if(item == null) {
				logger.error("Failed to parse API response for dest_id: {}", dest_id);
				return null;
			}
			//결과 생성 후 반환
			return createDetailResult(item, content_type);
		}catch(Exception e) {
			logger.error("Error getting place detail for dest_id: {}, content_type: {}", dest_id, content_type);
			logger.error("Exception stack trace:", e);
			
			return null;
		}
	};
	
	//여행지 상세정보 api 호출 , JSON 응답 문자열 받아옴
	private String fetchDetailFromAPI(int dest_id, int content_type) {
		//api 요청 URL 생성
		String urlStr = buildDetailApiUrl(dest_id, content_type);
		
		//api요청 및 응답 읽기
		try (BufferedReader br = new BufferedReader(
				new InputStreamReader(createConnection(urlStr).getInputStream(), StandardCharsets.UTF_8))){
			//응답 문자열로 변환
			return br.lines().collect(Collectors.joining());
		}catch(IOException e) {
			logger.error("Error fetching detail from API: {}", urlStr, e);
			return null;
		}
	};
	
	//api 상세정보 조회 URL을 요청 파라미터와 조립해서 반환
	private String buildDetailApiUrl(int dest_id, int content_type) {
		try {
			return String.format("%s?serviceKey=%s&MobileOS=ETC&MobileApp=Tripin&contentId=%d&contentTypeId=%d&_type=json"
					,DETAIL_API_URL
					,URLEncoder.encode(serviceKey, StandardCharsets.UTF_8.name())
					,dest_id
					,content_type);
		} catch (UnsupportedEncodingException e) {
			logger.error("Error encoding service key", e);
			return null;
		}
	};
	
	//JSON 응답 문자열 파싱
	private JSONObject parseApiResponse(String apiResponse) {
		try {
			//JSON파싱 체인
			return new JSONObject(apiResponse)
					.getJSONObject("response")
					.getJSONObject("body")
					.getJSONObject("items")
					.getJSONArray("item")
					.getJSONObject(0);
		} catch(Exception e) {
			logger.error("Error parsing API response: {}", apiResponse, e);
			return null;
		}
	};
    
	//컨텐츠 타입별 상세정보 필드 가공
	private JSONObject createDetailResult(JSONObject item, int content_type) {
		//새로운 JSON객체 result생성
        JSONObject result = new JSONObject();
        result.put("contenttypeid", content_type);
        
        //타입에 따른 분기
        try {
            switch (content_type) {
                case CONTENT_TYPE_TOUR:
                    addTourDetails(result, item);
                    break;
                case CONTENT_TYPE_CULTURE:
                    addCultureDetails(result, item);
                    break;
                case CONTENT_TYPE_FESTIVAL:
                    addFestivalDetails(result, item);
                    break;
                case CONTENT_TYPE_LEPORTS:
                    addLeportsDetails(result, item);
                    break;
                case CONTENT_TYPE_LODGING:
                    addLodgingDetails(result, item);
                    break;
                case CONTENT_TYPE_SHOPPING:
                    addShoppingDetails(result, item);
                    break;
                case CONTENT_TYPE_FOOD:
                    addFoodDetails(result, item);
                    break;
                default:
                    result.put("overview", item.optString("overview", ""));
            }
            logger.debug("Final detail result for JSP: {}", result.toString(2));
            return result;
        } catch (Exception e) {
            logger.error("Error creating detail result for content_type: {}", content_type, e);
            return null;
        }
    };
	
	//관광지12
	private void addTourDetails(JSONObject result, JSONObject item) {
        result.put("infocenter"		, item.optString("infocenter" 		, "")) //문의
              .put("usetime"   		, item.optString("usetime"	 		, ""))	//이용시간
              .put("usefee"    		, item.optString("usefee"	 		, ""))	//요금
              .put("restdate" 		, item.optString("restdate"	 		, ""))	//쉬는날
              .put("parking"   		, item.optString("parking"	 		, ""))	//주차시설
              .put("useseason"		, item.optString("useseason"	 	, ""))	//이용시기
              .put("age"       		, item.optString("expagerange"		, ""))	//체험가능연령
              .put("expguide"  		, item.optString("expguide"	 		, ""))	//체험안내
              .put("opendate"  		, item.optString("opendate"	 		, ""));//개장일
    };
	
	//문화시설14
    private void addCultureDetails(JSONObject result, JSONObject item) {
    	result.put("infocenter"		, item.optString("infocenterculture" , "")) //문의	
        	  .put("usetime"		, item.optString("usetimeculture"	 , "")) //이용시간
              .put("usefee"			, item.optString("usefeeculture"	 , "")) //요금
              .put("restdate"		, item.optString("restdateculture"	 , "")) //쉬는날
              .put("parking"		, item.optString("parkingculture"	 , "")) //주차시설
              .put("spendtime"		, item.optString("spendtime"		 , ""));//관람소요시간
    };
    
    //축제15
    private void addFestivalDetails(JSONObject result, JSONObject item) {
    	result.put("infocenter"		, item.optString("bookingplace"		 , "")) //예매처
    	      .put("usetime"		, item.optString("playtime"			 , "")) //공연시간
    	      .put("usefee"			, item.optString("usetimefestival"	 , "")) //이용요금
    		  .put("eventplace"		, item.optString("eventplace"		 , "")) //행사장소
			  .put("eventstartdate"	, item.optString("eventstartdate"	 , "")) //행사시작일
	          .put("eventenddate"	, item.optString("eventenddate"		 , "")) //행사종료일
	          .put("placeinfo"		, item.optString("placeinfo"		 , "")) //행사장위치안내
	          .put("sponsor"		, item.optString("sponsor1"			 , "")) //주최자정보
	          .put("program"		, item.optString("program"			 , "")) //행사프로그램
	          .put("spendtime"		, item.optString("spendtimefestival" , "")) //관람소요시간
	          .put("homepage"		, item.optString("eventhomepage"	 , ""));//행사홈페이지
    };
    
    //레저28
    private void addLeportsDetails(JSONObject result, JSONObject item) {
    	result.put("infocenter"		, item.optString("infocenterleports ", "")) //문의
	    	  .put("usetime"		, item.optString("usetimeleports"	 , "")) //이용시간
	    	  .put("usefee"			, item.optString("usefeeleports"	 , "")) //입장료
	    	  .put("restdate"		, item.optString("restdateleports"	 , "")) //쉬는날
	          .put("openperiod"		, item.optString("openperiod"		 , "")) //개장기간
	          .put("reservation"	, item.optString("reservation"		 , "")) //예약안내
	          .put("accomcount"		, item.optString("accomcountleports" , "")) //수용인원
	          .put("age"			, item.optString("expagerangeleports", ""));//체험가능연령
    };
    
    //숙박32
    private void addLodgingDetails(JSONObject result, JSONObject item) {
    	result.put("infocenter"		, item.optString("infocenterlodging ", "")) //문의	        
	    	  .put("checkintime"	, item.optString("checkintime"		 , "")) //입실시간
	    	  .put("checkouttime"	, item.optString("checkouttime"		 , "")) //퇴실시간
	    	  .put("roomtype"		, item.optString("roomtype"			 , "")) //객실유형
	          .put("roomcount"		, item.optString("roomcount"		 , "")) //객실수
	          .put("reservationurl"	, item.optString("reservationurl"	 , "")) //예약url
	          .put("accomcount"		, item.optString("accomcountlodging" , "")) //수용가능인원
	          .put("barbecue"		, item.optString("barbecue"			 , "")) //바베큐장여부
	          .put("refund"			, item.optString("refuntregulation"	 , ""));//환불규정
    };
    
    //쇼핑38
    private void addShoppingDetails(JSONObject result, JSONObject item) {
    	result.put("infocenter"		, item.optString("infocentershopping", "")) //문의
	    	  .put("usetime"		, item.optString("opentime"			 , "")) //영업시간
	    	  .put("restdate"		, item.optString("restdateshopping"	 , "")) //쉬는날
	    	  .put("saleitem"		, item.optString("saleitem"			 , "")) //판매품목
	          .put("parking"		, item.optString("parkingshopping"	 , ""));//주차시설
    };
    
    //음식39
    private void addFoodDetails(JSONObject result, JSONObject item) {
    	result.put("usetime"	 	, item.optString("opentimefood"		 , "")) //영업시간o
	    	  .put("restdatefood"	, item.optString("restdatefood"		 , "")) //쉬는날o
	    	  .put("firstmenu"		, item.optString("firstmenu"		 , "")) //대표메뉴
	          .put("treatmenu"	 	, item.optString("treatmenu"		 , "")) //취급메뉴
	          .put("parking"	 	, item.optString("parkingfood"		 , "")) //주차시설
	          .put("packing"	 	, item.optString("packing"			 , "")) //포장가능
	          .put("seat"		 	, item.optString("seat"				 , "")) //좌석수
	          .put("reservation" 	, item.optString("reservationfood"	 , ""));//예약안내o
    };
	
}
