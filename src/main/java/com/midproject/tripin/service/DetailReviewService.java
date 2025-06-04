package com.midproject.tripin.service;

import java.util.List;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.ReviewVO;

public interface DetailReviewService {

    List<ReviewVO> getRandomReviews();

    // 리뷰 등록
    void insertReview(ReviewVO review);

    // 리뷰 조회 (별점순)
    List<ReviewVO> getReviewsSortedByRating(int dest_id);

    // 리뷰 조회 (기본: 최신순)
    List<ReviewVO> getReviewsByDestId(int dest_id);

    // 리뷰 조회 (정렬 기준 지정)
    List<ReviewVO> getReviewsByDestId(int dest_id, String sort);

    // 여행지 존재 확인 후 없으면 삽입
    int ensureDestinationExists(String name, String contentId);

    // 여행지 이름 조회
    String getDestinationNameById(int dest_id);

    // 여행지 contentId 조회
    String getDestinationContentIdById(int dest_id);

    // 좋아요 여부 확인
    boolean isLikedByUser(int user_id, int dest_id);

    // 좋아요 추가
    void insertLike(int user_id, int dest_id);

    // 좋아요 삭제
    void deleteLike(int user_id, int dest_id);

    // 여행지 상세 정보 조회
    PlaceVO getPlaceByDestId(int dest_id);

    // 리뷰 수정
    void updateReview(ReviewVO review);

    // 리뷰 삭제
    boolean deleteReview(int review_id, int user_id);

    // 리뷰 신고 처리
    void incrementReportCount(int review_id);

    // 키워드 기반 장소 검색
    List<PlaceVO> searchPlacesByKeyword(String keyword);

    // 랜덤 여행지 이름 조회 (해시태그용)
    List<String> getRandomDestNames();
} 