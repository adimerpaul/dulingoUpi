<?php
declare(strict_types=1);

// --- Cabeceras CORS ---
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// --- Autoload manual ---
require_once __DIR__ . '/config/app.php';
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/core/JWT.php';
require_once __DIR__ . '/core/Router.php';
require_once __DIR__ . '/core/Controller.php';
require_once __DIR__ . '/core/Model.php';
require_once __DIR__ . '/middleware/AuthMiddleware.php';
require_once __DIR__ . '/middleware/AdminMiddleware.php';
require_once __DIR__ . '/models/Usuario.php';
require_once __DIR__ . '/models/Seccion.php';
require_once __DIR__ . '/models/SeccionDetalle.php';
require_once __DIR__ . '/models/Pregunta.php';
require_once __DIR__ . '/models/Respuesta.php';
require_once __DIR__ . '/models/UsuarioSeccionDetalle.php';
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/SeccionController.php';
require_once __DIR__ . '/controllers/PreguntaController.php';
require_once __DIR__ . '/controllers/ProgresoController.php';
require_once __DIR__ . '/controllers/AdminController.php';

// --- Resolver ruta relativa al directorio del script ---
$uri  = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$base = rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
$path = $base ? substr($uri, strlen($base)) : $uri;
if ($path === '' || $path === false) $path = '/';

// --- Despachar ---
$router = new Router();
require_once __DIR__ . '/routes/api.php';

try {
    $router->dispatch($path, $_SERVER['REQUEST_METHOD']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error de base de datos']);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error interno del servidor']);
}
