package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.MessageListResponseDto;
import com.shhtudy.backend.entity.Message;
import com.shhtudy.backend.entity.Seat;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.MessageRepository;
import com.shhtudy.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public List<MessageListResponseDto> getMessageList(String firebaseUid, String type) {
        // 1. type에 따라 받은/보낸/전체 쪽지 목록 조회
        List<Message> messages = switch (type) {
            case "received" -> messageRepository.findByReceiverIdOrderBySentAtDesc(firebaseUid);
            case "sent"     -> messageRepository.findBySenderIdOrderBySentAtDesc(firebaseUid);
            default         -> messageRepository.findBySenderIdOrReceiverIdOrderBySentAtDesc(firebaseUid,firebaseUid);
        };

        // 2. 각 메시지를 DTO로 변환
        return messages.stream().map(message -> {
            boolean isSentByMe = message.getSenderId().equals(firebaseUid);
            String counterpartUid = isSentByMe ? message.getReceiverId() : message.getSenderId();

            // 닉네임 조회
            String nickname = userRepository.findByFirebaseUid(counterpartUid)
                    .map(User::getNickname)
                    .orElse("(알 수 없음)");

            // 좌석 상태 조회
            // 먼저 상대방 유저를 가져온 뒤
            User counterpart = userRepository.findByFirebaseUid(counterpartUid)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

            // 상대방의 현재 좌석을 가져온다
            Seat seat = counterpart.getCurrentSeat();

            String displayName = seat != null
                    ? seat.getLocationCode() + "번 (" + nickname + ")"
                    : "퇴실한 사용자 (" + nickname + ")";


            return MessageListResponseDto.from(message, displayName, isSentByMe);
        }).toList();
    }

}
