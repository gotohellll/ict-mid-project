package com.midproject.tripin.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.ReviewVO;
import com.midproject.tripin.repositiory.DetailReviewRepo;
import com.midproject.tripin.service.DetailReviewService;

@Service
public class DetailReviewServiceImpl implements DetailReviewService {

    @Autowired
    private DetailReviewRepo reviewRepo;

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

    // 여행지 상세 정보 조회
    @Override
    public PlaceVO getPlaceByDestId(int dest_id) {
        return reviewRepo.getPlaceByDestId(dest_id);
    }

    // 키워드 기반 장소 검색
    @Override
    public List<PlaceVO> searchPlacesByKeyword(String keyword) {
        List<PlaceVO> result = reviewRepo.searchPlacesByKeyword(keyword);
        if (result == null || (result.size() == 1 && result.get(0) == null)) return List.of();
        return result;
    }

    // 좋아요 여부 확인
    @Override
    public boolean isLikedByUser(int user_id, int dest_id) {
        return reviewRepo.countLike(user_id, dest_id) > 0;
    }

    // 좋아요 추가
    @Override
    public void insertLike(int user_id, int dest_id) {
        reviewRepo.insertLike(user_id, dest_id);
    }

    // 좋아요 삭제
    @Override
    public void deleteLike(int user_id, int dest_id) {
        reviewRepo.deleteLike(user_id, dest_id);
    }

    // 리뷰 등록
    @Override
    public void insertReview(ReviewVO review) {
        reviewRepo.insertReview(review);
    }

    // 리뷰 조회 (별점순)
    @Override
    public List<ReviewVO> getReviewsSortedByRating(int dest_id) {
        return reviewRepo.getReviewsSortedByRating(dest_id);
    }

    // 리뷰 조회 (기본: 최신순)
    @Override
    public List<ReviewVO> getReviewsByDestId(int dest_id) {
        return reviewRepo.getReviewsByDestId(dest_id);
    }

    // 여행지 존재 확인 후 없으면 삽입
    @Override
    public int ensureDestinationExists(String name, String contentId) {
        Integer dest_id = reviewRepo.findDestIdByContentId(contentId);
        if (dest_id == null) {
            reviewRepo.insertDestinationWithContentId(name, contentId);
            dest_id = reviewRepo.findDestIdByContentId(contentId);
        }
        return dest_id;
    }

    // 여행지 이름 조회
    @Override
    public String getDestinationNameById(int dest_id) {
        return reviewRepo.findNameByDestId(dest_id);
    }

    // 여행지 contentId 조회
    @Override
    public String getDestinationContentIdById(int dest_id) {
        return reviewRepo.findContentIdByDestId(dest_id);
    }

    // 리뷰 수정
    @Override
    public void updateReview(ReviewVO review) {
        reviewRepo.updateReview(review);
    }

    // 리뷰 신고 처리
    @Override
    public void incrementReportCount(int review_id) {
        reviewRepo.incrementReportCount(review_id);
    }

    // 리뷰 삭제
    @Override
    public boolean deleteReview(int review_id, int user_id) {
        return reviewRepo.deleteReview(review_id, user_id) > 0;
    }

    // 랜덤 여행지 이름 조회 (해시태그용)
    @Override
    public List<String> getRandomDestNames() {
        return reviewRepo.getRandomDestNames();
    }

    // 리뷰 조회 (정렬 기준 지정)
    @Override
    public List<ReviewVO> getReviewsByDestId(int dest_id, String sort) {
        if ("rating".equals(sort)) {
            return reviewRepo.getReviewsSortedByRating(dest_id);
        } else {
            return reviewRepo.getReviewsByDestId(dest_id);
        }
    }
}
