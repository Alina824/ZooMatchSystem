
INSERT INTO countries (id, name, code) VALUES
(1, 'Россия', 'RU'),
(2, 'Беларусь', 'BY'),
(3, 'Казахстан', 'KZ')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code;

INSERT INTO roles (id, name) VALUES
(1, 'USER'),
(2, 'ZOO_EMPLOYEE'),
(3, 'CONTROLLING_ORGANIZATION'),
(4, 'ADMIN')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO zoos (name, country_id) VALUES ('Калининградский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Московский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Санкт-Петербургский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Новосибирский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Ростовский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Екатеринбургский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Красноярский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Самарский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Воронежский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Казанский зоопарк', 1) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Минский зоопарк', 2) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Гродненский зоопарк', 2) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Алматинский зоопарк', 3) ON CONFLICT (name) DO NOTHING;
INSERT INTO zoos (name, country_id) VALUES ('Астана зоопарк', 3) ON CONFLICT (name) DO NOTHING;

INSERT INTO species (id, name) VALUES
(1, 'Слон'),
(2, 'Рысь'),
(3, 'Жираф'),
(4, 'Лев'),
(5, 'Тигр'),
(6, 'Кенгуру'),
(7, 'Полярный волк'),
(8, 'Медведь'),
(9, 'Обезьяна'),
(10, 'Панда'),
(11, 'Зебра'),
(12, 'Бегемот'),
(13, 'Носорог'),
(14, 'Крокодил'),
(15, 'Орел')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO diseases (id, name) VALUES
(1, 'Респираторная инфекция'),
(2, 'Паразиты'),
(3, 'Кожные заболевания'),
(4, 'Проблемы с пищеварением'),
(5, 'Травмы'),
(6, 'Аллергия'),
(7, 'Инфекционные заболевания'),
(8, 'Хронические заболевания'),
(9, 'Генетические нарушения'),
(10, 'Возрастные изменения'),
(11, 'Заболевания опорно-двигательного аппарата'),
(12, 'Проблемы с зубами'),
(13, 'Ожирение'),
(14, 'Стресс'),
(15, 'Вирусные инфекции')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

SELECT setval('countries_id_seq', (SELECT MAX(id) FROM countries));
SELECT setval('zoos_id_seq', (SELECT MAX(id) FROM zoos));
SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));
SELECT setval('species_id_seq', (SELECT MAX(id) FROM species));
SELECT setval('diseases_id_seq', (SELECT MAX(id) FROM diseases));

