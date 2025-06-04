package com.midproject.tripin.service;

import java.util.List;

import com.midproject.tripin.model.InquiriesVO;

public interface InquiryService {
	void deleteInquiry(Integer chat_inq_id);
	List<InquiriesVO> selectInquiryListByUser(Integer user_id);
}
