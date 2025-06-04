package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.ReviewVO;

@Mapper
public interface ReviewRepo {
	List<ReviewVO> selectReviewByUser(Integer user_id);
	void deleteReview(Integer review_id);
	 List<ReviewVO> getRandomReviews();
	Integer reviewCountByUser(Integer user_id);
}
