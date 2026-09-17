package io.github.dumijdev.release_convetional_commits.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String hello() {
        return "Welcome to Release Conventional Commits Application!";
    }
}
