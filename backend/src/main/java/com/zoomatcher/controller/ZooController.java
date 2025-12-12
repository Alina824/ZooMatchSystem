package com.zoomatcher.controller;

import com.zoomatcher.model.Zoo;
import com.zoomatcher.repository.ZooRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/zoos")
public class ZooController {
    
    @Autowired
    private ZooRepository zooRepository;
    
    @GetMapping
    public ResponseEntity<List<Zoo>> getAllZoos() {
        return ResponseEntity.ok(zooRepository.findAll());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Zoo> getZooById(@PathVariable Long id) {
        return zooRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}



