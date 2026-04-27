package com.controller;

import com.annotation.IgnoreAuth;
import com.utils.R;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * 心理咨询师功能已下线，占位接口统一返回提示
 */
@RestController
@RequestMapping("/xinlizixunshi")
public class XinlizixunshiController {

    private static final String OFFLINE_MSG = "咨询师功能已下线";

    private R offline() {
        return R.error(410, OFFLINE_MSG);
    }

    @RequestMapping("/page")
    public R page(@RequestParam Map<String, Object> params, HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/info/{id}")
    public R info(HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/save")
    public R save(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/update")
    public R update(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/delete")
    public R delete(@RequestBody Integer[] ids) {
        return offline();
    }

    @RequestMapping("/batchInsert")
    public R batchInsert(String fileName, HttpServletRequest request) {
        return offline();
    }

    @IgnoreAuth
    @RequestMapping(value = "/login")
    public R login(String username, String password, String captcha, HttpServletRequest request) {
        return offline();
    }

    @IgnoreAuth
    @PostMapping(value = "/register")
    public R register(@RequestBody Map<String, Object> body) {
        return offline();
    }

    @GetMapping(value = "/resetPassword")
    public R resetPassword(Integer id) {
        return offline();
    }

    @IgnoreAuth
    @RequestMapping(value = "/resetPass")
    public R resetPass(String username, HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/session")
    public R session(HttpServletRequest request) {
        return offline();
    }

    @GetMapping(value = "logout")
    public R logout(HttpServletRequest request) {
        return offline();
    }

    @IgnoreAuth
    @RequestMapping("/list")
    public R list(@RequestParam Map<String, Object> params, HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/detail/{id}")
    public R detail(HttpServletRequest request) {
        return offline();
    }

    @RequestMapping("/add")
    public R add(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        return offline();
    }
}
