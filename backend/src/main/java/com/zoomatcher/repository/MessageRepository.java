package com.zoomatcher.repository;

import com.zoomatcher.model.Message;
import com.zoomatcher.model.PairingRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByPairingRequestOrderByCreatedAtAsc(PairingRequest pairingRequest);
}



