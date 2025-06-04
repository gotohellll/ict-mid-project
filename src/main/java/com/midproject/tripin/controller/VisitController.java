package com.midproject.tripin.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.midproject.tripin.service.VisitService;

@RestController
@RequestMapping("/visit")
public class VisitController {

    @Autowired
    private VisitService visitService;

    @GetMapping("/increase")
    public Map<String, Object> increaseVisit() {
        visitService.increaseVisitCount();
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Visit count increased");
        return response;
    }

    @GetMapping("/today")
    public Map<String, Object> getTodayVisitCount() {
        int count = visitService.getTodayVisitCount();
        Map<String, Object> response = new HashMap<>();
        response.put("todayCount", count);
        return response;
    }

    @GetMapping("/total")
    public Map<String, Object> getTotalVisitCount() {
        int count = visitService.getTotalVisitCount();
        Map<String, Object> response = new HashMap<>();
        response.put("totalCount", count);
        return response;
    }
}
