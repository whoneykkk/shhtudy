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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public Page<MessageListResponseDto> getMessageList(String firebaseUid, String type, Pageable pageable) {
        Page<Message> messages = switch (type) {
            case "received" -> messageRepository.findByReceiverId(firebaseUid, pageable);
            case "sent"     -> messageRepository.findBySenderId(firebaseUid, pageable);
            default         -> messageRepository.findBySenderIdOrReceiverId(firebaseUid, firebaseUid, pageable);
        };

        return messages.map(message -> {
            boolean isSentByMe = message.getSenderId().equals(firebaseUid);
            String counterpartUid = isSentByMe ? message.getReceiverId() : message.getSenderId();

            User counterpart = userRepository.findByFirebaseUid(counterpartUid)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

            String nickname = counterpart.getNickname();
            Seat seat = counterpart.getCurrentSeat();

            String displayName = seat != null
                    ? seat.getLocationCode() + "번 (" + nickname + ")"
                    : "퇴실한 사용자 (" + nickname + ")";

            return MessageListResponseDto.from(message, displayName, isSentByMe);
        });
    }

}
