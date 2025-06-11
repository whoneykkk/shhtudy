package com.shhtudy.backend.global.config;

import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@SecurityScheme(
        name = "FirebaseToken",
        type = SecuritySchemeType.HTTP,
        scheme = "bearer",
        bearerFormat = "JWT",
        description = "Firebase Authentication에서 발급받은 ID 토큰을 입력하세요."
)
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {
        Info info = new Info()
                .title("쉿터디(Shh-tudy) API")
                .description("종합 설계 프로젝트 API 문서입니다.")
                .version("1.0");

        SecurityRequirement firebaseSecurity = new SecurityRequirement().addList("FirebaseToken");

        return new OpenAPI()
                .info(info)
                .addSecurityItem(firebaseSecurity);
    }
}
