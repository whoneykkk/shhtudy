package com.shhtudy.backend.global.exception.code;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {

    // 공통 오류 (-1 ~ -999)
    BAD_REQUEST(HttpStatus.BAD_REQUEST, "-100", "잘못된 요청입니다."),

    // 사용자/계정 관련 오류 (-1000 ~ -1999)
    DUPLICATE_USER(HttpStatus.CONFLICT, "-1001", "이미 가입된 사용자입니다."),
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "-1002", "존재하지 않는 사용자입니다."),
    INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "-1003", "비밀번호가 일치하지 않습니다."),
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "-1004", "전화번호 또는 비밀번호가 올바르지 않습니다."),
    INVALID_FIREBASE_TOKEN(HttpStatus.UNAUTHORIZED, "-1005", "유효하지 않은 Firebase 토큰입니다."),
    DUPLICATE_NICKNAME(HttpStatus.CONFLICT, "-1006", "이미 사용 중인 닉네임입니다."),
    SENDER_NOT_FOUND(HttpStatus.NOT_FOUND, "-1007", "발신자 정보가 존재하지 않습니다."),
    RECEIVER_NOT_FOUND(HttpStatus.NOT_FOUND, "-1008", "수신자 정보가 존재하지 않습니다."),
    NO_USER_IN_SEAT(HttpStatus.NOT_FOUND, "-1009", "현재 해당 좌석을 이용 중인 사용자가 없습니다."),

    // 메시지 관련 오류 (-2000 ~ -2999)
    MESSAGE_NOT_FOUND(HttpStatus.NOT_FOUND, "-2001", "존재하지 않는 메시지입니다."),
    FORBIDDEN(HttpStatus.FORBIDDEN, "-2002", "접근 권한이 없습니다."),

    // 공지사항 관련 오류 (-4000 ~ -4999)
    NOTICE_NOT_FOUND(HttpStatus.NOT_FOUND, "-4001", "해당 ID의 공지사항이 존재하지 않습니다."),
    ALREADY_READ(HttpStatus.CONFLICT, "-4002", "이미 읽은 공지사항입니다. (중복 등록 방지)"),

    // 소음 관련 오류 (-5000 ~ -5999)
    INVALID_DECIBEL_VALUE(HttpStatus.BAD_REQUEST, "-5001", "Invalid decibel value"),
    INVALID_SEAT_NUMBER(HttpStatus.BAD_REQUEST, "-5002", "Invalid seat number"),
    NOISE_DATA_NOT_FOUND(HttpStatus.NOT_FOUND, "-5003", "Noise data not found"),
    SEAT_NOT_FOUND(HttpStatus.NOT_FOUND, "-5004", "Seat not found"),

    // 시스템 오류 (-9000 이상)
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "-9001", "서버 내부 오류입니다."),
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "-9002", "Internal server error");

    private final HttpStatus httpStatus;
    private final String code;
    private final String message;

    ErrorCode(final HttpStatus httpStatus, final String code, final String message) {
        this.httpStatus = httpStatus;
        this.code = code;
        this.message = message;
    }
}
