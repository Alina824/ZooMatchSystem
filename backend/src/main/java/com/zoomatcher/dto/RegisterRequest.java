package com.zoomatcher.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank
    private String username;
    
    @NotBlank
    private String password;
    
    private String firstName;
    private String lastName;
    private Long zooId;
}

