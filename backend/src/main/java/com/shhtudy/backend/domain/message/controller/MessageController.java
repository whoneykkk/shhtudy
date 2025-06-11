package com.shhtudy.backend.domain.message.controller;

import com.shhtudy.backend.domain.message.dto.*;
import com.shhtudy.backend.global.response.ResponseCustom;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.domain.message.service.MessageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/messages")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Message", description = "쪽지 관련 API")
public class MessageController {

    private final MessageService messageService;
    private final FirebaseAuthService firebaseAuthService;

    private String extractUid(String authorizationHeader) {
        return firebaseAuthService.verifyIdToken(authorizationHeader.replace("Bearer ", ""));
    }

    @Operation(summary = "쪽지 목록 조회", description = "받은/보낸/전체 쪽지 목록을 조회합니다. 받은 쪽지 목록 조회 시 안 읽은 쪽지는 모두 읽음 처리 합니다.")
    @GetMapping
    public ResponseCustom<Page<MessageListResponseDto>> getAllMessages(
            @RequestHeader("Authorization") String authorizationHeader,
            @RequestParam(defaultValue = "all") String type,
            @Parameter(hidden = true) Pageable pageable
    ) {
        String firebaseUid = extractUid(authorizationHeader);
        Page<MessageListResponseDto> result = messageService.getAllMessages(firebaseUid, type, pageable);
        return ResponseCustom.OK(result);
    }

    @Operation(summary = "쪽지 답장", description = "특정 메시지에 대해 상대방에게 답장을 보냅니다.")
    @PostMapping("/{messageId}/reply")
    public ResponseCustom<Void> replyToMessage(
            @PathVariable Long messageId,
            @RequestBody @Valid MessageSendRequestDto request,
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        String senderUid = extractUid(authorizationHeader);
        messageService.sendReplyMessage(senderUid, messageId, request);
        return ResponseCustom.OK();
    }

    @Operation(summary = "쪽지 상세 조회", description = "받은/보낸/전체 쪽지를 상세 조회합니다. 조회한 쪽지는 읽음 처리 합니다.")
    @GetMapping("/{messageId}")
    public ResponseCustom<MessageResponseDto> getMessageDetail(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long messageId
    ) {
        String firebaseUid = extractUid(authorizationHeader);
        MessageResponseDto result = messageService.getMessageDetail(messageId, firebaseUid);
        return ResponseCustom.OK(result);
    }

    @Operation(summary = "쪽지 삭제", description = "자신이 받은 또는 보낸 쪽지를 삭제합니다. 양측 모두 삭제 시 실제 삭제됩니다.")
    @DeleteMapping("/{messageId}")
    public ResponseCustom<Void> deleteMessage(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable Long messageId
    ) {
        String firebaseUid = extractUid(authorizationHeader);
        messageService.deleteMessage(firebaseUid, messageId);
        return ResponseCustom.OK();
    }

    @Operation(summary = "마이페이지 쪽지 요약 조회", description = "읽지 않은 쪽지 중 삭제되지 않은 쪽지를 최신순으로 최대 2건 조회합니다.")
    @GetMapping("/mypage")
    public ResponseCustom<MyPageMessagesResponseDto> getMessageSummaryForMyPage(
            @RequestHeader("Authorization") String authorizationHeader
    ) {
        String firebaseUid = extractUid(authorizationHeader);
        MyPageMessagesResponseDto result = messageService.getUnreadReceivedMessagesForMyPage(firebaseUid);

        if(result.getMessages().isEmpty())
            return ResponseCustom.OK("읽지 않은 쪽지가 존재하지 않습니다.");

        return ResponseCustom.OK(result);
    }
}
