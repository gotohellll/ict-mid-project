package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.midproject.tripin.model.InquiriesVO;

@Mapper
public interface InquiryRepo {
	void deleteInquiry(Integer chat_inq_id);
	List<InquiriesVO> selectInquiryListByUser(Integer user_id);
	
	// 특정 사용자의 읽지 않은 답변 수 조회
	int getUncheckedResponseCountByUserId(Integer integer);

	// 사용자가 답변을 확인했을 때 상태 업데이트
	int markResponseAsChecked(@Param("inquiryId") Long inquiryId, @Param("userId") Long userId);
	int markAllResponsesAsCheckedForUser(Integer integer);
}
