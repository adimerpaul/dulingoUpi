<?php
class AdminMiddleware {
    public function handle(): void {
        $userId = (int)($_SERVER['AUTH_USER_ID'] ?? 0);
        if (!$userId) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Token requerido']);
            exit;
        }

        $stmt = Database::getInstance()->prepare("
            SELECT rol
            FROM usuario
            WHERE id = ? AND deleted_at IS NULL
            LIMIT 1
        ");
        $stmt->execute([$userId]);
        $usuario = $stmt->fetch();

        if (!$usuario || $usuario['rol'] !== 'Administrador') {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Permisos de administrador requeridos']);
            exit;
        }
    }
}
