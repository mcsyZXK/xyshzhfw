package com.utils;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * JWT 工具类
 */
public class JwtUtil {

    // 密钥
    private static final String SECRET_KEY = "xiaoyuanzonghefuwu_secret_key_2024";
    
    // 过期时间（毫秒）- 7 天
    private static final long EXPIRATION_TIME = 7 * 24 * 60 * 60 * 1000;

    /**
     * 生成 JWT Token
     */
    public static String generateToken(Integer userId, String username, String role, String tableName) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", userId);
        claims.put("username", username);
        claims.put("role", role);
        claims.put("tableName", tableName);
        
        return Jwts.builder()
                .setClaims(claims)
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(SignatureAlgorithm.HS512, SECRET_KEY)
                .compact();
    }

    /**
     * 验证 JWT Token
     */
    public static Claims verifyToken(String token) {
        try {
            return Jwts.parser()
                    .setSigningKey(SECRET_KEY)
                    .parseClaimsJws(token)
                    .getBody();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * 从 Token 中获取用户 ID
     */
    public static Integer getUserIdFromToken(String token) {
        Claims claims = verifyToken(token);
        if (claims != null) {
            return (Integer) claims.get("userId");
        }
        return null;
    }

    /**
     * 从 Token 中获取用户名
     */
    public static String getUsernameFromToken(String token) {
        Claims claims = verifyToken(token);
        if (claims != null) {
            return (String) claims.get("username");
        }
        return null;
    }

    /**
     * 从 Token 中获取角色
     */
    public static String getRoleFromToken(String token) {
        Claims claims = verifyToken(token);
        if (claims != null) {
            return (String) claims.get("role");
        }
        return null;
    }

    /**
     * 从 Token 中获取表名
     */
    public static String getTableNameFromToken(String token) {
        Claims claims = verifyToken(token);
        if (claims != null) {
            return (String) claims.get("tableName");
        }
        return null;
    }

    /**
     * 判断 Token 是否过期
     */
    public static boolean isTokenExpired(String token) {
        Claims claims = verifyToken(token);
        if (claims != null) {
            return claims.getExpiration().before(new Date());
        }
        return true;
    }

    /**
     * 刷新 Token
     */
    public static String refreshToken(String token) {
        Claims claims = verifyToken(token);
        if (claims != null) {
            return generateToken(
                    (Integer) claims.get("userId"),
                    (String) claims.get("username"),
                    (String) claims.get("role"),
                    (String) claims.get("tableName")
            );
        }
        return null;
    }
}