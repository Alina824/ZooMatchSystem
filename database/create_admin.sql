
SET client_encoding TO 'UTF8';

DO $$
DECLARE
    admin_user_id BIGINT;
    admin_role_id BIGINT;
BEGIN
    SELECT id INTO admin_role_id FROM roles WHERE name = 'ADMIN' LIMIT 1;
    
    IF admin_role_id IS NULL THEN
        RAISE EXCEPTION 'Роль ADMIN не найдена в базе данных';
    END IF;
    
    SELECT id INTO admin_user_id FROM users WHERE username = 'admin';
    
    IF admin_user_id IS NULL THEN
        INSERT INTO users (username, password, first_name, last_name)
        VALUES ('admin', 'admin', 'Администратор', 'Системы')
        RETURNING id INTO admin_user_id;
        
        INSERT INTO user_roles (user_id, role_id)
        VALUES (admin_user_id, admin_role_id)
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Администратор создан: username=admin, password=admin';
    ELSE
        INSERT INTO user_roles (user_id, role_id)
        VALUES (admin_user_id, admin_role_id)
        ON CONFLICT DO NOTHING;
        
        RAISE NOTICE 'Роль ADMIN назначена существующему пользователю admin';
    END IF;
END $$;

