package com.midproject.tripin.service;

import java.util.List;

import com.midproject.tripin.model.ReviewVO;

public interface ReviewService {
	List<ReviewVO> selectReviewByUser(Integer user_id);
	void deleteReview(Integer review_id);
	 List<ReviewVO> getRandomReviews();
	Integer reviewCountByUser(Integer user_id);
}
