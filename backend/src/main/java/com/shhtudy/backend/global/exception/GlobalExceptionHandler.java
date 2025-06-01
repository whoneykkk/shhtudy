package com.shhtudy.backend.global.exception;

import com.shhtudy.backend.global.exception.code.ErrorCode;
import com.shhtudy.backend.global.response.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.orm.jpa.JpaSystemException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.sql.SQLException;

@RestControllerAdvice
public class GlobalExceptionHandler {
    
    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<ApiResponse<Object>> handleCustomException(CustomException e) {
        ErrorCode code = e.getErrorCode();
        logger.error("CustomException: {}", e.getMessage());
        return ResponseEntity
                .status(code.getHttpStatus())
                .body(ApiResponse.fail(code.getMessage()));
    }
    
    // JPA/데이터베이스 관련 예외 처리
    @ExceptionHandler({JpaSystemException.class, DataAccessException.class, SQLException.class})
    public ResponseEntity<ApiResponse<Object>> handleDatabaseException(Exception e) {
        logger.error("Database Error: {}", e.getMessage(), e);
        return ResponseEntity
                .status(500)
                .body(ApiResponse.fail("데이터베이스 오류: " + e.getMessage()));
    }
    
    // 기타 모든 예외 처리
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Object>> handleAllException(Exception e) {
        logger.error("Unexpected Error: {}", e.getMessage(), e);
        return ResponseEntity
                .status(500)
                .body(ApiResponse.fail("서버 오류가 발생했습니다: " + e.getMessage()));
    }
}
