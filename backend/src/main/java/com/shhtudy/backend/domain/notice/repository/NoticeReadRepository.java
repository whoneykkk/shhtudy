package com.shhtudy.backend.domain.notice.repository;

import com.shhtudy.backend.domain.notice.entity.NoticeRead;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NoticeReadRepository extends JpaRepository<NoticeRead, Long> {

    @Query("SELECT COUNT(n) > 0 FROM Notice n WHERE n.id NOT IN (" +
            "SELECT nr.notice.id FROM NoticeRead nr WHERE nr.userId = :userId)")
    boolean existsUnreadNotices(@Param("userId") String userId);

    List<NoticeRead> findAllByUserId(String userId);

    boolean existsByUserIdAndNotice_Id(String userId, Long noticeId);
}
