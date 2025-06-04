package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.AdminReviewVO;

@Mapper
public interface AdminReviewRepo {
	
	    List<AdminReviewVO> getAllReviewsForAdmin();
	    AdminReviewVO getDetailReview(Long reviewId);
	    int deleteReview(Long reviewId);
		long getTotalReviewCount();
}
