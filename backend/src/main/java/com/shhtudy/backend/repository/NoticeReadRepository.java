package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Notice;
import com.shhtudy.backend.entity.NoticeRead;
import com.shhtudy.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NoticeReadRepository extends JpaRepository<NoticeRead, Long> {
    @Query("SELECT COUNT(n) > 0 FROM Notice n WHERE n.id NOT IN (" +
            "SELECT nr.notice.id FROM NoticeRead nr WHERE nr.user.firebaseUid = :userId)")
    boolean existsUnreadNotices(@Param("userId") String userId);

    List<NoticeRead> findAllByUser(User user);

    boolean existsByUserAndNotice(User user, Notice notice);
}
