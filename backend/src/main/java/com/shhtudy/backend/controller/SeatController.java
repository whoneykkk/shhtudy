package com.shhtudy.backend.controller;

import com.shhtudy.backend.dto.MessageSendRequestDto;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.service.FirebaseAuthService;
import com.shhtudy.backend.service.MessageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/seats")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Seat", description = "좌석 관련 API")

public class SeatController {
    private final MessageService messageService;
    private final FirebaseAuthService firebaseAuthService;

    @Operation(summary = "쪽지 보내기(좌석)", description = "현재 로그인한 사용자가 특정 좌석에 앉아 있는 사용자에게 쪽지를 보냅니다.")
    @PostMapping("/{seatId}/message")
    public ResponseEntity<ApiResponse<String>> sendMessageToSeat(
            @PathVariable Integer seatId,
            @RequestBody @Valid MessageSendRequestDto request,
            @RequestHeader("Authorization") String authorizationHeader) {

        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        messageService.sendMessageToSeat(seatId, request, firebaseUid);
        return ResponseEntity.ok(new ApiResponse<>(true, "메시지 전송 완료", null));
    }

}
