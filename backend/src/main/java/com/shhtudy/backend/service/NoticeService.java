package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.NoticeResponseDto;
import com.shhtudy.backend.entity.Notice;
import com.shhtudy.backend.entity.NoticeRead;
import com.shhtudy.backend.entity.User;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.NoticeReadRepository;
import com.shhtudy.backend.repository.NoticeRepository;
import com.shhtudy.backend.repository.UserRepository;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NoticeService {
    private final NoticeRepository noticeRepository;
    private final NoticeReadRepository noticeReadRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly=true)
    public List<NoticeResponseDto> getNoticeWithRaeadStatus(String firebaseUid) {
        User user = userRepository.findById(firebaseUid).
                orElseThrow(()-> new CustomException(ErrorCode.USER_NOT_FOUND));

        List<Notice> notices = noticeRepository.findAllByOrderByCreatedAtDesc();

        List<NoticeRead> reads = noticeReadRepository.findAllByUser(user);
        //사용자가 읽은 공지 ID 목록
        Set<Long> readNoticeIds = reads.stream()
                .map(nr -> nr.getNotice().getId())
                .collect(Collectors.toSet());

        //공지사항 리스트를 dto로 변환하면서 읽음 여부 판단
        return notices.stream()
                .map(notice -> new NoticeResponseDto(
                        notice,
                        readNoticeIds.contains(notice.getId())
                ))
                .toList();
    }

    @Transactional
    public void markAsRead(String firebaseUid, Long noticeId) {
        // 1. 사용자 조회
        User user = userRepository.findById(firebaseUid)
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 2. 공지사항 존재 여부 확인
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOTICE_NOT_FOUND));

        // 3. 이미 읽었는지 체크
        boolean alreadyRead = noticeReadRepository.existsByUserAndNotice(user, notice);
        if (alreadyRead) {
            throw new CustomException(ErrorCode.ALREADY_READ);
        }

        // 4. 읽음 기록 저장
        NoticeRead noticeRead = new NoticeRead();
        noticeRead.setUser(user);
        noticeRead.setNotice(notice);
        noticeRead.setReadAt(LocalDateTime.now());

        noticeReadRepository.save(noticeRead);
    }
}
