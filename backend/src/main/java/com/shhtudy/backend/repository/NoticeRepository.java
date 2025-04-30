package com.shhtudy.backend.repository;

import com.shhtudy.backend.entity.Notice;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NoticeRepository extends JpaRepository<Notice, Long> {
}
