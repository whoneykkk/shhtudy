package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.MessageListResponseDto;
import com.shhtudy.backend.dto.MessageResponseDto;
import com.shhtudy.backend.dto.MessageSendRequestDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.MessageService;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequiredArgsConstructor
@RequestMapping("/messages")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Message", description = "쪽지 관련 API")

public class MessageController {
    private final MessageService messageService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "쪽지 목록 조회", description = "받은/보낸/전체 쪽지를 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<Page<MessageListResponseDto>>> getMessageList(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestParam(defaultValue = "all") String type,
            @Parameter(hidden = true) Pageable pageable
    ) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        Page<MessageListResponseDto> result = messageService.getMessageList(firebaseUid, type, pageable);
        return ResponseEntity.ok(ApiResponse.success(result, "조회 성공"));
    }

    @Operation(summary = "쪽지 답장", description = "특정 메시지에 대해 상대방에게 답장을 보냅니다.")
    @PostMapping("/{messageId}/reply")
    public ResponseEntity<ApiResponse<String>> replyToMessage(
            @PathVariable Long messageId,
            @RequestBody @Valid MessageSendRequestDto request,
            @RequestHeader("Authorization") String authorizationHeader) {

        String senderUid = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        messageService.sendReplyMessage(senderUid, messageId, request);

        return ResponseEntity.ok(new ApiResponse<>(true, "답장 전송 완료", null));
    }

    @Operation(summary = "쪽지 상세 조회", description = "받은/보낸/전체 쪽지를 상세 조회합니다.")
    @GetMapping("/{messageId}")
    public ResponseEntity<ApiResponse<MessageResponseDto>> getMessageDetail(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long messageId
    ) {
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        MessageResponseDto result = messageService.getMessageDetail(messageId, firebaseUid);
        return ResponseEntity.ok(ApiResponse.success(result, "조회 성공"));
    }

    @Operation(summary = "읽지 않은 쪽지 수 조회", description = "사용자의 읽지 않은 쪽지 수를 반환합니다.")
    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Long>> getUnreadMessageCount(
            @RequestHeader("Authorization") String authorizationHeader) {

        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        long count = messageService.countUnreadMessages(firebaseUid);
        return ResponseEntity.ok(ApiResponse.success(count, "조회 성공"));
    }

    @Operation(summary = "쪽지 삭제", description = "자신이 받은 또는 보낸 쪽지를 삭제합니다. 양측 모두 삭제 시 실제 삭제됩니다.")
    @DeleteMapping("/{messageId}")
    public ResponseEntity<ApiResponse<String>> deleteMessage(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long messageId
    ) {
        String firebaseUid = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        messageService.deleteMessage(firebaseUid, messageId);
        return ResponseEntity.ok(ApiResponse.success(null, "삭제 완료"));
    }

    @Operation(summary = "좌석별 쪽지 전송", description = "특정 좌석에 앉아있는 사용자에게 쪽지를 보냅니다.")
    @PostMapping("/seats/{seatId}")
    public ResponseEntity<ApiResponse<String>> sendMessageToSeat(
            @PathVariable Integer seatId,
            @RequestBody @Valid MessageSendRequestDto request,
            @RequestHeader("Authorization") String authorizationHeader) {

        String senderUid = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        messageService.sendMessageToSeat(senderUid, seatId, request);

        return ResponseEntity.ok(new ApiResponse<>(true, "쪽지 전송 완료", null));
    }

    @Operation(summary = "쪽지 읽음 처리", description = "단일 쪽지 또는 모든 쪽지를 읽음 처리합니다.")
    @PostMapping("/read")
    public ResponseEntity<ApiResponse<String>> markMessagesAsRead(
            @RequestParam(required = false) Long messageId,
            @RequestParam(defaultValue = "false") boolean all,
            @RequestHeader("Authorization") String authorizationHeader) {
        
        String firebaseUid = firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
        
        if (all) {
            messageService.markAllMessagesAsRead(firebaseUid);
            return ResponseEntity.ok(new ApiResponse<>(true, "모든 메시지 읽음 처리 완료", null));
        } else if (messageId != null) {
            messageService.markMessageAsRead(firebaseUid, messageId);
            return ResponseEntity.ok(new ApiResponse<>(true, "읽음 처리 완료", null));
        } else {
            return ResponseEntity.badRequest().body(new ApiResponse<>(false, "messageId 또는 all 파라미터가 필요합니다", null));
        }
    }

}

