package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.NoticeRead;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NoticeReadRepository extends JpaRepository<NoticeRead, Long> {
    @Query("SELECT COUNT(n) > 0 FROM Notice n WHERE n.id NOT IN (" +
            "SELECT nr.notice.id FROM NoticeRead nr WHERE nr.user.firebaseUid = :userId)")
    boolean existsUnreadNotices(@Param("userId") String userId);

}
