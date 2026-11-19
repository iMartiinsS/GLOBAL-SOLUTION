package br.com.fiap.alagalerta;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class AlagalertaApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(AlagalertaApiApplication.class, args);
    }
}
