package com.midproject.tripin.model;

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
public class PlaceVO {
	private int dest_id;
	private String dest_name;
	private String dest_type;
	private String repr_img_url;
	private String full_address;
	private String contact_num;
	private String oper_hours;
	private String fee_info;
	private String rel_keywords;
	private String orig_json_data;
	
	private String created_time;
	private String rest_date;
	private String cat1;
	private String cat2;
	private String cat3;
	private Integer content_type;
	
	private Integer user_id;

	
	private Float avg_rating;
	private Integer review_count;
}
