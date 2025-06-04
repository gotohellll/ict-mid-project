package com.midproject.tripin.repositiory;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.AdminFAQVO;

@Mapper
public interface AdminChatInquiryRepo {
		int insertChatInquiry(AdminFAQVO chatInquiry);

	    // 관리자가 문의에 답변하거나 상태를 변경할 때 사용
	    int updateChatInquiryByAdmin(AdminFAQVO chatInquiry);

	    // 특정 문의 상세 조회 (JOIN 포함 가능)
	    AdminFAQVO getChatInquiryById(Long chatInqId);

	    // 관리자용 문의 목록 조회 (필터링, 정렬, 페이징 지원)
	    List<AdminFAQVO> getChatInquiriesForAdmin(Map<String, Object> params);

	    // 관리자용 문의 총 개수 조회 (페이징용)
	    int getTotalChatInquiriesForAdmin(Map<String, Object> params);

	    // 사용자별 자신의 챗봇 문의 목록 조회 (마이페이지용)
	    List<AdminFAQVO> getChatInquiriesByUserId(Long userId);

		long getCountByStatus(AdminFAQVO searchVO);
}
