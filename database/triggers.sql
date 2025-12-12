

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_pairing_requests_updated_at
    BEFORE UPDATE ON pairing_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE TRIGGER update_role_requests_updated_at
    BEFORE UPDATE ON role_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


CREATE OR REPLACE FUNCTION check_animals_ready_before_request()
RETURNS TRIGGER AS $$
DECLARE
    v_from_ready BOOLEAN;
    v_to_ready BOOLEAN;
BEGIN
    SELECT ready_for_pairing INTO v_from_ready
    FROM animals
    WHERE id = NEW.from_animal_id;
    
    IF NOT v_from_ready THEN
        RAISE EXCEPTION 'Животное-отправитель не готово к составлению пары';
    END IF;
    
    SELECT ready_for_pairing INTO v_to_ready
    FROM animals
    WHERE id = NEW.to_animal_id;
    
    IF NOT v_to_ready THEN
        RAISE EXCEPTION 'Животное-получатель не готово к составлению пары';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_animals_ready_on_insert
    BEFORE INSERT ON pairing_requests
    FOR EACH ROW
    EXECUTE FUNCTION check_animals_ready_before_request();

CREATE OR REPLACE FUNCTION auto_update_request_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.recipient_approved = TRUE AND NEW.organization_approved = TRUE THEN
        IF NEW.status != 'APPROVED' THEN
            NEW.status := 'APPROVED';
            UPDATE animals SET ready_for_pairing = FALSE WHERE id = NEW.from_animal_id;
            UPDATE animals SET ready_for_pairing = FALSE WHERE id = NEW.to_animal_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER auto_update_request_status_trigger
    BEFORE UPDATE ON pairing_requests
    FOR EACH ROW
    WHEN (OLD.recipient_approved IS DISTINCT FROM NEW.recipient_approved OR
          OLD.organization_approved IS DISTINCT FROM NEW.organization_approved)
    EXECUTE FUNCTION auto_update_request_status();

CREATE OR REPLACE FUNCTION check_unique_active_request()
RETURNS TRIGGER AS $$
DECLARE
    v_existing_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_existing_count
    FROM pairing_requests
    WHERE from_animal_id = NEW.from_animal_id
      AND to_animal_id = NEW.to_animal_id
      AND status != 'REJECTED'
      AND id != COALESCE(NEW.id, 0);
    
    IF v_existing_count > 0 THEN
        RAISE EXCEPTION 'Уже существует активная заявка для этой пары животных';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_unique_active_request_on_insert
    BEFORE INSERT ON pairing_requests
    FOR EACH ROW
    EXECUTE FUNCTION check_unique_active_request();

CREATE OR REPLACE TRIGGER check_unique_active_request_on_update
    BEFORE UPDATE ON pairing_requests
    FOR EACH ROW
    WHEN (OLD.status = 'REJECTED' AND NEW.status != 'REJECTED')
    EXECUTE FUNCTION check_unique_active_request();

CREATE OR REPLACE FUNCTION check_animal_zoo_consistency()
RETURNS TRIGGER AS $$
DECLARE
    v_owner_zoo_id BIGINT;
BEGIN
    SELECT zoo_id INTO v_owner_zoo_id
    FROM users
    WHERE id = NEW.owner_id;
    
    IF v_owner_zoo_id IS NOT NULL AND v_owner_zoo_id != NEW.zoo_id THEN
        RAISE EXCEPTION 'Животное должно принадлежать зоопарку владельца';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_animal_zoo_consistency_trigger
    BEFORE INSERT OR UPDATE ON animals
    FOR EACH ROW
    EXECUTE FUNCTION check_animal_zoo_consistency();

CREATE OR REPLACE FUNCTION check_different_animals()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.from_animal_id = NEW.to_animal_id THEN
        RAISE EXCEPTION 'Нельзя создать заявку на одно и то же животное';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_different_animals_trigger
    BEFORE INSERT OR UPDATE ON pairing_requests
    FOR EACH ROW
    EXECUTE FUNCTION check_different_animals();

CREATE OR REPLACE FUNCTION validate_request_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'APPROVED' THEN
        IF NOT (NEW.recipient_approved = TRUE AND NEW.organization_approved = TRUE) THEN
            RAISE EXCEPTION 'Заявка не может быть одобрена без обоих одобрений';
        END IF;
    END IF;
    
    IF OLD.status = 'REJECTED' AND NEW.status != 'REJECTED' THEN
        RAISE EXCEPTION 'Нельзя изменить статус отклоненной заявки';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER validate_request_status_trigger
    BEFORE UPDATE ON pairing_requests
    FOR EACH ROW
    EXECUTE FUNCTION validate_request_status();


