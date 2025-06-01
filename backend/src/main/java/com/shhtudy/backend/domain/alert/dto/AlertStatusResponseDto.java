package com.shhtudy.backend.domain.alert.dto;

import lombok.Getter;

@Getter
public class AlertStatusResponseDto {
    final private boolean hasUnreadMessages;
    final private String locationCode;

    public AlertStatusResponseDto(boolean hasUnreadMessages, String locationCode) {
        this.hasUnreadMessages = hasUnreadMessages;
        this.locationCode = locationCode;
    }
}
