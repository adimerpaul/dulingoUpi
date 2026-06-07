<?php
class AuthMiddleware {
    public function handle(): void {
        $headers = getallheaders();
        $auth    = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (!preg_match('/^Bearer\s+(.+)$/i', trim($auth), $m)) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Token requerido']);
            exit;
        }

        $payload = JWT::decode($m[1], JWT_SECRET);
        if (!$payload) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Token inválido o expirado']);
            exit;
        }

        $_SERVER['AUTH_USER_ID']    = $payload['sub'];
        $_SERVER['AUTH_USER_EMAIL'] = $payload['email'];
        $_SERVER['AUTH_USER_NAME']  = $payload['nombre'];
        $_SERVER['AUTH_USER_ROL']   = $payload['rol'] ?? 'Estudiante';
    }
}
