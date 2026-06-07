<?php
$auth = [[AuthMiddleware::class, 'handle']];
$admin = [[AuthMiddleware::class, 'handle'], [AdminMiddleware::class, 'handle']];

// Autenticación (pública)
$router->post('/auth/login',    [AuthController::class,   'login']);
$router->post('/auth/register', [AuthController::class,   'register']);

// Secciones con progreso (protegido)
$router->get('/secciones',                                         [SeccionController::class,  'index'], $auth);

// Preguntas de un nodo (protegido)
$router->get('/secciones/{id}/detalles/{detalleId}/preguntas',     [PreguntaController::class, 'index'], $auth);

// Progreso del usuario (protegido)
$router->get('/progreso',  [ProgresoController::class, 'get'],  $auth);
$router->post('/progreso', [ProgresoController::class, 'post'], $auth);

// Administracion (solo rol Administrador)
$router->get('/admin/{resource}',       [AdminController::class, 'index'],  $admin);
$router->put('/admin/{resource}/{id}',  [AdminController::class, 'update'], $admin);
