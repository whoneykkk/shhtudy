package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.MessageListResponseDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.MessageService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/messages")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Message", description = "쪽지 관련 API")

public class MessageController {
    private final MessageService messageService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "쪽지 목록 조회", description = "받은 쪽지, 보낸 쪽지, 전체 쪽지를 type 파라미터로 구분하여 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<MessageListResponseDto>>> getMessages(
            @Parameter(description = "Firebase 인증 토큰", required = true)
            @RequestHeader("Authorization") String authorizationHeader,

            @Parameter(description = "조회 타입 (received, sent, all). 기본값은 all")
            @RequestParam(defaultValue = "all") String type){
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        List<MessageListResponseDto> response = messageService.getMessageList(firebaseUid, type);

        return ResponseEntity.ok(ApiResponse.success(response, "메시지 조회 성공"));
    }
}
