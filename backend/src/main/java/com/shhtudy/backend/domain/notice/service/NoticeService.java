package com.shhtudy.backend.domain.notice.service;

import com.shhtudy.backend.domain.notice.dto.MyPageNoticeDto;
import com.shhtudy.backend.domain.notice.dto.MyPageNoticesResponseDto;
import com.shhtudy.backend.domain.notice.dto.NoticeResponseDto;
import com.shhtudy.backend.domain.notice.dto.NoticeListResponseDto;
import com.shhtudy.backend.domain.notice.entity.Notice;
import com.shhtudy.backend.domain.notice.entity.NoticeRead;
import com.shhtudy.backend.global.exception.CustomException;
import com.shhtudy.backend.global.exception.code.ErrorCode;
import com.shhtudy.backend.domain.notice.repository.NoticeReadRepository;
import com.shhtudy.backend.domain.notice.repository.NoticeRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.transaction.annotation.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NoticeService {
    private final NoticeRepository noticeRepository;
    private final NoticeReadRepository noticeReadRepository;

    @Transactional
    public Page<NoticeListResponseDto> getAllNotices(String firebaseUid, Pageable pageable) {
        Pageable sortedPageable = PageRequest.of(
                pageable.getPageNumber(),
                pageable.getPageSize(),
                Sort.by("createdAt").descending()
        );

        Page<Notice> notices = noticeRepository.findAll(sortedPageable);

        List<NoticeRead> reads = noticeReadRepository.findAllByUserId(firebaseUid);
        Set<Long> readNoticeIds = reads.stream()
                .map(nr -> nr.getNotice().getId())
                .collect(Collectors.toSet());

        List<NoticeRead> unreadReads = notices.getContent().stream()
                .filter(notice -> !readNoticeIds.contains(notice.getId()))
                .map(notice -> NoticeRead.builder()
                        .notice(notice)
                        .userId(firebaseUid)
                        .build())
                .toList();

        noticeReadRepository.saveAll(unreadReads);

        return notices.map(notice ->
                new NoticeListResponseDto(
                        notice,
                        readNoticeIds.contains(notice.getId())
                )
        );
    }

    @Transactional
    public NoticeResponseDto getNoticeDetail(Long noticeId, String firebaseUid) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOTICE_NOT_FOUND));

        boolean isAlreadyRead = noticeReadRepository.existsByUserIdAndNotice_Id(firebaseUid, noticeId);

        if (!isAlreadyRead) {
            noticeReadRepository.save(
                    NoticeRead.builder()
                            .userId(firebaseUid)
                            .notice(notice)
                            .build()
            );
        }

        return NoticeResponseDto.builder()
                .title(notice.getTitle())
                .content(notice.getContent())
                .createdAt(notice.getCreatedAt())
                .build();
    }

    @Transactional(readOnly = true)
    public MyPageNoticesResponseDto getUnreadNoticeForMyPage(String firebaseUid) {
        int unreadCount = noticeReadRepository.countUnreadByUserId(firebaseUid);

        List<Notice> recentUnreadNotices = noticeRepository.findUnreadByUserId(
                firebaseUid,
                PageRequest.of(0, 2, Sort.by(Sort.Direction.DESC, "createdAt"))
        );

        List<MyPageNoticeDto> noticeDtos = recentUnreadNotices.stream()
                .map(notice -> new MyPageNoticeDto(notice, false))
                .toList();

        return new MyPageNoticesResponseDto(unreadCount, noticeDtos);
    }
}
