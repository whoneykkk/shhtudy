package com.shhtudy.backend.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

public class LoginRequestDto {

    @Schema(description = "전화번호", example = "01012345678@fakeuser.test")
    @NotBlank(message = "전화번호는 필수입니다.")
    private String phoneNumber;

    @Schema(description = "비밀번호", example = "testpassword")
    @NotBlank(message = "비밀번호는 필수입니다.")
    private String password;
}
