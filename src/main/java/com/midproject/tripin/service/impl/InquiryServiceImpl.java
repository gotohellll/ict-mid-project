package com.midproject.tripin.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.midproject.tripin.model.InquiriesVO;
import com.midproject.tripin.repositiory.InquiryRepo;
import com.midproject.tripin.service.InquiryService;

@Service
public class InquiryServiceImpl implements InquiryService {

	@Autowired
	private InquiryRepo inquiryRepo;
	
	@Override
	public void deleteInquiry(Integer chat_inq_id) {
		inquiryRepo.deleteInquiry(chat_inq_id);
	}

	@Override
	public List<InquiriesVO> selectInquiryListByUser(Integer user_id) {
		return inquiryRepo.selectInquiryListByUser(user_id);
	}
	
	public int getUncheckedResponseCount(Integer integer) {
	    if (integer == null) return 0;
	    return inquiryRepo.getUncheckedResponseCountByUserId(integer);
	}

	@Transactional
	public void markInquiryAsCheckedByUser(Long inquiryId, Long userId) {
	    // 추가적인 검증 로직 (예: 정말 해당 사용자의 문의인지)
	    inquiryRepo.markResponseAsChecked(inquiryId, userId);
	}
	@Transactional
    public int markAllResponsesAsCheckedForUser(Integer integer) {
        if (integer == null) {
            return 0;
        }
        System.out.println("Service: Marking all responses as checked for user ID: " + integer); // 로그 추가
        return inquiryRepo.markAllResponsesAsCheckedForUser(integer);
    }


	

}
