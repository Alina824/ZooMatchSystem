package com.zoomatcher.dto;

import com.zoomatcher.model.Message;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class MessageDto {
    private Long id;
    private Long pairingRequestId;
    private Long senderId;
    private String senderName;
    private String content;
    private LocalDateTime createdAt;
    
    public static MessageDto fromEntity(Message message) {
        MessageDto dto = new MessageDto();
        dto.setId(message.getId());
        dto.setPairingRequestId(message.getPairingRequest().getId());
        dto.setSenderId(message.getSender().getId());
        dto.setSenderName(message.getSender().getUsername());
        dto.setContent(message.getContent());
        dto.setCreatedAt(message.getCreatedAt());
        return dto;
    }
}



