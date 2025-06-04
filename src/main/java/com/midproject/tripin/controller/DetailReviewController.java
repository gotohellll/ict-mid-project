package com.midproject.tripin.controller;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.ReviewVO;
import com.midproject.tripin.model.UserVO;
import com.midproject.tripin.service.PlaceOpenAPIService;
import com.midproject.tripin.service.PlaceViewService;
import com.midproject.tripin.service.impl.DetailReviewServiceImpl;

@Controller
public class DetailReviewController {

    @Autowired
    private DetailReviewServiceImpl reviewService;
    
	@Autowired
	private PlaceOpenAPIService placeOpenAPIService;
	
	@Autowired
	private PlaceViewService placeViewService;

    // 여행지 검색 (AJAX)
    @GetMapping("/searchPlace")
    @ResponseBody
    public List<PlaceVO> searchPlace(@RequestParam("keyword") String keyword) {
    	System.out.println("======= /searchPlace Controller 진입, keyword: " + keyword + " =======");
        System.out.println("검색어: " + keyword);
        return reviewService.searchPlacesByKeyword(keyword);
    }

	/*
	 * // 여행지 상세 페이지 진입
	 * 
	 * @GetMapping("/destinationdetail") public String destinationDetail(
	 * 
	 * @RequestParam(value = "dest_id", required = false) Integer dest_id,
	 * 
	 * @RequestParam(value = "name", required = false) String name,
	 * 
	 * @RequestParam(value = "contentId", required = false) String contentId, Model
	 * model,HttpSession session,HttpServletRequest request) {
	 * 
	 * 
	 * UserVO user = (UserVO) session.getAttribute("user");
	 * model.addAttribute("user", user);
	 * 
	 * PlaceVO place2 = placeViewService.getPlaceByDestId(dest_id);
	 * 
	 * if(place2 == null) { System.out.println("error"+dest_id); }
	 * 
	 * JSONObject detail = placeOpenAPIService.getPlaceDetail( place2.getDest_id(),
	 * place2.getContent_type());
	 * 
	 * Map<String, Object> detailMap = new HashMap<>(); for (String key :
	 * detail.keySet()) { detailMap.put(key, detail.get(key)); };
	 * 
	 * 
	 * model.addAttribute("detail", detailMap);
	 * 
	 * if (dest_id != null) { PlaceVO place =
	 * reviewService.getPlaceByDestId(dest_id); if (place == null) {
	 * model.addAttribute("reviewList", List.of()); model.addAttribute("dest_id",
	 * 0); model.addAttribute("place", null); return "destinationdetail"; }
	 * List<ReviewVO> reviews = reviewService.getReviewsByDestId(dest_id);
	 * processRatings(reviews); model.addAttribute("reviewList", reviews);
	 * model.addAttribute("dest_id", dest_id); model.addAttribute("place", place);
	 * model.addAttribute("name", place.getDest_name()); return "destinationdetail";
	 * }
	 * 
	 * if (name == null || contentId == null || name.trim().isEmpty() ||
	 * contentId.trim().isEmpty()) { model.addAttribute("reviewList", List.of());
	 * model.addAttribute("dest_id", 0); model.addAttribute("place", null); return
	 * "destinationdetail"; }
	 * 
	 * int ensured_dest_id = reviewService.ensureDestinationExists(name, contentId);
	 * PlaceVO place = reviewService.getPlaceByDestId(ensured_dest_id);
	 * List<ReviewVO> reviews = reviewService.getReviewsByDestId(ensured_dest_id);
	 * processRatings(reviews); model.addAttribute("reviewList", reviews);
	 * model.addAttribute("dest_id", ensured_dest_id); model.addAttribute("place",
	 * place);
	 * 
	 * return "destinationdetail"; }
	 */
    
    @GetMapping("/destinationdetail") // 또는 /destinationdetail
    public String destinationDetail(
            @RequestParam(value = "dest_id", required = false) Integer destId, // Wrapper 타입으로 받아 null 처리 용이
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "contentId", required = false) String contentId, // API의 contentId는 보통 숫자형
            Model model, HttpSession session) { // HttpServletRequest는 HttpSession으로 대체 가능

        // 1. 세션에서 사용자 정보 가져오기 (필요한 경우)
        UserVO currentUser = (UserVO) session.getAttribute("loggedInUser"); // "loggedInUser" 또는 실제 세션 키
        model.addAttribute("currentUser", currentUser); // JSP에서 ${currentUser.xxx} 로 사용

        PlaceVO place = null;
        Map<String, Object> detailMap = new HashMap<>();

        // 2. dest_id가 우선적으로 사용됨
        if (destId != null && destId > 0) {
            place = placeViewService.getPlaceByDestId(destId);
        }
        // dest_id가 없거나, dest_id로 조회가 안됐고, name과 contentId가 있다면 그걸로 시도
        else if (name != null && !name.trim().isEmpty() && contentId != null && !contentId.trim().isEmpty()) {
            try {
                // contentId가 숫자형태의 문자열이라고 가정, 실제 API 스펙 확인 필요
                int ensuredDestId = reviewService.ensureDestinationExists(name, contentId); // contentId를 int로 변환
                place = placeViewService.getPlaceByDestId(ensuredDestId);
            } catch (NumberFormatException e) {
                model.addAttribute("errorMessage", "잘못된 contentId 형식입니다.");
            }
        }

        // 3. place 객체가 정상적으로 조회되었는지 확인
        if (place == null) { // dest_id 필드명 확인
            model.addAttribute("errorMessage", "요청하신 여행지 정보를 찾을 수 없습니다.");
            model.addAttribute("place", null);
            model.addAttribute("detail", detailMap); // 빈 맵 전달
            model.addAttribute("reviewList", List.of()); // 빈 리스트 전달
            return "destinationdetail";
        }

        model.addAttribute("place", place);
        model.addAttribute("name", place.getDest_name()); // JSP에서 ${name}으로도 사용 가능하게 (중복될 수 있음)
        model.addAttribute("dest_id", place.getDest_id()); // JSP에서 ${dest_id}로도 사용 가능하게
        Integer placeContentTypeInt = place.getContent_type();
  
        if (placeContentTypeInt != null) {
            
            JSONObject detailJson = placeOpenAPIService.getPlaceDetail(place.getDest_id(), placeContentTypeInt); // dest_id도 int로

            if (detailJson != null) {
                for (String key : detailJson.keySet()) {
                    detailMap.put(key.toLowerCase(), detailJson.get(key)); // 키를 소문자로 변환하여 저장
                }
            }
        } else {
            
        }
        model.addAttribute("detail", detailMap);
 


        // 5. 리뷰 목록 조회
        List<ReviewVO> reviews = reviewService.getReviewsByDestId(place.getDest_id()); // dest_id를 int로
        processRatings(reviews); // 이 메소드가 정의되어 있어야 함
        model.addAttribute("reviewList", reviews);


        return "destinationdetail";
    }
    
    
    

    // 랜덤 해시태그 요청
    @GetMapping("/randomDestNames")
    @ResponseBody
    public List<String> getRandomDestNames() {
    	System.out.println("======= /random Controller 진입");
        return reviewService.getRandomDestNames(); 
    }

    //좋아요 토글
    @PostMapping("/toggleLike")
    @ResponseBody
    public ResponseEntity<String> toggleLike(
        @RequestParam("user_id") int user_id,
        @RequestParam("dest_id") int dest_id) {
        System.out.println("[TOGGLE] user_id = " + user_id + ", dest_id = " + dest_id);
        boolean liked = reviewService.isLikedByUser(user_id, dest_id);
        if (liked) {
            reviewService.deleteLike(user_id, dest_id);
            return ResponseEntity.ok("unliked");
        } else {
            reviewService.insertLike(user_id, dest_id);
            return ResponseEntity.ok("liked");
        }
    }

    // 리뷰 등록
    @PostMapping("/addReview")
    @ResponseBody
    public ResponseEntity<ReviewVO> addReview(
        //@RequestParam("userId") int userId,
    		 @RequestParam("dest_id") int dest_id,
    	        @RequestParam("rating") double rating,
    	        @RequestParam("content") String content,
    	        @RequestParam(value = "imageFiles", required = false) MultipartFile[] imageFiles,

        HttpServletRequest request,Model m, HttpSession session) {
    	
    	
    	UserVO user = (UserVO) session.getAttribute("user");
	    m.addAttribute("user", user);
	    Integer userId = user.getUser_id(); 
	    ReviewVO review = new ReviewVO();
        review.setUser_id(userId);
        review.setDest_id(dest_id);
        review.setRating(rating);
        review.setContent(content);

        StringBuilder pathBuilder = new StringBuilder();
        if (imageFiles != null) {
            for (MultipartFile file : imageFiles) {
                if (!file.isEmpty()) {
                    String saved = saveImage(file, request);
                    if (pathBuilder.length() > 0) pathBuilder.append(",");
                    pathBuilder.append(saved);
                }
            }
        }
        review.setImage_path(pathBuilder.toString());
        reviewService.insertReview(review);
        return ResponseEntity.ok(review);
    }


    // 리뷰 수정
    @PostMapping("/updateReview")
    @ResponseBody
    public ResponseEntity<String> updateReview(
    		 @RequestParam("review_id") int review_id,
    	        //@RequestParam("user_id") int user_id,
    	        @RequestParam("rating") double rating,
    	        @RequestParam("content") String content,
    	        @RequestParam(value = "image_path", required = false) String image_path,
        @RequestParam(value = "newImageFiles", required = false) MultipartFile[] newImageFiles,
        HttpServletRequest request,Model m, HttpSession session) {
    	
    	
    	UserVO user = (UserVO) session.getAttribute("user");
	    m.addAttribute("user", user);
	    Integer userId = user.getUser_id(); 
	    StringBuilder pathBuilder = new StringBuilder(image_path != null ? image_path : "");

        if (newImageFiles != null) {
            for (MultipartFile file : newImageFiles) {
                if (!file.isEmpty()) {
                    String saved = saveImage(file, request);
                    if (pathBuilder.length() > 0) pathBuilder.append(",");
                    pathBuilder.append(saved);
                }
            }
        }

        ReviewVO review = new ReviewVO();
        review.setReview_id(review_id);
        review.setUser_id(userId);
        review.setRating(rating);
        review.setContent(content);
        review.setImage_path(pathBuilder.toString());

        reviewService.updateReview(review);
        return ResponseEntity.ok("success");
    }


    // 리뷰 신고
    @PostMapping("/reportReview")
    @ResponseBody
    public ResponseEntity<String> reportReview(@RequestParam("review_id") int review_id, HttpSession session) {
        Object attr = session.getAttribute("reportedReviews");
        Set<Integer> reportedReviews = (attr instanceof Set<?>) ? (Set<Integer>) attr : new HashSet<>();

        if (reportedReviews.contains(review_id)) {
            return ResponseEntity.status(409).body("already_reported");
        }

        reviewService.incrementReportCount(review_id);
        reportedReviews.add(review_id);
        session.setAttribute("reportedReviews", reportedReviews);

        return ResponseEntity.ok("reported");
    }

    // 리뷰 삭제
    @PostMapping("/deleteReview")
    @ResponseBody
    public ResponseEntity<String> deleteReview(
    		@RequestParam("review_id") int review_id,Model m, HttpSession session
        //@RequestParam("userId") int userId
        ) {

    	
    	UserVO user = (UserVO) session.getAttribute("user");
	    m.addAttribute("user", user);
	    Integer userId = user.getUser_id(); 
        boolean deleted = reviewService.deleteReview(review_id, userId);
        return deleted ? ResponseEntity.ok("deleted") : ResponseEntity.status(403).body("unauthorized");
    }

    // 리뷰 목록 조회 (정렬 포함)
    @GetMapping("/getReviewsByDestId")
    @ResponseBody
    public List<ReviewVO> getReviewsByDestId(@RequestParam("dest_id") int dest_id,
                                             @RequestParam(value = "sort", defaultValue = "latest") String sort) {
        List<ReviewVO> reviews = reviewService.getReviewsByDestId(dest_id, sort);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSXXX");
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Seoul"));

        for (ReviewVO review : reviews) {
            double rating = review.getRating();
            int full = (int) rating;
            boolean half = (rating - full) >= 0.5;
            int empty = 5 - full - (half ? 1 : 0);
            review.setFull_stars(full);
            review.setHalf_star(half);
            review.setEmpty_stars(empty);

            if (review.getCreated_at() != null) {
                review.setCreated_at_str(sdf.format(review.getCreated_at()));
            }
        }

        return reviews;
    }

    // 내부 메서드: 이미지 저장
    private String saveImage(MultipartFile imageFile, HttpServletRequest request) {
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String uploadDir = request.getSession().getServletContext().getRealPath("/resources/uploads/");
                File dir = new File(uploadDir);
                if (!dir.exists()) dir.mkdirs();

                String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
                File savedFile = new File(uploadDir, fileName);
                imageFile.transferTo(savedFile);

                return "/resources/uploads/" + fileName;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    // 공통 유틸: 별점 계산
    private void processRatings(List<ReviewVO> reviews) {
        for (ReviewVO review : reviews) {
            double rating = review.getRating();
            int full = (int) rating;
            boolean half = (rating - full) >= 0.5;
            int empty = 5 - full - (half ? 1 : 0);
            review.setFull_stars(full);
            review.setHalf_star(half);
            review.setEmpty_stars(empty);
        }
    }
}