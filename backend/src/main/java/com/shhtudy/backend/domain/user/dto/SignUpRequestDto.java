package com.shhtudy.backend.domain.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SignUpRequestDto {

    @Schema(description = "이름", example = "홍길동")
    @NotBlank(message = "이름은 필수입니다.")
    private String name;

    @Schema(description = "닉네임", example = "Hong123")
    @Size(min=2, message = "닉네임은 필수입니다.")
    private String nickname;

    @Schema(description = "전화번호", example = "01011111111@fakeuser.test")
    @NotBlank(message = "전화번호는 필수입니다.")
    private String phoneNumber;

    @Schema(description = "비밀번호", example = "testpassword")
    @Size(min = 6, message = "비밀번호는 최소 6자리 이상이어야 합니다.")
    private String password;

    @Schema(description = "비밀번호 확인", example = "testpassword")
    @Size(min = 6, message = "비밀번호 확인은 최소 6자리 이상이어야 합니다.")
    private String confirmPassword;

}
