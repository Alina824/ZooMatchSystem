

CREATE INDEX IF NOT EXISTS idx_animals_zoo_id ON animals(zoo_id);

CREATE INDEX IF NOT EXISTS idx_animals_owner_id ON animals(owner_id);

CREATE INDEX IF NOT EXISTS idx_animals_species_id ON animals(species_id);

CREATE INDEX IF NOT EXISTS idx_animals_ready_species ON animals(ready_for_pairing, species_id) 
WHERE ready_for_pairing = TRUE;

CREATE INDEX IF NOT EXISTS idx_animals_zoo_ready ON animals(zoo_id, ready_for_pairing);


CREATE INDEX IF NOT EXISTS idx_pairing_requests_from_animal ON pairing_requests(from_animal_id);

CREATE INDEX IF NOT EXISTS idx_pairing_requests_to_animal ON pairing_requests(to_animal_id);

CREATE INDEX IF NOT EXISTS idx_pairing_requests_sender ON pairing_requests(sender_id);

CREATE INDEX IF NOT EXISTS idx_pairing_requests_status ON pairing_requests(status);

CREATE INDEX IF NOT EXISTS idx_pairing_requests_unique_active 
ON pairing_requests(from_animal_id, to_animal_id, status) 
WHERE status != 'REJECTED';

CREATE INDEX IF NOT EXISTS idx_pairing_requests_created_at ON pairing_requests(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_pairing_requests_status_created ON pairing_requests(status, created_at DESC);


CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE INDEX IF NOT EXISTS idx_users_zoo_id ON users(zoo_id);


CREATE INDEX IF NOT EXISTS idx_role_requests_user_id ON role_requests(user_id);

CREATE INDEX IF NOT EXISTS idx_role_requests_status ON role_requests(status);

CREATE INDEX IF NOT EXISTS idx_role_requests_request_type ON role_requests(request_type);

CREATE INDEX IF NOT EXISTS idx_role_requests_pending ON role_requests(status, created_at DESC) 
WHERE status = 'PENDING';

CREATE INDEX IF NOT EXISTS idx_role_requests_zoo_id ON role_requests(zoo_id);


CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);

CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(role_id);


CREATE INDEX IF NOT EXISTS idx_animal_diseases_animal_id ON animal_diseases(animal_id);

CREATE INDEX IF NOT EXISTS idx_animal_diseases_disease_id ON animal_diseases(disease_id);


CREATE INDEX IF NOT EXISTS idx_zoos_country_id ON zoos(country_id);


CREATE INDEX IF NOT EXISTS idx_messages_pairing_request_id ON messages(pairing_request_id);

CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);

CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);


