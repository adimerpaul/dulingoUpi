<?php
class Router {
    private array $routes = [];

    public function get(string $path, array $handler, array $middleware = []): void {
        $this->add('GET', $path, $handler, $middleware);
    }
    public function post(string $path, array $handler, array $middleware = []): void {
        $this->add('POST', $path, $handler, $middleware);
    }
    public function put(string $path, array $handler, array $middleware = []): void {
        $this->add('PUT', $path, $handler, $middleware);
    }
    public function delete(string $path, array $handler, array $middleware = []): void {
        $this->add('DELETE', $path, $handler, $middleware);
    }

    private function add(string $method, string $path, array $handler, array $middleware): void {
        preg_match_all('/\{(\w+)\}/', $path, $m);
        $this->routes[] = [
            'method'     => $method,
            'pattern'    => '#^' . preg_replace('/\{(\w+)\}/', '([^/]+)', $path) . '$#',
            'keys'       => $m[1],
            'handler'    => $handler,
            'middleware' => $middleware,
        ];
    }

    public function dispatch(string $path, string $method): void {
        // Preflight CORS
        if ($method === 'OPTIONS') {
            http_response_code(204);
            exit;
        }

        foreach ($this->routes as $r) {
            if ($r['method'] !== $method) continue;
            if (!preg_match($r['pattern'], $path, $matches)) continue;

            array_shift($matches);
            $params = $r['keys'] ? array_combine($r['keys'], $matches) : [];

            foreach ($r['middleware'] as [$mwClass, $mwMethod]) {
                (new $mwClass())->$mwMethod();
            }

            [$class, $action] = $r['handler'];
            (new $class())->$action($params);
            return;
        }

        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Ruta no encontrada']);
    }
}
