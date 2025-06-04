package com.midproject.tripin.model;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString
@AllArgsConstructor
@NoArgsConstructor
public class AdminReviewVO {
    private Long review_id;
    private Long user_id;
    private Long dest_id;
    private String user_name;
    private String dest_name;
    private Double rating; 
    private String content; 
    private Date created_at;
    private Long report_count;
    private String image_path;
}
