package com.shhtudy.backend.global.util;

import com.shhtudy.backend.domain.seat.entity.Seat;
import com.shhtudy.backend.domain.user.entity.User;

public class UserDisplayUtil {
    public static String getDisplayName(User user) {
        String nickname = user.getNickname();
        Seat seat = user.getCurrentSeat();
        return seat != null
                ? seat.getLocationCode() + "번 (" + nickname + ")"
                : "퇴실한 사용자 (" + nickname + ")";
    }
}
