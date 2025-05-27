package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.MessageListResponseDto;
import com.shhtudy.backend.dto.MessageResponseDto;
import com.shhtudy.backend.dto.MessageSendRequestDto;
import com.shhtudy.backend.entity.Message;
import com.shhtudy.backend.entity.Seat;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.MessageRepository;
import com.shhtudy.backend.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MessageService {
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    private void validateMessageAccess(Message message, String firebaseUid) {
        if (!firebaseUid.equals(message.getSenderId()) && !firebaseUid.equals(message.getReceiverId())) {
            throw new CustomException(ErrorCode.MESSAGE_NOT_FOUND); // or FORBIDDEN
        }
    }

    private String getDisplayName(User user) {
        String nickname = user.getNickname();
        Seat seat = user.getCurrentSeat();
        return seat != null
                ? seat.getLocationCode() + "번 (" + nickname + ")"
                : "퇴실한 사용자 (" + nickname + ")";
    }

    private void sendMessage(String senderUid, String receiverUid, String content) {
        if (!userRepository.existsByFirebaseUid(senderUid)) {
            throw new CustomException(ErrorCode.SENDER_NOT_FOUND);
        }

        if (!userRepository.existsByFirebaseUid(receiverUid)) {
            throw new CustomException(ErrorCode.RECEIVER_NOT_FOUND);
        }

        Message message = new Message();
        message.setSenderId(senderUid);
        message.setReceiverId(receiverUid);
        message.setContent(content);


        messageRepository.save(message);
    }

    public Page<MessageListResponseDto> getAllMessages(String firebaseUid, String type, Pageable pageable) {

        Page<Message> messages = switch (type) {
            case "received" -> {
                Page<Message> receivedMessages = messageRepository.findByReceiverIdAndDeletedByReceiverFalse(firebaseUid, pageable);
                receivedMessages.forEach(message -> {
                    if (!message.isRead()) {
                        message.setRead(true);
                        messageRepository.save(message);
                    }
                });
                yield receivedMessages;
            }
            case "sent"     -> messageRepository.findBySenderIdAndDeletedBySenderFalse(firebaseUid, pageable);
            default         -> messageRepository.findAllVisibleMessages(firebaseUid, pageable);
        };

        return messages.map(message -> {
            boolean isSentByMe = message.getSenderId().equals(firebaseUid);
            String counterpartUid = isSentByMe ? message.getReceiverId() : message.getSenderId();

            User counterpart = userRepository.findByFirebaseUid(counterpartUid)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

            String displayName = getDisplayName(counterpart);

            return MessageListResponseDto.from(message, displayName, isSentByMe);
        });

    }

    public void sendReplyMessage(String senderUid, Long originalMessageId, MessageSendRequestDto request) {
        Message original = messageRepository.findById(originalMessageId)
                .orElseThrow(() -> new CustomException(ErrorCode.MESSAGE_NOT_FOUND));

        validateMessageAccess(original, senderUid);

        String receiverUid = senderUid.equals(original.getSenderId())
                ? original.getReceiverId()
                : original.getSenderId();

        sendMessage(senderUid, receiverUid, request.getContent());
    }

    public void sendMessageToSeat(String senderUid, Integer seatId, MessageSendRequestDto request) {
        User receiver = userRepository.findByCurrentSeat_SeatId(seatId)
                .orElseThrow(() -> new CustomException(ErrorCode.NO_USER_IN_SEAT));

        sendMessage(senderUid, receiver.getFirebaseUid(), request.getContent());
    }

    @Transactional
    public MessageResponseDto getMessageDetail(Long messageId, String firebaseUid) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new CustomException(ErrorCode.MESSAGE_NOT_FOUND));

        validateMessageAccess(message, firebaseUid);

        if (firebaseUid.equals(message.getSenderId()) && message.isDeletedBySender()) {
            throw new CustomException(ErrorCode.MESSAGE_NOT_FOUND);
        }
        if (firebaseUid.equals(message.getReceiverId()) && message.isDeletedByReceiver()) {
            throw new CustomException(ErrorCode.MESSAGE_NOT_FOUND);
        }

        if (firebaseUid.equals(message.getReceiverId()) && !message.isRead()) {
            message.setRead(true);
        }

        User sender = userRepository.findByFirebaseUid(message.getSenderId())
                .orElseThrow(() -> new CustomException(ErrorCode.SENDER_NOT_FOUND));

        return MessageResponseDto.from(message, getDisplayName(sender));
    }

    public long countUnreadMessages(String firebaseUid) {
        return messageRepository.countByReceiverIdAndReadFalseAndDeletedByReceiverFalse(firebaseUid);
    }
    
    @Transactional
    public void deleteMessage(String firebaseUid, Long messageId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new CustomException(ErrorCode.MESSAGE_NOT_FOUND));

        if (!firebaseUid.equals(message.getSenderId()) && !firebaseUid.equals(message.getReceiverId())) {
            throw new CustomException(ErrorCode.FORBIDDEN); // 권한 없음
        }

        if (firebaseUid.equals(message.getSenderId())) {
            message.setDeletedBySender(true);
        }

        if (firebaseUid.equals(message.getReceiverId())) {
            message.setDeletedByReceiver(true);
        }

        if (message.isDeletedBySender() && message.isDeletedByReceiver()) {
            messageRepository.delete(message);
        } else {
            messageRepository.save(message);
        }
    }

    public Page<MessageListResponseDto> getUnreadReceivedMessagesForMyPage(String firebaseUid, Pageable pageable) {
        Page<Message> messages = messageRepository
                .findByReceiverIdAndReadFalseAndDeletedByReceiverFalseOrderBySentAtDesc(firebaseUid, pageable);

        return messages.map(message -> {
            User sender = userRepository.findByFirebaseUid(message.getSenderId())
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

            String displayName = getDisplayName(sender);

            return MessageListResponseDto.from(message, displayName, false); // 항상 false
        });
    }
}
