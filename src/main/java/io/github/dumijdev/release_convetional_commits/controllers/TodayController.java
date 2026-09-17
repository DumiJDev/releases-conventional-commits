package io.github.dumijdev.release_convetional_commits.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TodayController {
    @GetMapping("/today")
    public String today() {
        return "Today is: " + java.time.LocalDate.now();
    }
}
