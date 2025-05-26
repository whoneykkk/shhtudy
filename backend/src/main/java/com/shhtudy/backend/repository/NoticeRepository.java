package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Notice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NoticeRepository extends JpaRepository<Notice, Long> {
    Page<Notice> findAll(Pageable pageable);
    @Query("""
    SELECT n FROM Notice n
    WHERE n.id NOT IN (
        SELECT nr.notice.id FROM NoticeRead nr WHERE nr.userId = :userId
    )
    ORDER BY n.createdAt DESC
""")
    List<Notice> findUnreadByUserId(@Param("userId") String userId, Pageable pageable);


}
