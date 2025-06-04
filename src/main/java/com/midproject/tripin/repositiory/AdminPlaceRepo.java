package com.midproject.tripin.repositiory;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.midproject.tripin.model.AdminPlaceVO;

@Mapper
public interface AdminPlaceRepo {
	List<AdminPlaceVO> getAllDestinationsForAdmin();
	AdminPlaceVO getDetailDest(Long destId);
	int updateDest(AdminPlaceVO destinationData);
	int deleteDest(Long destId);

}
