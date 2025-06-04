package com.midproject.tripin.model;

public class DetailReviewVO {

    private int reviewId;
    private int userId;
    private int destId;
    private double rating;
    private String content;
    private java.util.Date createdAt;
    private String imagePath;

    private int fullStars;
    private boolean halfStar;
    private int emptyStars;
    private String createdAtStr;

    public String getCreatedAtStr() {
        return createdAtStr;
    }

    public void setCreatedAtStr(String createdAtStr) {
        this.createdAtStr = createdAtStr;
    }

    public int getFullStars() {
        return fullStars;
    }

    public void setFullStars(int fullStars) {
        this.fullStars = fullStars;
    }

    public boolean isHalfStar() {
        return halfStar;
    }

    public void setHalfStar(boolean halfStar) {
        this.halfStar = halfStar;
    }

    public int getEmptyStars() {
        return emptyStars;
    }

    public void setEmptyStars(int emptyStars) {
        this.emptyStars = emptyStars;
    }

    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getDestId() {
        return destId;
    }

    public void setDestId(int destId) {
        this.destId = destId;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public java.util.Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(java.util.Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
} 