package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.midproject.tripin.model.PlaceVO;
import com.midproject.tripin.model.ReviewVO;

@Mapper
public interface DetailReviewRepo {

    List<ReviewVO> getRandomReviews();

    // 리뷰 등록
    void insertReview(ReviewVO review);

    // 리뷰 조회 (최신순)
    List<ReviewVO> getReviewsByDestId(@Param("dest_id") int dest_id);

    // 리뷰 조회 (별점순)
    List<ReviewVO> getReviewsSortedByRating(@Param("dest_id") int dest_id);

    // 여행지 이름 조회
    String findNameByDestId(@Param("dest_id") int dest_id);

    // 여행지 존재 확인 (contentId 기준)
    Integer findDestIdByContentId(@Param("contentId") String contentId);

    // 여행지 삽입
    void insertDestinationWithContentId(@Param("name") String name, @Param("contentId") String contentId);

    // contentId 조회 (destId 기준)
    String findContentIdByDestId(@Param("dest_id") int dest_id);

    // 리뷰 수정
    void updateReview(ReviewVO review);

    // 리뷰 삭제
    int deleteReview(@Param("review_id") int review_id, @Param("user_id") int user_id);

    // 리뷰 신고
    void incrementReportCount(@Param("review_id") int review_id);

    // 키워드 기반 장소 검색
    List<PlaceVO> searchPlacesByKeyword(@Param("keyword") String keyword);

    // 여행지 상세 조회 (destId 기준)
    PlaceVO getPlaceByDestId(@Param("dest_id") int dest_id);

    // 좋아요 여부 확인
    int countLike(@Param("user_id") int user_id, @Param("dest_id") int dest_id);

    // 좋아요 추가
    void insertLike(@Param("user_id") int user_id, @Param("dest_id") int dest_id);

    // 좋아요 삭제
    void deleteLike(@Param("user_id") int user_id, @Param("dest_id") int dest_id);

    // 랜덤 해시태그용 여행지 이름 조회
    List<String> getRandomDestNames();
} 
