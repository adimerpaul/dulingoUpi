# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Duolingo-style language-learning app built with **pure PHP MVC**, **MySQL**, **REST API**, and **JWT authentication**. Runs on XAMPP (Apache + MySQL). No external PHP framework — the MVC core is custom-built in `core/`.

## Development Environment

- **Server:** XAMPP on Windows — Apache serves from `C:\xamppUpi\htdocs\duolingo\public\`
- **Entry point:** All HTTP requests route through `public/index.php` via `.htaccess` rewrite
- **Database:** MySQL on localhost, DB name `duolingo`
- **PHP version:** 8.x (use typed properties, named args, match expressions freely)

Start/stop XAMPP services from the XAMPP Control Panel. No build step needed.

## Project Structure

```
duolingo/
├── app/
│   ├── controllers/     # One controller per resource (AuthController, SeccionController, etc.)
│   ├── models/          # One model per table, extends core/Model.php
│   ├── views/           # PHP templates (only for non-API HTML pages, if any)
│   └── middleware/      # AuthMiddleware.php validates JWT on protected routes
├── config/
│   ├── database.php     # PDO connection singleton
│   └── app.php          # APP_URL, JWT_SECRET, environment constants
├── core/
│   ├── Router.php       # Registers GET/POST/PUT/DELETE routes, dispatches to controllers
│   ├── Controller.php   # Base: json($data, $status), input(), param()
│   ├── Model.php        # Base: PDO instance, find(), findAll(), create(), update(), softDelete()
│   └── Response.php     # Standardized JSON envelope: {success, data, message, errors}
├── routes/
│   └── api.php          # All route definitions — import here, keep controllers thin
├── database/
│   └── schema.sql       # Full DDL for all tables (single source of truth)
└── public/
    ├── index.php        # Bootstrap: load config, instantiate Router, run()
    └── .htaccess        # RewriteRule: everything → index.php
```

## Database Schema

All tables use soft deletes (`deleted_at` nullable timestamp). Always filter `WHERE deleted_at IS NULL`.

```
usuario              — id, nombre, email, password (bcrypt), created_at, updated_at, deleted_at
seccion              — id, nombre, created_at, updated_at, deleted_at
seccion_detalle      — id, seccion_id (FK), nombre, color, created_at, updated_at, deleted_at
preguntas            — id, nombre, tipo_pregunta, created_at, updated_at, deleted_at
respuesta            — id, nombre, created_at, updated_at, deleted_at
usuario_seccion_detalle — id, usuario_id (FK), seccion_detalle_id (FK), realizado (bool),
                          fecha_creacion, created_at, updated_at, deleted_at
```

`tipo_pregunta` in `preguntas` drives question rendering logic (e.g., `multiple_choice`, `fill_blank`, `match`).

## API Design

All endpoints are under `/api/v1/`. Responses always use the `Response` envelope:

```json
{ "success": true, "data": { ... }, "message": "OK", "errors": [] }
```

**Auth endpoints (public):**
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login` → returns JWT

**Protected endpoints (require `Authorization: Bearer <token>` header):**
- `GET  /api/v1/secciones`
- `GET  /api/v1/secciones/{id}/detalles`
- `GET  /api/v1/preguntas`
- `POST /api/v1/usuario/progreso` — mark a `seccion_detalle` as completed
- `GET  /api/v1/usuario/progreso` — get authenticated user's progress

## Authentication

JWT-based. `AuthMiddleware::handle()` must be called first on any protected route.

- Tokens signed with `JWT_SECRET` from `config/app.php`
- Payload: `{ sub: usuario_id, email, iat, exp }`
- No refresh tokens — expiry configurable in `app.php`
- Passwords hashed with `password_hash($pass, PASSWORD_BCRYPT)`

## Routing Convention

```php
// routes/api.php
$router->post('/api/v1/auth/login', [AuthController::class, 'login']);
$router->get('/api/v1/secciones', [SeccionController::class, 'index'], [AuthMiddleware::class]);
```

Third argument to `get()`/`post()` etc. is an optional middleware stack (executed in order).

## Model Convention

Models extend `core/Model.php`. The base class provides:
- `find($id)` — single row by PK, respects soft delete
- `findAll($where = [], $order = 'id ASC')` — array of rows
- `create($data)` — INSERT, returns new ID
- `update($id, $data)` — UPDATE, sets `updated_at`
- `softDelete($id)` — sets `deleted_at = NOW()`

Each model declares `protected string $table` and `protected array $fillable`.

## Key Constraints

- Soft deletes are mandatory — never use hard DELETE.
- All foreign keys must be validated in the controller before insert (return 422 if the related record doesn't exist or is soft-deleted).
- The `usuario_seccion_detalle.realizado` column is a tinyint(1) boolean — store 0/1.
- No ORM — raw PDO with prepared statements only. No query builder.
