package com.midproject.tripin.service;

public interface VisitService {
    void increaseVisitCount();
    int getTodayVisitCount();
    int getTotalVisitCount();
}