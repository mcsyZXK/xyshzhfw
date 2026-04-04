package com.config;

import com.interceptor.AuthorizationInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import java.io.File;
import java.nio.file.Paths;

/**
 * Web MVC 配置
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Autowired
    private AuthorizationInterceptor authorizationInterceptor;

    @Value("${upload.path:upload/}")
    private String uploadPath;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(authorizationInterceptor)
                .addPathPatterns("/**")
                .excludePathPatterns(
                    "/resources/**",
                    "/upload/**",
                    "/login",
                    "/register",
                    "/resetPass",
                    "/file/download",
                    "/admin/auto"
                );
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        File uploadDir = Paths.get(uploadPath).toAbsolutePath().normalize().toFile();
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        String uploadAbsolutePath = uploadDir.getAbsolutePath().replace("\\", "/");
        if (!uploadAbsolutePath.endsWith("/")) {
            uploadAbsolutePath = uploadAbsolutePath + "/";
        }
        String uploadLocation = "file:" + uploadAbsolutePath;
        registry.addResourceHandler("/upload/**")
                .addResourceLocations(uploadLocation);
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("classpath:/static/");
    }
}
