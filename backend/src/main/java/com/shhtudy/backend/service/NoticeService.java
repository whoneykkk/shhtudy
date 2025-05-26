package com.shhtudy.backend.service;

import com.shhtudy.backend.dto.NoticeResponseDto;
import com.shhtudy.backend.dto.NoticeSummaryResponseDto;
import com.shhtudy.backend.entity.Notice;
import com.shhtudy.backend.entity.NoticeRead;
import com.shhtudy.backend.exception.CustomException;
import com.shhtudy.backend.exception.code.ErrorCode;
import com.shhtudy.backend.repository.NoticeReadRepository;
import com.shhtudy.backend.repository.NoticeRepository;
import com.shhtudy.backend.repository.UserRepository;
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
    public Page<NoticeSummaryResponseDto> getAllNotices(String userId, Pageable pageable) {
        Pageable sortedPageable = PageRequest.of(
                pageable.getPageNumber(),
                pageable.getPageSize(),
                Sort.by("createdAt").descending()
        );

        Page<Notice> notices = noticeRepository.findAll(sortedPageable);

        List<NoticeRead> reads = noticeReadRepository.findAllByUserId(userId);
        Set<Long> readNoticeIds = reads.stream()
                .map(nr -> nr.getNotice().getId())
                .collect(Collectors.toSet());

        List<NoticeRead> unreadReads = notices.getContent().stream()
                .filter(notice -> !readNoticeIds.contains(notice.getId()))
                .map(notice -> NoticeRead.builder()
                        .notice(notice)
                        .userId(userId)
                        .build())
                .toList();

        noticeReadRepository.saveAll(unreadReads);

        return notices.map(notice ->
                new NoticeSummaryResponseDto(
                        notice,
                        readNoticeIds.contains(notice.getId())
                )
        );
    }

    @Transactional
    public NoticeResponseDto getNoticeDetail(Long noticeId, String userId) {
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new CustomException(ErrorCode.NOTICE_NOT_FOUND));

        boolean isAlreadyRead = noticeReadRepository.existsByUserIdAndNotice_Id(userId, noticeId);

        if (!isAlreadyRead) {
            noticeReadRepository.save(
                    NoticeRead.builder()
                            .userId(userId)
                            .notice(notice)
                            .build()
            );
        }

        return NoticeResponseDto.builder()
                .title(notice.getTitle())
                .content(notice.getContent())
                .createdAt(notice.getCreatedAt().toString())
                .build();
    }

}
