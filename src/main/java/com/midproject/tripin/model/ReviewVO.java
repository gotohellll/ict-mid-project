package com.midproject.tripin.model;

import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReviewVO {
	private Integer review_id;
	private Integer user_id;
	private Integer dest_id;
	private double rating;
	private String content;
	private Date created_at;
	private String image_path;
	private int full_stars;
	private boolean half_star;
	private int empty_stars;
	private String created_at_str;
	
	//조인 때문에 추가
	private String dest_name;
	private String user_name;

}
