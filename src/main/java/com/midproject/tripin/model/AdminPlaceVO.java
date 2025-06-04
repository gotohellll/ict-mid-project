package com.midproject.tripin.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@AllArgsConstructor
@NoArgsConstructor
@ToString
public class AdminPlaceVO {

	private Long dest_id;
	private String dest_name;
	private String dest_type;
    private String repr_img_url;
    private String full_address;
    private String contact_num;
    private String oper_hours;
    private String fee_info;
    private String rel_keywords;
    private String orig_json_data;
    
    private List<AdminPlaceDetailVO> themes;
	
}

