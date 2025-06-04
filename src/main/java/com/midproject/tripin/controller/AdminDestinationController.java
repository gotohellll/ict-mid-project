package com.midproject.tripin.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.midproject.tripin.model.AdminActionLogVO;
import com.midproject.tripin.model.AdminPlaceVO;
import com.midproject.tripin.model.AdminVO;
import com.midproject.tripin.service.impl.AdminActionLogService;
import com.midproject.tripin.service.impl.AdminPlaceServiceImpl;

@Controller
@RequestMapping("/admin/destinations")
public class AdminDestinationController {
	
	@Autowired
	private AdminPlaceServiceImpl placeService;
	
	@Autowired
    private AdminActionLogService activityLogService;
	
	
	private String saveImage(MultipartFile file, HttpServletRequest request) {
	    if (file == null || file.isEmpty()) {
	        return null;
	    }
	    String originalFilename = file.getOriginalFilename();
	    String extension = "";
	    if (originalFilename != null && originalFilename.lastIndexOf(".") != -1) {
	        extension = originalFilename.substring(originalFilename.lastIndexOf("."));
	    }
	    String savedFileName = UUID.randomUUID().toString() + extension;

	    HttpSession session = request.getSession(); // 세션 가져오기
	    if (session == null) {
	        System.err.println("saveImage: HttpSession is null. Cannot get ServletContext.");
	        return null; // 또는 예외 발생
	    }
	    ServletContext servletContext = session.getServletContext();
	    if (servletContext == null) {
	        System.err.println("saveImage: ServletContext is null.");
	        return null; // 또는 예외 발생
	    }

	    String uploadDirRelativePath = "/resources/uploads/destinations/"; // 웹 접근 가능 경로 기준
	    String uploadDirAbsolutePath = servletContext.getRealPath(uploadDirRelativePath);

	    File directory = new File(uploadDirAbsolutePath);
	    if (!directory.exists()) {
	        directory.mkdirs();
	    }

	    try {
	        File newFile = new File(uploadDirAbsolutePath + File.separator + savedFileName);
	        file.transferTo(newFile);
	        System.out.println("File saved to: " + newFile.getAbsolutePath());
	        return uploadDirRelativePath + savedFileName; // DB에 저장할 상대 경로
	    } catch (IOException e) {
	        System.err.println("File save error: " + e.getMessage());
	        e.printStackTrace();
	        return null;
	    }
	}

	private void deleteFileOnServer(String fileWebPath, HttpServletRequest request) {
	    if (fileWebPath == null || fileWebPath.isEmpty()) return;

	    HttpSession session = request.getSession();
	    if (session == null) {
	        System.err.println("deleteFileOnServer: HttpSession is null. Cannot get ServletContext.");
	        return;
	    }
	    ServletContext servletContext = session.getServletContext();
	    if (servletContext == null) {
	        System.err.println("deleteFileOnServer: ServletContext is null.");
	        return;
	    }

	    try {
	        String filePath = servletContext.getRealPath(fileWebPath);
	        if (filePath == null) {
	            System.err.println("Could not resolve real path for: " + fileWebPath);
	            return;
	        }
	        File fileToDelete = new File(filePath);
	        if (fileToDelete.exists() && fileToDelete.isFile()) {
	            if(fileToDelete.delete()){
	                System.out.println("Deleted old file: " + filePath);
	            } else {
	                System.err.println("Failed to delete old file: " + filePath);
	            }
	        } else {
	            System.out.println("File not found for deletion or is not a file: " + filePath);
	        }
	    } catch (Exception e) {
	        System.err.println("Error deleting file " + fileWebPath + ": " + e.getMessage());
	        e.printStackTrace();
	    }
	}
	
	@GetMapping("")
	public String destinationPage(Model m,HttpServletRequest request) {
		 HttpSession session = request.getSession(false);
	        if (session == null || session.getAttribute("loggedInAdmin") == null) {
	            return "redirect:/admin/login";
	        }
	       AdminVO admin = (AdminVO) session.getAttribute("loggedInAdmin");
	       m.addAttribute("currentAdmin", admin);
	       List<AdminPlaceVO>destinationList = placeService.getAllDestinationsForAdmin();
	       m.addAttribute("destinationList", destinationList);
	       m.addAttribute("pageTitle", "여행지 정보 관리");
	       m.addAttribute("contentPage", "content_destinationManagement.jsp");
	        return "admin/_layout";
	    
	}
    @GetMapping("/delete") // 또는 @PostMapping("/delete")
    public String deleteUser(@RequestParam("dest_id") Long destId, RedirectAttributes redirectAttributes, HttpServletRequest request) {
    	System.out.println(destId);
    	// 로그인 체크
    	HttpSession session = request.getSession(false);
	    if (session == null || session.getAttribute("loggedInAdmin") == null) {
	        redirectAttributes.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
	        return "redirect:/admin/login";
	    }
	    AdminVO performingAdmin = (AdminVO) session.getAttribute("loggedInAdmin"); // 현재 로그인한 관리자 정보 가져오기

	    try {
	        boolean deleteSuccess = placeService.deleteDest(destId, performingAdmin);
	        if (deleteSuccess) {
	            redirectAttributes.addFlashAttribute("successMessage", "여행지(ID: " + destId + ")가 성공적으로 삭제되었습니다.");
	        } else {
	            redirectAttributes.addFlashAttribute("errorMessage", "여행지(ID: " + destId + ") 삭제에 실패했거나 해당 여행지가 존재하지 않습니다.");
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	        redirectAttributes.addFlashAttribute("errorMessage", "여행지 삭제 중 오류가 발생했습니다: " + e.getMessage());
	    }
	    return "redirect:/admin/destinations";
    }
    
    @GetMapping("/api/detail")
    @ResponseBody
    public ResponseEntity<?>getDetailDest(@RequestParam("dest_id")Long destId){
    	AdminPlaceVO vo =  placeService.getDetailDest(destId);
    	return ResponseEntity.ok(vo);
    }
    
    @PostMapping("/editActionWithFiles")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateDestinationActionWithFiles(
            @RequestParam("dest_id") Long destId,
            @RequestParam("dest_name") String destName,
            @RequestParam("dest_type") String destType,
            @RequestParam("full_address") String fullAddress,
            @RequestParam(value = "contact_num", required = false) String contactNum, // 선택적 필드는 required=false
            @RequestParam(value = "oper_hours", required = false) String operHours,
            @RequestParam(value = "fee_info", required = false) String feeInfo,
            @RequestParam(value = "rel_keywords", required = false) String relKeywords,
            @RequestParam(value = "orig_json_data", required = false) String origJsonData,
            @RequestParam(value = "existingReprImgUrl", required = false) String existingReprImgUrl,
            @RequestParam(value = "newReprImageFile", required = false) MultipartFile newReprImageFile,
            @RequestParam(value = "existingAdditionalImgUrls", required = false) String existingAdditionalImgUrls,
            @RequestParam(value = "newAdditionalImageFiles", required = false) MultipartFile[] newAdditionalImageFiles,
            HttpServletRequest request, HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        AdminVO performingAdmin = (AdminVO) session.getAttribute("loggedInAdmin");

        if (performingAdmin == null || performingAdmin.getAdmin_id() == null) {
            response.put("success", false);
            response.put("message", "관리자 로그인이 필요합니다.");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
        }

        try {
            // AdminPlaceVO의 실제 getDestinationById 메소드명 사용
            AdminPlaceVO destToUpdate = placeService.getDetailDest(destId);
            if (destToUpdate == null) {
                response.put("success", false);
                response.put("message", "수정할 여행지를 찾을 수 없습니다 (ID: " + destId + ").");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            // 변경 전 데이터 로깅을 위한 준비 (예시 - 실제로는 더 정교한 비교 필요)
            // String beforeDetails = createDetailsJson(destToUpdate); // 변경 전 상태를 JSON 문자열로

            // 기본 정보 업데이트
            destToUpdate.setDest_name(destName);
            destToUpdate.setDest_type(destType);
            destToUpdate.setFull_address(fullAddress);
            destToUpdate.setContact_num(contactNum); // null 가능
            destToUpdate.setOper_hours(operHours);   // null 가능
            destToUpdate.setFee_info(feeInfo);     // null 가능
            destToUpdate.setRel_keywords(relKeywords); // null 가능
            destToUpdate.setOrig_json_data(origJsonData); // null 가능

            // 대표 이미지 처리
            String currentReprImgInVO = destToUpdate.getRepr_img_url(); // VO에 저장된 현재 대표 이미지
            String finalReprImgUrl = currentReprImgInVO; // 기본은 기존 값 유지

            if (newReprImageFile != null && !newReprImageFile.isEmpty()) {
                // 새 대표 이미지가 업로드되면 기존 이미지 파일 삭제
                if (currentReprImgInVO != null && !currentReprImgInVO.isEmpty()) {
                    deleteFileOnServer(currentReprImgInVO, request);
                }
                String savedReprImg = saveImage(newReprImageFile, request);
                if (savedReprImg != null) {
                    finalReprImgUrl = savedReprImg;
                } else {
                    // 새 이미지 저장 실패에 대한 처리 (예: 오류 메시지, 기존 이미지 유지 등)
                    System.err.println("새 대표 이미지 저장 실패. destId: " + destId);
                    // finalReprImgUrl은 여전히 currentReprImgInVO 값을 가짐
                }
            } else if (existingReprImgUrl == null || existingReprImgUrl.isEmpty() || "null".equalsIgnoreCase(existingReprImgUrl.trim())) {
                // 클라이언트가 "기존 대표 이미지 없음" 또는 "삭제" 신호를 보낸 경우
                if (currentReprImgInVO != null && !currentReprImgInVO.isEmpty()) {
                    deleteFileOnServer(currentReprImgInVO, request);
                }
                finalReprImgUrl = null; // 대표 이미지 없음으로 설정
            }
            // existingReprImgUrl이 있고 newReprImageFile이 없으면 기존 이미지 유지 (finalReprImgUrl은 이미 currentReprImgInVO)
            destToUpdate.setRepr_img_url(finalReprImgUrl);


            // 추가 이미지 처리
            List<String> finalAdditionalImagePaths = new ArrayList<>();
            // 클라이언트에서 "유지하기로 한 기존 추가 이미지 경로들"
            if (existingAdditionalImgUrls != null && !existingAdditionalImgUrls.trim().isEmpty()) {
                // 쉼표로 구분된 문자열이므로, 각 경로의 유효성 체크나 앞뒤 공백 제거 등이 필요할 수 있음
                finalAdditionalImagePaths.addAll(
                    Arrays.asList(existingAdditionalImgUrls.split(","))
                          .stream()
                          .map(String::trim) // 각 경로 앞뒤 공백 제거
                          .filter(path -> !path.isEmpty()) // 빈 경로 제거
                          .collect(Collectors.toList())
                );
            }

            // 새로 업로드된 추가 이미지 저장 및 경로 추가
            if (newAdditionalImageFiles != null) {
                for (MultipartFile file : newAdditionalImageFiles) {
                    if (file != null && !file.isEmpty()) {
                        String savedAddImg = saveImage(file, request);
                        if (savedAddImg != null) {
                            finalAdditionalImagePaths.add(savedAddImg);
                        } else {
                            System.err.println("새 추가 이미지 중 일부 저장 실패. destId: " + destId);
                        }
                    }
                }
            }
            // AdminPlaceVO에 setAdditional_img_urls 메소드가 String을 받는다고 가정
            destToUpdate.setRepr_img_url(finalAdditionalImagePaths.isEmpty() ? null : String.join(",", finalAdditionalImagePaths));


            // 서비스 메소드명 및 파라미터 확인 (AdminVO 대신 adminId만 전달 가능)
            boolean success = placeService.updateDest(destToUpdate, performingAdmin); // AdminVO performingAdmin 파라미터 제거 또는 서비스 수정

            if (success) {
                // 관리자 활동 로그 기록
                AdminActionLogVO log = new AdminActionLogVO(); // AdminActionLogVO -> AdminActivityLogVO
                log.setAdmin_id(performingAdmin.getAdmin_id());
                log.setTarget_type("DESTINATION");
                log.setTarget_id(String.valueOf(destId));
                log.setAction_type("UPDATE_DESTINATION_INFO"); // 좀 더 구체적으로
                // String afterDetails = new ObjectMapper().writeValueAsString(destToUpdate); // 변경 후 상태
                // log.setAction_details("{\"before\":" + beforeDetails + ", \"after\":" + afterDetails + "}");
                log.setAction_details("여행지 ID " + destId + " 정보 및 이미지 수정됨."); // 간단 로그
                log.setResult_status("SUCCESS");
                activityLogService.recordActivity(log);

                response.put("success", true);
                response.put("message", "여행지 정보가 성공적으로 수정되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                // ... (수정 실패 응답) ...
            }
        } catch (Exception e) {
            // ... (예외 처리 응답) ...
        }
        // 컴파일 에러 방지를 위한 임시 반환
        response.put("success", false);
        response.put("message", "처리 중 예기치 않은 오류가 발생했습니다.");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }

	


}

