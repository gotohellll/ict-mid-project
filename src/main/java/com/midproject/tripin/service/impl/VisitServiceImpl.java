package com.midproject.tripin.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.midproject.tripin.repositiory.VisitRepo;
import com.midproject.tripin.service.VisitService;


@Service
public class VisitServiceImpl implements VisitService {

    @Autowired
    private VisitRepo visitRepository;

    @Override
    public void increaseVisitCount() {
        visitRepository.increaseVisitCount();
    }

    @Override
    public int getTodayVisitCount() {
        return visitRepository.getTodayVisitCount();
    }

    @Override
    public int getTotalVisitCount() {
        return visitRepository.getTotalVisitCount();
    }
}
