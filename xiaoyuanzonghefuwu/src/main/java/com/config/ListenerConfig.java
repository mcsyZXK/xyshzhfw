package com.config;

import com.ServletContextListener.DictionaryServletContextListener;
import org.springframework.boot.web.servlet.ServletListenerRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Servlet 监听器注册
 */
@Configuration
public class ListenerConfig {

    @Bean
    public ServletListenerRegistrationBean<DictionaryServletContextListener> dictionaryServletContextListenerRegistration() {
        return new ServletListenerRegistrationBean<>(new DictionaryServletContextListener());
    }
}

