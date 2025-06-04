package com.midproject.tripin.service;

import org.json.JSONObject;

public interface PlaceOpenAPIService {
	int fetchAndSavePlaces();

	JSONObject getPlaceDetail(int dest_id, int content_type);
}
