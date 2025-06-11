package com.shhtudy.backend.domain.message.service;

import com.shhtudy.backend.domain.message.dto.*;
import com.shhtudy.backend.domain.message.entity.Message;
import com.shhtudy.backend.domain.user.entity.User;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import com.shhtudy.backend.domain.message.repository.MessageRepository;
import com.shhtudy.backend.domain.user.repository.UserRepository;
import com.shhtudy.backend.global.util.UserDisplayUtil;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    private void validateMessageAccess(Message message, String userId) {
        if (!userId.equals(message.getSenderId()) && !userId.equals(message.getReceiverId())) {
            throw new CustomException(ErrorCode.MESSAGE_NOT_FOUND);
        }
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
        message.setSentAt(LocalDateTime.now());

        messageRepository.save(message);
    }

    public Page<MessageListResponseDto> getAllMessages(String userId, String type, Pageable pageable) {
        Page<Message> messages = switch (type) {
            case "received" -> {
                Page<Message> receivedMessages = messageRepository.findByReceiverIdAndDeletedByReceiverFalse(userId, pageable);
                receivedMessages.forEach(message -> {
                    if (!message.isRead()) message.setRead(true);
                });
                yield receivedMessages;
            }
            case "sent" -> messageRepository.findBySenderIdAndDeletedBySenderFalse(userId, pageable);
            default -> messageRepository.findAllVisibleMessages(userId, pageable);
        };

        return messages.map(message -> {
            boolean isSentByMe = message.getSenderId().equals(userId);
            String counterpartUid = isSentByMe ? message.getReceiverId() : message.getSenderId();

            User counterpart = userRepository.findByFirebaseUid(counterpartUid)
                    .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

            String displayName = UserDisplayUtil.getDisplayName(counterpart);
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
    public MessageResponseDto getMessageDetail(Long messageId, String userId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new CustomException(ErrorCode.MESSAGE_NOT_FOUND));

        validateMessageAccess(message, userId);

        if (userId.equals(message.getSenderId()) && message.isDeletedBySender()) {
            throw new CustomException(ErrorCode.MESSAGE_NOT_FOUND);
        }
        if (userId.equals(message.getReceiverId()) && message.isDeletedByReceiver()) {
            throw new CustomException(ErrorCode.MESSAGE_NOT_FOUND);
        }

        if (userId.equals(message.getReceiverId()) && !message.isRead()) {
            message.setRead(true);
        }

        User sender = userRepository.findByFirebaseUid(message.getSenderId())
                .orElseThrow(() -> new CustomException(ErrorCode.SENDER_NOT_FOUND));

        return MessageResponseDto.from(message, UserDisplayUtil.getDisplayName(sender));
    }

    @Transactional
    public void deleteMessage(String userId, Long messageId) {
        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new CustomException(ErrorCode.MESSAGE_NOT_FOUND));

        validateMessageAccess(message, userId);

        if (userId.equals(message.getSenderId())) {
            message.setDeletedBySender(true);
        }

        if (userId.equals(message.getReceiverId())) {
            message.setDeletedByReceiver(true);
        }

        if (message.isDeletedBySender() && message.isDeletedByReceiver()) {
            messageRepository.delete(message);
        }
    }

    public MyPageMessagesResponseDto getUnreadReceivedMessagesForMyPage(String userId) {
        long unreadCount = messageRepository.countByReceiverIdAndReadFalseAndDeletedByReceiverFalse(userId);

        List<Message> unreadMessages = messageRepository
                .findByReceiverIdAndReadFalseAndDeletedByReceiverFalseOrderBySentAtDesc(
                        userId,
                        PageRequest.of(0, 2)
                ).getContent();

        List<MyPageMessageDto> messageDtos = unreadMessages.stream()
                .map(message -> {
                    User counterpart = userRepository.findByFirebaseUid(message.getSenderId())
                            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

                    return new MyPageMessageDto(
                            message,
                            UserDisplayUtil.getDisplayName(counterpart),
                            message.getSenderId().equals(userId)
                    );
                })
                .toList();

        return new MyPageMessagesResponseDto(unreadCount, messageDtos);
    }
}
