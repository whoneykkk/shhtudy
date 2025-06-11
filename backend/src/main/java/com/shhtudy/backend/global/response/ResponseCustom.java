package com.shhtudy.backend.global.response;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.annotation.Nullable;
import lombok.*;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

@Getter
@Setter
@ToString
@NoArgsConstructor
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
    private HttpStatus status;

    @Builder
    public ResponseCustom(T data, LocalDateTime timestamp, String message, HttpStatus status, int statusCode) {
        this.data = data;
        this.timestamp = timestamp;
        this.message = message;
        this.status = status;
        this.statusCode = statusCode;
    }

    public static <T> ResponseCustom<T> OK(@Nullable T data) {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .data(data)
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.OK)
                .statusCode(HttpStatus.OK.value())
                .build();
    }
    public static <T> ResponseCustom<T> OK() {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .timestamp(LocalDateTime.now())
                .message("요청이 성공적으로 처리되었습니다.")
                .status(HttpStatus.OK)
                .statusCode(HttpStatus.OK.value())
                .build();
    }

    public static <T> ResponseCustom<T> OK(String message) {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .timestamp(LocalDateTime.now())
                .message(message)
                .status(HttpStatus.OK)
                .statusCode(HttpStatus.OK.value())
                .build();
    }

    public static <T> ResponseCustom<T> created(T data) {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .data(data)
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.CREATED)
                .statusCode(HttpStatus.CREATED.value())
                .build();
    }

    public static <T> ResponseCustom<T> badRequest(@Nullable T data) {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .data(data)
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.BAD_REQUEST)
                .statusCode(HttpStatus.BAD_REQUEST.value())
                .build();
    }

    public static <T> ResponseCustom<T> notFound(@Nullable T data) {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .data(data)
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.NOT_FOUND)
                .statusCode(HttpStatus.NOT_FOUND.value())
                .build();
    }

    public static <T> ResponseCustom<T> internalServerError(@Nullable T data) {
        return (ResponseCustom<T>) ResponseCustom.builder()
                .data(data)
                .timestamp(LocalDateTime.now())
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .statusCode(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .build();
    }
}
