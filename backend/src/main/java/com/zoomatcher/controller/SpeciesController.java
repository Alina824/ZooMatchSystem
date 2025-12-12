package com.zoomatcher.controller;

import com.zoomatcher.model.Species;
import com.zoomatcher.repository.SpeciesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/species")
public class SpeciesController {
    
    @Autowired
    private SpeciesRepository speciesRepository;
    
    @GetMapping
    public ResponseEntity<List<Species>> getAllSpecies() {
        return ResponseEntity.ok(speciesRepository.findAll());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Species> getSpeciesById(@PathVariable Long id) {
        return speciesRepository.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
}



