package com.shhtudy.backend.global.response;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.*;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Schema(description = "API 공통 응답")
public class ResponseCustom<T> {

    @Schema(description = "응답 데이터", example = "{\"id\": 1, \"name\": \"홍길동\"}")
    private T data;

    @Schema(description = "설명 메시지", example = "요청이 성공적으로 처리되었습니다.")
    private String message;

    @Schema(description = "요청 처리 시간", example = "2025-06-11T19:00:00")
    private LocalDateTime timestamp;

    @Schema(description = "HTTP 상태 코드", example = "200")
    private int statusCode;

    @Schema(description = "HTTP 상태 이름", example = "OK")
    private String status;

    public static <T> ResponseCustom<T> of(T data, String message, HttpStatus httpStatus) {
        return ResponseCustom.<T>builder()
                .data(data)
                .message(message)
                .timestamp(LocalDateTime.now())
                .statusCode(httpStatus.value())
                .status(httpStatus.name())
                .build();
    }

    public static <T> ResponseCustom<T> ok(T data) {
        return of(data, "요청이 성공적으로 처리되었습니다.", HttpStatus.OK);
    }

    public static <T> ResponseCustom<T> created(T data) {
        return of(data, "리소스가 성공적으로 생성되었습니다.", HttpStatus.CREATED);
    }

    public static <T> ResponseCustom<T> badRequest(String message) {
        return of(null, message, HttpStatus.BAD_REQUEST);
    }

    public static <T> ResponseCustom<T> notFound(String message) {
        return of(null, message, HttpStatus.NOT_FOUND);
    }

    public static <T> ResponseCustom<T> internalServerError(String message) {
        return of(null, message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
