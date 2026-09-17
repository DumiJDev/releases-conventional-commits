package io.github.dumijdev.release_convetional_commits.controllers;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

class TodayControllerTest {

    @Test
    void today() {
        var todayController = new TodayController();
        var result = todayController.today();
        Assertions.assertEquals("Today is: " + java.time.LocalDate.now(), result);
}
    
}
