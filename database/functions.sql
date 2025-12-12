

CREATE OR REPLACE FUNCTION create_animal(
    p_name VARCHAR(255),
    p_gender VARCHAR(255),
    p_date_of_birth DATE,
    p_description VARCHAR(255),
    p_ready_for_pairing BOOLEAN,
    p_species_id BIGINT,
    p_zoo_id BIGINT,
    p_owner_id BIGINT,
    p_disease_ids BIGINT[] DEFAULT ARRAY[]::BIGINT[]
) RETURNS BIGINT AS $$
DECLARE
    v_animal_id BIGINT;
    v_disease_id BIGINT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM species WHERE id = p_species_id) THEN
        RAISE EXCEPTION 'Вид с id % не найден', p_species_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM zoos WHERE id = p_zoo_id) THEN
        RAISE EXCEPTION 'Зоопарк с id % не найден', p_zoo_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_owner_id) THEN
        RAISE EXCEPTION 'Пользователь с id % не найден', p_owner_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_owner_id AND zoo_id = p_zoo_id) THEN
        RAISE EXCEPTION 'Пользователь не прикреплен к указанному зоопарку';
    END IF;
    
    INSERT INTO animals (
        name, gender, date_of_birth, description, 
        ready_for_pairing, species_id, zoo_id, owner_id
    ) VALUES (
        p_name, p_gender, p_date_of_birth, p_description,
        p_ready_for_pairing, p_species_id, p_zoo_id, p_owner_id
    ) RETURNING id INTO v_animal_id;
    
    IF array_length(p_disease_ids, 1) > 0 THEN
        FOREACH v_disease_id IN ARRAY p_disease_ids
        LOOP
            IF EXISTS (SELECT 1 FROM diseases WHERE id = v_disease_id) THEN
                INSERT INTO animal_diseases (animal_id, disease_id)
                VALUES (v_animal_id, v_disease_id)
                ON CONFLICT DO NOTHING;
            END IF;
        END LOOP;
    END IF;
    
    RETURN v_animal_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_animals_by_zoo(p_zoo_id BIGINT)
RETURNS TABLE (
    id BIGINT,
    name VARCHAR(255),
    gender VARCHAR(255),
    date_of_birth DATE,
    description TEXT,
    photo_url VARCHAR(255),
    ready_for_pairing BOOLEAN,
    species_id BIGINT,
    species_name VARCHAR(255),
    zoo_id BIGINT,
    zoo_name VARCHAR(255),
    owner_id BIGINT,
    owner_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.gender,
        a.date_of_birth,
        a.description,
        a.photo_url,
        a.ready_for_pairing,
        s.id AS species_id,
        s.name AS species_name,
        z.id AS zoo_id,
        z.name AS zoo_name,
        u.id AS owner_id,
        COALESCE(u.first_name || ' ' || u.last_name, u.username) AS owner_name
    FROM animals a
    INNER JOIN species s ON a.species_id = s.id
    INNER JOIN zoos z ON a.zoo_id = z.id
    INNER JOIN users u ON a.owner_id = u.id
    WHERE a.zoo_id = p_zoo_id
    ORDER BY a.name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_animals_by_owner(p_owner_id BIGINT)
RETURNS TABLE (
    id BIGINT,
    name VARCHAR(255),
    gender VARCHAR(255),
    date_of_birth DATE,
    description TEXT,
    photo_url VARCHAR(255),
    ready_for_pairing BOOLEAN,
    species_id BIGINT,
    species_name VARCHAR(255),
    zoo_id BIGINT,
    zoo_name VARCHAR(255),
    owner_id BIGINT,
    owner_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a.id,
        a.name,
        a.gender,
        a.date_of_birth,
        a.description,
        a.photo_url,
        a.ready_for_pairing,
        s.id AS species_id,
        s.name AS species_name,
        z.id AS zoo_id,
        z.name AS zoo_name,
        u.id AS owner_id,
        COALESCE(u.first_name || ' ' || u.last_name, u.username) AS owner_name
    FROM animals a
    INNER JOIN species s ON a.species_id = s.id
    INNER JOIN zoos z ON a.zoo_id = z.id
    INNER JOIN users u ON a.owner_id = u.id
    WHERE a.owner_id = p_owner_id
    ORDER BY a.name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_animals_ready_for_pairing(
    p_from_animal_id BIGINT,
    p_to_animal_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_from_ready BOOLEAN;
    v_to_ready BOOLEAN;
BEGIN
    SELECT ready_for_pairing INTO v_from_ready
    FROM animals
    WHERE id = p_from_animal_id;
    
    IF v_from_ready IS NULL THEN
        RAISE EXCEPTION 'Животное-отправитель с id % не найдено', p_from_animal_id;
    END IF;
    
    SELECT ready_for_pairing INTO v_to_ready
    FROM animals
    WHERE id = p_to_animal_id;
    
    IF v_to_ready IS NULL THEN
        RAISE EXCEPTION 'Животное-получатель с id % не найдено', p_to_animal_id;
    END IF;
    
    RETURN v_from_ready AND v_to_ready;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_pairing_request(
    p_from_animal_id BIGINT,
    p_to_animal_id BIGINT,
    p_sender_id BIGINT,
    p_message VARCHAR(255) DEFAULT NULL
) RETURNS BIGINT AS $$
DECLARE
    v_request_id BIGINT;
    v_sender_zoo_id BIGINT;
    v_from_animal_zoo_id BIGINT;
    v_has_active_duplicate BOOLEAN;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM animals WHERE id = p_from_animal_id) THEN
        RAISE EXCEPTION 'Животное-отправитель с id % не найдено', p_from_animal_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM animals WHERE id = p_to_animal_id) THEN
        RAISE EXCEPTION 'Животное-получатель с id % не найдено', p_to_animal_id;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_sender_id) THEN
        RAISE EXCEPTION 'Пользователь с id % не найден', p_sender_id;
    END IF;
    
    IF NOT check_animals_ready_for_pairing(p_from_animal_id, p_to_animal_id) THEN
        RAISE EXCEPTION 'Одно или оба животных не готовы к составлению пары';
    END IF;
    
    SELECT zoo_id INTO v_sender_zoo_id FROM users WHERE id = p_sender_id;
    SELECT zoo_id INTO v_from_animal_zoo_id FROM animals WHERE id = p_from_animal_id;
    
    IF v_sender_zoo_id IS NULL OR v_sender_zoo_id != v_from_animal_zoo_id THEN
        RAISE EXCEPTION 'Вы можете создавать заявки только для животных вашего зоопарка';
    END IF;
    
    SELECT EXISTS (
        SELECT 1
        FROM pairing_requests
        WHERE from_animal_id = p_from_animal_id
          AND to_animal_id = p_to_animal_id
          AND status != 'REJECTED'
    ) INTO v_has_active_duplicate;
    
    IF v_has_active_duplicate THEN
        RAISE EXCEPTION 'Уже существует активная заявка для этой пары животных';
    END IF;
    
    INSERT INTO pairing_requests (
        from_animal_id, to_animal_id, sender_id, message,
        status, recipient_approved, organization_approved, created_at, updated_at
    ) VALUES (
        p_from_animal_id, p_to_animal_id, p_sender_id, p_message,
        'PENDING', FALSE, FALSE, NOW(), NOW()
    ) RETURNING id INTO v_request_id;
    
    RETURN v_request_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION approve_pairing_request_recipient(
    p_request_id BIGINT,
    p_user_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_to_animal_id BIGINT;
    v_to_animal_owner_id BIGINT;
    v_to_animal_zoo_id BIGINT;
    v_user_zoo_id BIGINT;
    v_from_animal_id BIGINT;
    v_recipient_approved BOOLEAN;
    v_organization_approved BOOLEAN;
BEGIN
    SELECT 
        to_animal_id, 
        recipient_approved, 
        organization_approved,
        from_animal_id
    INTO 
        v_to_animal_id, 
        v_recipient_approved, 
        v_organization_approved,
        v_from_animal_id
    FROM pairing_requests
    WHERE id = p_request_id;
    
    IF v_to_animal_id IS NULL THEN
        RAISE EXCEPTION 'Заявка с id % не найдена', p_request_id;
    END IF;
    
    IF NOT check_animals_ready_for_pairing(v_from_animal_id, v_to_animal_id) THEN
        RAISE EXCEPTION 'Одно или оба животных больше не готовы к составлению пары';
    END IF;
    
    SELECT owner_id, zoo_id INTO v_to_animal_owner_id, v_to_animal_zoo_id
    FROM animals WHERE id = v_to_animal_id;
    
    SELECT zoo_id INTO v_user_zoo_id FROM users WHERE id = p_user_id;
    
    IF v_to_animal_owner_id != p_user_id AND 
       (v_user_zoo_id IS NULL OR v_user_zoo_id != v_to_animal_zoo_id) THEN
        RAISE EXCEPTION 'Вы не можете одобрить эту заявку';
    END IF;
    
    UPDATE pairing_requests
    SET recipient_approved = TRUE,
        updated_at = NOW()
    WHERE id = p_request_id;
    
    IF v_organization_approved THEN
        UPDATE pairing_requests
        SET status = 'APPROVED',
            updated_at = NOW()
        WHERE id = p_request_id;
        
        UPDATE animals SET ready_for_pairing = FALSE WHERE id = v_from_animal_id;
        UPDATE animals SET ready_for_pairing = FALSE WHERE id = v_to_animal_id;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION approve_pairing_request_organization(
    p_request_id BIGINT,
    p_user_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_from_animal_id BIGINT;
    v_to_animal_id BIGINT;
    v_sender_id BIGINT;
    v_from_animal_owner_id BIGINT;
    v_to_animal_owner_id BIGINT;
    v_from_animal_zoo_id BIGINT;
    v_to_animal_zoo_id BIGINT;
    v_user_zoo_id BIGINT;
    v_recipient_approved BOOLEAN;
    v_organization_approved BOOLEAN;
    v_is_controlling_org BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        INNER JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_user_id AND r.name = 'CONTROLLING_ORGANIZATION'
    ) INTO v_is_controlling_org;
    
    IF NOT v_is_controlling_org THEN
        RAISE EXCEPTION 'Только контролирующая организация может одобрять заявки';
    END IF;
    
    SELECT 
        from_animal_id, 
        to_animal_id, 
        sender_id,
        recipient_approved, 
        organization_approved
    INTO 
        v_from_animal_id, 
        v_to_animal_id, 
        v_sender_id,
        v_recipient_approved, 
        v_organization_approved
    FROM pairing_requests
    WHERE id = p_request_id;
    
    IF v_from_animal_id IS NULL THEN
        RAISE EXCEPTION 'Заявка с id % не найдена', p_request_id;
    END IF;
    
    IF NOT check_animals_ready_for_pairing(v_from_animal_id, v_to_animal_id) THEN
        RAISE EXCEPTION 'Одно или оба животных больше не готовы к составлению пары';
    END IF;
    
    SELECT owner_id, zoo_id INTO v_from_animal_owner_id, v_from_animal_zoo_id
    FROM animals WHERE id = v_from_animal_id;
    
    SELECT owner_id, zoo_id INTO v_to_animal_owner_id, v_to_animal_zoo_id
    FROM animals WHERE id = v_to_animal_id;
    
    SELECT zoo_id INTO v_user_zoo_id FROM users WHERE id = p_user_id;
    
    IF p_user_id = v_sender_id OR
       p_user_id = v_from_animal_owner_id OR
       p_user_id = v_to_animal_owner_id OR
       (v_user_zoo_id IS NOT NULL AND (v_user_zoo_id = v_from_animal_zoo_id OR v_user_zoo_id = v_to_animal_zoo_id)) THEN
        RAISE EXCEPTION 'Контролирующая организация не может одобрять заявки, в которых она участвует';
    END IF;
    
    UPDATE pairing_requests
    SET organization_approved = TRUE,
        updated_at = NOW()
    WHERE id = p_request_id;
    
    IF v_recipient_approved THEN
        UPDATE pairing_requests
        SET status = 'APPROVED',
            updated_at = NOW()
        WHERE id = p_request_id;
        
        UPDATE animals SET ready_for_pairing = FALSE WHERE id = v_from_animal_id;
        UPDATE animals SET ready_for_pairing = FALSE WHERE id = v_to_animal_id;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reject_pairing_request(
    p_request_id BIGINT,
    p_user_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_to_animal_id BIGINT;
    v_from_animal_id BIGINT;
    v_to_animal_owner_id BIGINT;
    v_from_animal_owner_id BIGINT;
    v_to_animal_zoo_id BIGINT;
    v_from_animal_zoo_id BIGINT;
    v_user_zoo_id BIGINT;
    v_is_controlling_org BOOLEAN;
    v_can_reject BOOLEAN;
BEGIN
    SELECT from_animal_id, to_animal_id
    INTO v_from_animal_id, v_to_animal_id
    FROM pairing_requests
    WHERE id = p_request_id;
    
    IF v_from_animal_id IS NULL THEN
        RAISE EXCEPTION 'Заявка с id % не найдена', p_request_id;
    END IF;
    
    SELECT owner_id, zoo_id INTO v_from_animal_owner_id, v_from_animal_zoo_id
    FROM animals WHERE id = v_from_animal_id;
    
    SELECT owner_id, zoo_id INTO v_to_animal_owner_id, v_to_animal_zoo_id
    FROM animals WHERE id = v_to_animal_id;
    
    SELECT zoo_id INTO v_user_zoo_id FROM users WHERE id = p_user_id;
    
    SELECT EXISTS (
        SELECT 1
        FROM user_roles ur
        INNER JOIN roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_user_id AND r.name = 'CONTROLLING_ORGANIZATION'
    ) INTO v_is_controlling_org;
    
    v_can_reject := (
        p_user_id = v_to_animal_owner_id OR
        p_user_id = v_from_animal_owner_id OR
        (v_user_zoo_id IS NOT NULL AND v_user_zoo_id = v_to_animal_zoo_id) OR
        (v_user_zoo_id IS NOT NULL AND v_user_zoo_id = v_from_animal_zoo_id) OR
        v_is_controlling_org
    );
    
    IF NOT v_can_reject THEN
        RAISE EXCEPTION 'Вы не можете отклонить эту заявку';
    END IF;
    
    UPDATE pairing_requests
    SET status = 'REJECTED',
        updated_at = NOW()
    WHERE id = p_request_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_pairing_requests_by_sender(p_sender_id BIGINT)
RETURNS TABLE (
    id BIGINT,
    from_animal_id BIGINT,
    to_animal_id BIGINT,
    sender_id BIGINT,
    message VARCHAR(255),
    status VARCHAR(255),
    recipient_approved BOOLEAN,
    organization_approved BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pr.id,
        pr.from_animal_id,
        pr.to_animal_id,
        pr.sender_id,
        pr.message,
        pr.status,
        pr.recipient_approved,
        pr.organization_approved,
        pr.created_at,
        pr.updated_at
    FROM pairing_requests pr
    WHERE pr.sender_id = p_sender_id
    ORDER BY pr.created_at DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_pairing_requests_by_recipient(p_user_id BIGINT)
RETURNS TABLE (
    id BIGINT,
    from_animal_id BIGINT,
    to_animal_id BIGINT,
    sender_id BIGINT,
    message VARCHAR(255),
    status VARCHAR(255),
    recipient_approved BOOLEAN,
    organization_approved BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pr.id,
        pr.from_animal_id,
        pr.to_animal_id,
        pr.sender_id,
        pr.message,
        pr.status,
        pr.recipient_approved,
        pr.organization_approved,
        pr.created_at,
        pr.updated_at
    FROM pairing_requests pr
    INNER JOIN animals a ON pr.to_animal_id = a.id
    WHERE a.owner_id = p_user_id
    ORDER BY pr.created_at DESC;
END;
$$ LANGUAGE plpgsql;


