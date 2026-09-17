package io.github.dumijdev.release_convetional_commits;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;

@SpringBootApplication
public class ReleaseConvetionalCommitsApplication {

	public static void main(String[] args) {
		SpringApplication.run(ReleaseConvetionalCommitsApplication.class, args);
	}


	@GetMapping("/hello")
	public String hello() {
		return "Welcome to Release Conventional Commits Application!";
	}

}
