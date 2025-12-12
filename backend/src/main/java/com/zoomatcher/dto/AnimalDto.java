package com.zoomatcher.dto;

import com.zoomatcher.model.Animal;
import lombok.Data;

import java.time.LocalDate;
import java.util.Set;
import java.util.stream.Collectors;

@Data
public class AnimalDto {
    private Long id;
    private String name;
    private Animal.Gender gender;
    private LocalDate dateOfBirth;
    private String description;
    private String photoUrl;
    private Boolean readyForPairing;
    private Long speciesId;
    private String speciesName;
    private Long zooId;
    private String zooName;
    private Long ownerId;
    private String ownerName;
    private Set<Long> diseaseIds;
    private Set<String> diseaseNames;
    
    public static AnimalDto fromEntity(Animal animal) {
        AnimalDto dto = new AnimalDto();
        dto.setId(animal.getId());
        dto.setName(animal.getName());
        dto.setGender(animal.getGender());
        dto.setDateOfBirth(animal.getDateOfBirth());
        dto.setDescription(animal.getDescription());
        dto.setPhotoUrl(animal.getPhotoUrl());
        dto.setReadyForPairing(animal.getReadyForPairing());
        
        if (animal.getSpecies() != null) {
            dto.setSpeciesId(animal.getSpecies().getId());
            dto.setSpeciesName(animal.getSpecies().getName());
        }
        
        if (animal.getZoo() != null) {
            dto.setZooId(animal.getZoo().getId());
            dto.setZooName(animal.getZoo().getName());
            if (animal.getZoo().getCountry() != null) {
                // Можно добавить поля страны в DTO если нужно
            }
        }
        
        if (animal.getOwner() != null) {
            dto.setOwnerId(animal.getOwner().getId());
            dto.setOwnerName(animal.getOwner().getUsername());
        }
        
        if (animal.getDiseases() != null) {
            dto.setDiseaseIds(animal.getDiseases().stream()
                .map(d -> d.getId())
                .collect(Collectors.toSet()));
            dto.setDiseaseNames(animal.getDiseases().stream()
                .map(d -> d.getName())
                .collect(Collectors.toSet()));
        }
        
        return dto;
    }
}

