package com.zoomatcher.dto;

import com.zoomatcher.model.PairingRequest;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PairingRequestDto {
    private Long id;
    private AnimalDto fromAnimal;
    private AnimalDto toAnimal;
    private Long senderId;
    private String senderName;
    private PairingRequest.RequestStatus status;
    private Boolean recipientApproved;
    private Boolean organizationApproved;
    private Long approverId;
    private String approverName;
    private String message;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    public static PairingRequestDto fromEntity(PairingRequest request) {
        PairingRequestDto dto = new PairingRequestDto();
        dto.setId(request.getId());
        dto.setFromAnimal(AnimalDto.fromEntity(request.getFromAnimal()));
        dto.setToAnimal(AnimalDto.fromEntity(request.getToAnimal()));
        dto.setSenderId(request.getSender().getId());
        dto.setSenderName(request.getSender().getUsername());
        dto.setStatus(request.getStatus());
        dto.setRecipientApproved(request.getRecipientApproved());
        dto.setOrganizationApproved(request.getOrganizationApproved());
        if (request.getApprover() != null) {
            dto.setApproverId(request.getApprover().getId());
            dto.setApproverName(request.getApprover().getUsername());
        }
        dto.setMessage(request.getMessage());
        dto.setCreatedAt(request.getCreatedAt());
        dto.setUpdatedAt(request.getUpdatedAt());
        return dto;
    }
}



