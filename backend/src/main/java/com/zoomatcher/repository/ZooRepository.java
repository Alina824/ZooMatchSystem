package com.zoomatcher.repository;

import com.zoomatcher.model.Zoo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ZooRepository extends JpaRepository<Zoo, Long> {
    Optional<Zoo> findByName(String name);
}



