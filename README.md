# Zoo Match System

Информационная система для составления пар животных в зоопарках.

## Технологии

- **Backend**: Java Spring Boot 3.2.0
- **Frontend**: React 18.2.0
- **База данных**: PostgreSQL 15
- **Аутентификация**: JWT
- **Контейнеризация**: Docker & Docker Compose

## Структура проекта

```
zooMatchSystem/
├── backend/                 # Spring Boot приложение
│   ├── src/
│   │   └── main/
│   │       ├── java/com/zoomatcher/
│   │       │   ├── config/      # Конфигурация
│   │       │   ├── controller/  # REST контроллеры
│   │       │   ├── dto/         # Data Transfer Objects
│   │       │   ├── model/       # JPA сущности
│   │       │   ├── repository/  # JPA репозитории
│   │       │   ├── security/    # Security конфигурация
│   │       │   ├── service/     # Бизнес-логика
│   │       │   └── util/        # Утилиты
│   │       └── resources/
│   │           └── application.yml
│   ├── Dockerfile
│   └── pom.xml
├── frontend/               # React приложение
│   ├── public/
│   ├── src/
│   │   ├── components/    # React компоненты
│   │   ├── context/       # React контекст
│   │   ├── services/      # API сервисы
│   │   └── App.js
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── database/              # SQL скрипты
├── docker-compose.yml     # Docker Compose конфигурация
└── README.md
```

## Быстрый запуск с Docker

### Требования

- Docker 20.10+
- Docker Compose 2.0+

### Запуск

1. Клонируйте репозиторий:
```bash
git clone <repository-url>
cd zooMatchSystem
```

2. Запустите все сервисы через Docker Compose:
```bash
docker-compose up -d
```

3. Приложение будет доступно:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8080/api
   - PostgreSQL: localhost:5432

4. Остановка сервисов:
```bash
docker-compose down
```

5. Остановка с удалением данных:
```bash
docker-compose down -v
```

## Ручная установка (без Docker)

### Требования

- Java 17+
- Maven 3.8+
- Node.js 18+
- PostgreSQL 15+

### Backend

1. Создайте базу данных PostgreSQL:
```sql
CREATE DATABASE zoomatcher;
```

2. Настройте `backend/src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/zoomatcher
    username: postgres
    password: postgres
```

3. Запустите приложение:
```bash
cd backend
mvn spring-boot:run
```

Backend будет доступен на `http://localhost:8080/api`

### Frontend

1. Установите зависимости:
```bash
cd frontend
npm install
```

2. Запустите приложение:
```bash
npm start
```

Frontend будет доступен на `http://localhost:3000`

## Основные функции

- ✅ Регистрация и аутентификация пользователей
- ✅ Создание и просмотр карточек животных
- ✅ Создание заявок на составление пары
- ✅ Разделение поданных и полученных заявок
- ✅ Фильтрация заявок
- ✅ Одобрение заявок получателем и контролирующей организацией
- ✅ Обмен сообщениями по заявкам
- ✅ Редактирование карточек животных (владелец или сотрудник зоопарка)
- ✅ Флаг готовности к составлению пары (blocking для создания/принятия заявок)
- ✅ Управление странами и зоопарками
- ✅ Роли: USER, ZOO_EMPLOYEE, CONTROLLING_ORGANIZATION, ADMIN

## Роли пользователей

- **USER** - Обычный пользователь, может создавать карточки животных и заявки
- **ZOO_EMPLOYEE** - Сотрудник зоопарка, может редактировать карточки животных своего зоопарка
- **CONTROLLING_ORGANIZATION** - Контролирующая организация, может одобрять заявки на составление пары (не может одобрять заявки, где она участвует)
- **ADMIN** - Администратор системы

## API Endpoints

### Аутентификация
- `POST /auth/register` - Регистрация
- `POST /auth/login` - Вход

### Животные
- `GET /animals` - Получить все животные
- `GET /animals/my` - Получить мои животные
- `GET /animals/{id}` - Получить животное по ID
- `POST /animals` - Создать животное
- `PUT /animals/{id}` - Обновить животное
- `DELETE /animals/{id}` - Удалить животное

### Заявки
- `GET /pairing-requests` - Получить все заявки
- `GET /pairing-requests/my` - Получить все мои заявки
- `GET /pairing-requests/sent` - Получить поданные мной заявки
- `GET /pairing-requests/received` - Получить полученные мной заявки
- `GET /pairing-requests/filter` - Получить заявки с фильтрами
- `GET /pairing-requests/{id}` - Получить заявку по ID
- `POST /pairing-requests` - Создать заявку
- `POST /pairing-requests/{id}/approve-recipient` - Одобрить получателем
- `POST /pairing-requests/{id}/approve-organization` - Одобрить организацией
- `POST /pairing-requests/{id}/reject` - Отклонить заявку

### Сообщения
- `GET /messages/request/{requestId}` - Получить сообщения по заявке
- `POST /messages/request/{requestId}` - Создать сообщение

### Страны
- `GET /countries` - Получить все страны
- `GET /countries/{id}` - Получить страну по ID

## Безопасность

- Контролирующая организация не может одобрять заявки, в которых она участвует как отправитель, получатель или владелец животного
- Пользователи могут иметь несколько ролей одновременно
- Все API endpoints (кроме публичных) требуют JWT аутентификации

## Структура базы данных

Основные таблицы:
- `users` - Пользователи
- `roles` - Роли
- `user_roles` - Связь пользователей и ролей (многие-ко-многим)
- `countries` - Страны
- `zoos` - Зоопарки (связаны со странами)
- `species` - Виды животных
- `animals` - Животные
- `diseases` - Заболевания
- `animal_diseases` - Связь животных и заболеваний (многие-ко-многим)
- `pairing_requests` - Заявки на составление пары
- `messages` - Сообщения по заявкам
