package com.midproject.tripin.repositiory;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface VisitRepo {
    void increaseVisitCount();
    int getTodayVisitCount();
    int getTotalVisitCount();
}
