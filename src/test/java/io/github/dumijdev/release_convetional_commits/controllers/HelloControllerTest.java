package io.github.dumijdev.release_convetional_commits.controllers;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

/**
 * HelloControllerTest
 */
public class HelloControllerTest {

    @Test 
    void testHello() {
        HelloController helloController = new HelloController();
        String result = helloController.hello();
        Assertions.assertEquals("Welcome to Release Conventional Commits Application!", result);
    }
}