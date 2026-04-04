package com.websocket;

import com.alibaba.fastjson.JSONObject;
import com.entity.TokenEntity;
import com.entity.WupinEntity;
import com.service.TokenService;
import com.service.WupinService;
import com.utils.SpringContextUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * 二手交易实时沟通 WebSocket
 * 连接地址: /ws/wupin-chat?token=xxx&wupinId=1
 */
@Component
@ServerEndpoint(value = "/ws/wupin-chat")
public class WupinChatWebSocket {

    private static final Logger logger = LoggerFactory.getLogger(WupinChatWebSocket.class);
    private static final ConcurrentHashMap<String, Session> SESSION_MAP = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, ClientMeta> SESSION_META_MAP = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<Integer, CopyOnWriteArraySet<String>> ROOM_SESSION_MAP = new ConcurrentHashMap<>();
    private static final SimpleDateFormat TIME_FORMAT = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    @OnOpen
    public void onOpen(Session session) {
        try {
            Map<String, String> queryParams = parseQueryString(session.getQueryString());
            String token = queryParams.get("token");
            Integer wupinId = parseInteger(queryParams.get("wupinId"));
            if (StringUtils.isBlank(token) || wupinId == null) {
                sendErrorAndClose(session, "连接参数不完整");
                return;
            }

            TokenService tokenService = SpringContextUtils.getBean("tokenService", TokenService.class);
            WupinService wupinService = SpringContextUtils.getBean("wupinService", WupinService.class);
            TokenEntity tokenEntity = tokenService.getTokenEntity(token);
            if (tokenEntity == null) {
                sendErrorAndClose(session, "登录已过期，请重新登录");
                return;
            }

            WupinEntity wupin = wupinService.selectById(wupinId);
            if (wupin == null || Integer.valueOf(2).equals(wupin.getWupinDelete())) {
                sendErrorAndClose(session, "物品不存在或已下架");
                return;
            }

            ClientMeta clientMeta = new ClientMeta();
            clientMeta.setSessionId(session.getId());
            clientMeta.setUserId(tokenEntity.getUserid());
            clientMeta.setUsername(StringUtils.defaultIfBlank(tokenEntity.getUsername(), "用户" + tokenEntity.getUserid()));
            clientMeta.setRole(tokenEntity.getRole());
            clientMeta.setWupinId(wupinId);

            SESSION_MAP.put(session.getId(), session);
            SESSION_META_MAP.put(session.getId(), clientMeta);
            ROOM_SESSION_MAP.computeIfAbsent(wupinId, key -> new CopyOnWriteArraySet<>()).add(session.getId());

            JSONObject connected = new JSONObject();
            connected.put("type", "connected");
            connected.put("wupinId", wupinId);
            connected.put("userId", tokenEntity.getUserid());
            connected.put("time", TIME_FORMAT.format(new Date()));
            sendText(session, connected.toJSONString());

            broadcastSystemMessage(wupinId, clientMeta.getUsername() + " 进入了实时沟通");
            logger.info("WebSocket connected. sessionId={}, userId={}, wupinId={}", session.getId(), tokenEntity.getUserid(), wupinId);
        } catch (Exception e) {
            logger.error("WebSocket onOpen error", e);
            closeQuietly(session);
        }
    }

    @OnMessage
    public void onMessage(String rawMessage, Session session) {
        ClientMeta meta = SESSION_META_MAP.get(session.getId());
        if (meta == null) {
            closeQuietly(session);
            return;
        }
        try {
            JSONObject requestJson = JSONObject.parseObject(rawMessage);
            String content = StringUtils.trimToEmpty(requestJson.getString("content"));
            if (StringUtils.isBlank(content)) {
                sendError(session, "消息不能为空");
                return;
            }

            JSONObject payload = new JSONObject();
            payload.put("type", "chat");
            payload.put("wupinId", meta.getWupinId());
            payload.put("senderUserId", meta.getUserId());
            payload.put("senderName", meta.getUsername());
            payload.put("senderRole", meta.getRole());
            payload.put("content", content);
            payload.put("sendTime", TIME_FORMAT.format(new Date()));
            logger.info("WebSocket chat message. sessionId={}, userId={}, wupinId={}, contentLength={}",
                    session.getId(), meta.getUserId(), meta.getWupinId(), content.length());
            broadcastToRoom(meta.getWupinId(), payload.toJSONString());
        } catch (Exception e) {
            logger.error("WebSocket onMessage error. sessionId={}", session.getId(), e);
            sendError(session, "消息格式错误");
        }
    }

    @OnClose
    public void onClose(Session session) {
        ClientMeta meta = removeSession(session.getId());
        if (meta != null) {
            broadcastSystemMessage(meta.getWupinId(), meta.getUsername() + " 离开了实时沟通");
            logger.info("WebSocket closed. sessionId={}, userId={}, wupinId={}", session.getId(), meta.getUserId(), meta.getWupinId());
        }
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        logger.error("WebSocket error. sessionId={}", session == null ? null : session.getId(), throwable);
        if (session != null) {
            removeSession(session.getId());
            closeQuietly(session);
        }
    }

    private void broadcastSystemMessage(Integer wupinId, String message) {
        JSONObject payload = new JSONObject();
        payload.put("type", "system");
        payload.put("wupinId", wupinId);
        payload.put("content", message);
        payload.put("sendTime", TIME_FORMAT.format(new Date()));
        broadcastToRoom(wupinId, payload.toJSONString());
    }

    private void broadcastToRoom(Integer wupinId, String message) {
        Set<String> sessionIds = ROOM_SESSION_MAP.get(wupinId);
        if (sessionIds == null || sessionIds.isEmpty()) {
            return;
        }
        for (String sessionId : sessionIds) {
            Session targetSession = SESSION_MAP.get(sessionId);
            if (targetSession == null || !targetSession.isOpen()) {
                removeSession(sessionId);
                continue;
            }
            sendText(targetSession, message);
        }
    }

    private ClientMeta removeSession(String sessionId) {
        SESSION_MAP.remove(sessionId);
        ClientMeta meta = SESSION_META_MAP.remove(sessionId);
        if (meta == null) {
            return null;
        }
        CopyOnWriteArraySet<String> sessionIds = ROOM_SESSION_MAP.get(meta.getWupinId());
        if (sessionIds != null) {
            sessionIds.remove(sessionId);
            if (sessionIds.isEmpty()) {
                ROOM_SESSION_MAP.remove(meta.getWupinId());
            }
        }
        return meta;
    }

    private void sendErrorAndClose(Session session, String message) {
        sendError(session, message);
        closeQuietly(session);
    }

    private void sendError(Session session, String message) {
        JSONObject payload = new JSONObject();
        payload.put("type", "error");
        payload.put("message", message);
        payload.put("sendTime", TIME_FORMAT.format(new Date()));
        sendText(session, payload.toJSONString());
    }

    private void sendText(Session session, String message) {
        if (session != null && session.isOpen()) {
            synchronized (session) {
                try {
                    session.getBasicRemote().sendText(message);
                } catch (Exception e) {
                    logger.warn("WebSocket sendText failed. sessionId={}", session.getId(), e);
                    closeQuietly(session);
                }
            }
        }
    }

    private void closeQuietly(Session session) {
        try {
            if (session != null && session.isOpen()) {
                session.close();
            }
        } catch (Exception ignored) {
        }
    }

    private Integer parseInteger(String value) {
        if (StringUtils.isBlank(value)) {
            return null;
        }
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Map<String, String> parseQueryString(String queryString) {
        Map<String, String> result = new HashMap<>();
        if (StringUtils.isBlank(queryString)) {
            return result;
        }
        String[] pairs = queryString.split("&");
        for (String pair : pairs) {
            if (StringUtils.isBlank(pair)) {
                continue;
            }
            try {
                String[] keyValue = pair.split("=", 2);
                String key = URLDecoder.decode(keyValue[0], StandardCharsets.UTF_8.name());
                String value = keyValue.length > 1
                        ? URLDecoder.decode(keyValue[1], StandardCharsets.UTF_8.name())
                        : "";
                result.put(key, value);
            } catch (Exception ignored) {
            }
        }
        return result;
    }

    private static class ClientMeta {
        private String sessionId;
        private Integer userId;
        private String username;
        private String role;
        private Integer wupinId;

        public String getSessionId() {
            return sessionId;
        }

        public void setSessionId(String sessionId) {
            this.sessionId = sessionId;
        }

        public Integer getUserId() {
            return userId;
        }

        public void setUserId(Integer userId) {
            this.userId = userId;
        }

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getRole() {
            return role;
        }

        public void setRole(String role) {
            this.role = role;
        }

        public Integer getWupinId() {
            return wupinId;
        }

        public void setWupinId(Integer wupinId) {
            this.wupinId = wupinId;
        }
    }
}
