package com.shhtudy.backend.domain.seat.controller;

import com.shhtudy.backend.domain.message.dto.MessageSendRequestDto;
import com.shhtudy.backend.domain.seat.dto.SeatResponseDto;
import com.shhtudy.backend.domain.seat.entity.Seat;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.global.response.ApiResponse;
import com.shhtudy.backend.global.auth.FirebaseAuthService;
import com.shhtudy.backend.domain.message.service.MessageService;
import com.shhtudy.backend.domain.seat.service.SeatService;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping("api/seats")
@SecurityRequirement(name = "FirebaseToken")
@Tag(name = "Seat", description = "좌석 관련 API (데모 앱 - 조회만)")
public class SeatController {
    
    private final SeatService seatService;
    private final MessageService messageService;
    private final FirebaseAuthService firebaseAuthService;
    private final UserRepository userRepository;
    
    @Operation(summary = "좌석 현황 조회", description = "모든 좌석의 현재 상태를 조회합니다.")
    @GetMapping
    public ResponseEntity<ApiResponse<List<SeatResponseDto>>> getAllSeats(
            @RequestHeader("Authorization") String authorizationHeader) {
        
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);
        
        // 사용자 정보 조회 (등급 확인용)
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        List<Seat> seats = seatService.getAllSeats();
        
        // 좌석 정보를 DTO로 변환하면서 접근 가능 여부 추가
        List<SeatResponseDto> seatDtos = seats.stream()
                .map(seat -> {
                    String zone = seat.getLocationCode().split("-")[0];
                    boolean accessible = seatService.canUserAccessZone(zone, user.getGrade());
                    
                    return new SeatResponseDto(
                            seat.getSeatId(),
                            seat.getLocationCode(),
                            seat.getStatus().name(),
                            accessible,
                            seatService.getAccessibilityMessage(zone, user.getGrade())
                    );
                })
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(ApiResponse.success(seatDtos, "좌석 현황 조회 성공"));
    }
    
    @Operation(summary = "구역별 좌석 조회", description = "특정 구역의 좌석 현황을 조회합니다.")
    @GetMapping("/zone/{zone}")
    public ResponseEntity<ApiResponse<List<SeatResponseDto>>> getSeatsByZone(
            @RequestHeader("Authorization") String authorizationHeader,
            @PathVariable String zone) {
        
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);
        
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        List<Seat> seats = seatService.getSeatsByZone(zone);
        boolean accessible = seatService.canUserAccessZone(zone, user.getGrade());
        
        List<SeatResponseDto> seatDtos = seats.stream()
                .map(seat -> new SeatResponseDto(
                        seat.getSeatId(),
                        seat.getLocationCode(),
                        seat.getStatus().name(),
                        accessible,
                        seatService.getAccessibilityMessage(zone, user.getGrade())
                ))
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(ApiResponse.success(seatDtos, zone + "구역 좌석 조회 성공"));
    }
    
    @Operation(summary = "접근 가능한 구역 조회", description = "사용자 등급에 따라 접근 가능한 구역 목록을 반환합니다.")
    @GetMapping("/accessible-zones")
    public ResponseEntity<ApiResponse<List<String>>> getAccessibleZones(
            @RequestHeader("Authorization") String authorizationHeader) {
        
        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);
        
        User user = userRepository.findByFirebaseUid(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        
        List<String> accessibleZones = seatService.getAccessibleZones(user.getGrade());
        
        return ResponseEntity.ok(ApiResponse.success(accessibleZones, "접근 가능한 구역 조회 성공"));
    }

    @Operation(summary = "쪽지 보내기(좌석)", description = "현재 로그인한 사용자가 특정 좌석에 앉아 있는 사용자에게 쪽지를 보냅니다.")
    @PostMapping("/{seatId}/message")
    public ResponseEntity<ApiResponse<String>> sendMessageToSeat(
            @PathVariable Integer seatId,
            @RequestBody @Valid MessageSendRequestDto request,
            @RequestHeader("Authorization") String authorizationHeader) {

        String idToken = authorizationHeader.replace("Bearer ", "");
        String firebaseUid = firebaseAuthService.verifyIdToken(idToken);

        messageService.sendMessageToSeat(firebaseUid, seatId, request);
        return ResponseEntity.ok(new ApiResponse<>(true, "메시지 전송 완료", null));
    }
}
