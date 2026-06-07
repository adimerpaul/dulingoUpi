<?php
class Controller {
    protected function json(mixed $data, int $status = 200): void {
        http_response_code($status);
        echo json_encode(['success' => $status < 400, 'data' => $data]);
    }

    protected function error(string $message, int $status = 400): void {
        http_response_code($status);
        echo json_encode(['success' => false, 'message' => $message]);
        exit;
    }

    protected function input(): array {
        return json_decode(file_get_contents('php://input'), true) ?? [];
    }
}
