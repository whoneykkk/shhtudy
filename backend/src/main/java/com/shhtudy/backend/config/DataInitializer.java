package com.shhtudy.backend.config;

import com.shhtudy.backend.entity.*;
import com.shhtudy.backend.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements ApplicationRunner {
    
    private final SeatRepository seatRepository;
    private final NoticeRepository noticeRepository;
    private final MessageRepository messageRepository;

    @Override
    @Transactional
    public void run(ApplicationArguments args) throws Exception {
        log.info("=== 데모 앱 초기 데이터 설정 시작 ===");
        
        // 1. 좌석 데이터 초기화 (기본 상태로만)
        initializeSeats();
        
        // 2. 공지사항 데이터 초기화
        initializeNotices();
        
        // 3. 메시지 데이터 초기화
        initializeMessages();
        
        log.info("=== 데모 앱 초기 데이터 설정 완료 ===");
    }

    /**
     * 좌석 데이터 초기화 (64개 좌석) - 모두 EMPTY 상태로 설정
     * A구역: 16석, B구역: 21석, C구역: 16석, D구역: 11석
     */
    private void initializeSeats() {
        if (seatRepository.count() > 0) {
            log.info("좌석 데이터가 이미 존재합니다. 건너뜁니다.");
            return;
        }
        
        log.info("좌석 데이터 초기화 시작 (기본 상태로 설정)...");
        
        int seatId = 1;
        
        // A구역 좌석 생성 (16개)
        for (int i = 1; i <= 16; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatId++);
            seat.setLocationCode("A-" + i);
            seat.setStatus(Seat.Status.EMPTY); // 모두 빈 좌석으로 설정
            seatRepository.save(seat);
        }
        
        // B구역 좌석 생성 (21개)
        for (int i = 1; i <= 21; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatId++);
            seat.setLocationCode("B-" + i);
            seat.setStatus(Seat.Status.EMPTY); // 모두 빈 좌석으로 설정
            seatRepository.save(seat);
        }
        
        // C구역 좌석 생성 (16개)
        for (int i = 1; i <= 16; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatId++);
            seat.setLocationCode("C-" + i);
            seat.setStatus(Seat.Status.EMPTY); // 모두 빈 좌석으로 설정
            seatRepository.save(seat);
        }
        
        // D구역 좌석 생성 (11개)
        for (int i = 1; i <= 11; i++) {
            Seat seat = new Seat();
            seat.setSeatId(seatId++);
            seat.setLocationCode("D-" + i);
            seat.setStatus(Seat.Status.EMPTY); // 모두 빈 좌석으로 설정
            seatRepository.save(seat);
        }
        
        log.info("좌석 데이터 초기화 완료: 총 {}개 좌석 생성 (모두 빈 좌석 상태)", seatId - 1);
    }

    /**
     * 공지사항 데이터 초기화 (스터디카페 공지사항)
     */
    private void initializeNotices() {
        if (noticeRepository.count() > 0) {
            log.info("공지사항 데이터가 이미 존재합니다. 건너뜁니다.");
            return;
        }
        
        log.info("스터디카페 공지사항 데이터 초기화 시작...");
        
        // 공지사항 1
        Notice notice1 = new Notice();
        notice1.setTitle("🏢 스터디카페 이용 안내");
        notice1.setContent("안녕하세요! shh-tudy 스터디카페를 이용해 주셔서 감사합니다.\n\n" +
                "📋 이용 안내:\n" +
                "• 좌석 선택: 1층 키오스크에서 진행해 주세요\n" +
                "• 앱 기능: 소음 모니터링, 공지확인, 쪽지 등\n" +
                "• 조용한 학습 환경 유지를 위해 협조 부탁드립니다\n\n" +
                "🎯 구역별 특징:\n" +
                "• A구역: 완전 무음 구역 (A등급만 이용 가능)\n" +
                "• B구역: 일반 조용 구역 (A,B등급 이용 가능)\n" +
                "• C,D구역: 일반 구역 (모든 등급 이용 가능)\n\n" +
                "감사합니다! 📚");
        notice1.setCreatedAt(LocalDateTime.now().minusDays(5));
        noticeRepository.save(notice1);
        
        // 공지사항 2
        Notice notice2 = new Notice();
        notice2.setTitle("📊 매너 점수 시스템 안내");
        notice2.setContent("앱을 통한 매너 점수 관리 시스템을 안내드립니다.\n\n" +
                "⭐ 등급 시스템:\n" +
                "• 🏆 A등급(조용함): 700점 이상\n" +
                "• 🥈 B등급(양호): 300-699점  \n" +
                "• ⚠️ C등급(주의): 0-299점\n\n" +
                "📱 앱에서 확인 가능한 정보:\n" +
                "• 실시간 소음 레벨 모니터링\n" +
                "• 나의 평균 데시벨 및 소음 발생 횟수\n" +
                "• 매너 점수 변동 이력\n" +
                "• 소음 레포트 기능\n\n" +
                "조용한 환경 유지에 협조해 주시면 점수가 향상됩니다! 🤫");
        notice2.setCreatedAt(LocalDateTime.now().minusDays(3));
        noticeRepository.save(notice2);
        
        // 공지사항 3
        Notice notice3 = new Notice();
        notice3.setTitle("💬 쪽지 기능 이용 안내");
        notice3.setContent("앱의 쪽지 기능으로 조용하게 소통하세요!\n\n" +
                "📩 사용 방법:\n" +
                "1. 좌석 현황에서 다른 이용자 좌석 클릭\n" +
                "2. 짧은 메시지 작성 후 전송\n" +
                "3. 받은 쪽지는 마이페이지에서 확인\n\n" +
                "⚡ 쪽지 예시:\n" +
                "• '잠시 자리 비워주실 수 있나요?'\n" +
                "• '펜 빌려주실 수 있나요?'\n" +
                "• '조용히 해주세요 ㅠㅠ'\n\n" +
                "🤝 서로 배려하는 마음으로 이용해 주세요!");
        notice3.setCreatedAt(LocalDateTime.now().minusDays(1));
        noticeRepository.save(notice3);
        
        // 공지사항 4 (신규 - 읽지 않음)
        Notice notice4 = new Notice();
        notice4.setTitle("🆕 앱 업데이트 완료!");
        notice4.setContent("shh-tudy 앱이 업데이트되었습니다! 🎉\n\n" +
                "🚀 새로운 기능:\n" +
                "• 실시간 소음 레벨 표시 개선\n" +
                "• 소음 레포트 기능 추가\n" +
                "• 쪽지 기능 안정성 향상\n" +
                "• 매너 점수 상세 분석\n" +
                "• 알림 시스템 개선\n\n" +
                "🎯 향후 계획:\n" +
                "• 그룹 스터디룸 예약 기능\n" +
                "• 학습 타이머 기능\n" +
                "• 이용 통계 분석\n\n" +
                "더욱 편리한 스터디카페 이용을 위해 최선을 다하겠습니다! 💪");
        notice4.setCreatedAt(LocalDateTime.now());
        noticeRepository.save(notice4);
        
        log.info("공지사항 데이터 초기화 완료: 총 4개 공지사항 생성");
    }

    /**
     * 메시지 데이터 초기화 (기본 테스트 메시지만)
     */
    private void initializeMessages() {
        if (messageRepository.count() > 0) {
            log.info("메시지 데이터가 이미 존재합니다. 건너뜁니다.");
            return;
        }
        
        log.info("기본 메시지 데이터 초기화 완료 (실제 데이터는 사용자 활동으로 생성)");
    }
} 