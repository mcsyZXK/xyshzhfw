package com.interceptor;

import com.alibaba.fastjson.JSONObject;
import com.service.TokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

/**
 * 权限拦截器
 */
@Component
public class AuthorizationInterceptor implements HandlerInterceptor {

    @Autowired
    private TokenService tokenService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 不是方法调用，直接放行
        if (!(handler instanceof HandlerMethod)) {
            return true;
        }

        // 获取请求路径
        String requestURI = request.getRequestURI();
        
        // 放行静态资源和公开接口
        if (requestURI.contains("/resources/") || 
            requestURI.contains("/upload/") ||
            requestURI.contains("/login") || 
            requestURI.contains("/register") ||
            requestURI.contains("/resetPass") ||
            requestURI.contains("/file/download") ||
            requestURI.contains("/admin/auto")) {
            return true;
        }

        // 优先从 Session 获取用户信息
        Object userId = request.getSession().getAttribute("userId");
        if (userId != null) {
            // Session 有效，放行
            return true;
        }

        // Session 无效，尝试从 Token 获取
        String token = request.getHeader("token");
        if (token == null || token.isEmpty()) {
            token = request.getParameter("token");
        }

        if (token != null && !token.isEmpty()) {
            // 验证 Token
            com.entity.TokenEntity tokenEntity = tokenService.getTokenEntity(token);
            if (tokenEntity != null) {
                // Token 有效，将用户信息存入 Session
                request.getSession().setAttribute("userId", tokenEntity.getUserid());
                request.getSession().setAttribute("role", tokenEntity.getRole());
                request.getSession().setAttribute("tableName", tokenEntity.getTablename());
                request.getSession().setAttribute("username", tokenEntity.getUsername());
                return true;
            }
        }

        // 验证失败，返回错误信息
        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();
        result.put("code", 511);
        result.put("msg", "请先登录");
        PrintWriter out = response.getWriter();
        out.print(JSONObject.toJSONString(result));
        out.flush();
        out.close();
        return false;
    }
}