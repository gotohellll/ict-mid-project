package com.midproject.tripin.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.ReviewVO;
import com.midproject.tripin.repositiory.ReviewRepo;
import com.midproject.tripin.service.ReviewService;

@Service
public class ReviewServiceImpl implements ReviewService {
	
	@Autowired
	private ReviewRepo reviewRepo;

	@Override
	public List<ReviewVO> selectReviewByUser(Integer user_id) {
		return reviewRepo.selectReviewByUser(user_id);
	}

	@Override
	public void deleteReview(Integer review_id) {
		reviewRepo.deleteReview(review_id);
		
	}
	  @Override
	    public List<ReviewVO> getRandomReviews() {
	        List<ReviewVO> reviews = reviewRepo.getRandomReviews();

	        for (ReviewVO review : reviews) {
	            double rating = review.getRating();
	            int full_stars = (int) rating;
	            boolean half_star = (rating - full_stars) >= 0.5;
	            int empty_stars = 5 - full_stars - (half_star ? 1 : 0);

	            review.setFull_stars(full_stars);
	            review.setHalf_star(half_star);
	            review.setEmpty_stars(empty_stars);
	        }

	        return reviews;
	    }


	@Override
	public Integer reviewCountByUser(Integer user_id) {
		return reviewRepo.reviewCountByUser(user_id);
	}
	
}
