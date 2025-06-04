package com.midproject.tripin.model;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;
import lombok.ToString;

@Data
@ToString
public class AdminUserVO {
    private Long user_id; // DB: USER_ID (NUMBER)
    private Date joined_at; // DB: JOINED_AT (DATE)
    private String login_id; // DB: LOGIN_ID (VARCHAR2)
    private String password; // DB: PASSWORD (VARCHAR2) - 보통 목록에서는 보여주지 않음
    private String user_name; // DB: USER_NAME (VARCHAR2)
    private String address; // DB: ADDRESS (VARCHAR2)
    private String phone_num; // DB: PHONE_NUM (VARCHAR2)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd", timezone = "Asia/Seoul")
    private Date birthDate; // DB: BIRTH_DATE (DATE)
    private String is_modified; // DB: IS_MODIFIED (VARCHAR2(1))
    private String social_id; // DB: SOCIAL_ID (VARCHAR2)
    private String login_provider; // DB: LOGIN_PROVIDER (VARCHAR2)

}
