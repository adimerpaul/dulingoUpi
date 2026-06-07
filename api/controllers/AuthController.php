<?php
class AuthController extends Controller {

    public function login(array $params): void {
        $in = $this->input();
        $email    = trim($in['email']    ?? '');
        $password =       $in['password'] ?? '';

        if (!$email || !$password) {
            $this->error('Email y contraseña requeridos', 422);
        }

        $usuario = (new Usuario())->findByEmail($email);
        if (!$usuario || !password_verify($password, $usuario['password'])) {
            $this->error('Credenciales incorrectas', 401);
        }

        $this->json([
            'token' => $this->makeToken($usuario),
            'user'  => $this->safeUser($usuario),
        ]);
    }

    public function register(array $params): void {
        $in = $this->input();
        $nombre   = trim($in['nombre']   ?? '');
        $email    = trim($in['email']    ?? '');
        $password =       $in['password'] ?? '';

        if (!$nombre || !$email || !$password) {
            $this->error('Todos los campos son requeridos', 422);
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->error('Email inválido', 422);
        }
        if (strlen($password) < 6) {
            $this->error('La contraseña debe tener al menos 6 caracteres', 422);
        }

        $model = new Usuario();
        if ($model->findByEmail($email)) {
            $this->error('El email ya está registrado', 409);
        }

        $id = $model->create([
            'nombre'   => $nombre,
            'email'    => $email,
            'password' => password_hash($password, PASSWORD_BCRYPT),
            'rol'      => 'Estudiante',
        ]);

        $usuario = ['id' => $id, 'nombre' => $nombre, 'email' => $email, 'rol' => 'Estudiante', 'password' => ''];
        $this->json([
            'token' => $this->makeToken($usuario),
            'user'  => $this->safeUser($usuario),
        ], 201);
    }

    private function makeToken(array $u): string {
        return JWT::encode([
            'sub'    => $u['id'],
            'email'  => $u['email'],
            'nombre' => $u['nombre'],
            'rol'    => $u['rol'] ?? 'Estudiante',
            'iat'    => time(),
            'exp'    => time() + JWT_EXPIRY,
        ], JWT_SECRET);
    }

    private function safeUser(array $u): array {
        return [
            'id'     => $u['id'],
            'nombre' => $u['nombre'],
            'email'  => $u['email'],
            'rol'    => $u['rol'] ?? 'Estudiante',
        ];
    }
}
