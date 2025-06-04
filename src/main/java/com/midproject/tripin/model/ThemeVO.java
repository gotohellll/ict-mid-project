package com.midproject.tripin.model;

import lombok.Data;

@Data
public class ThemeVO {
    private Long theme_id; 
    private String theme_name; 
    private Integer theme_cnt;   

    private String chart_color;
}