package com.shhtudy.backend.domain.message.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(description = "쪽지 전송 요청 DTO")
public class MessageSendRequestDto {
    @Schema(description = "쪽지 내용 (최대 300자)", example = "조용히 부탁드립니다.")
    @NotBlank(message = "내용은 비어 있을 수 없습니다.")
    @Size(max = 300, message = "쪽지 내용은 최대 300자까지 허용됩니다.")
    private String content;
}
