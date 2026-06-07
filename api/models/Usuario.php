<?php
class Usuario extends Model {
    protected string $table = 'usuario';

    public function findByEmail(string $email): ?array {
        $stmt = $this->db->prepare("SELECT * FROM usuario WHERE email = ? AND deleted_at IS NULL");
        $stmt->execute([$email]);
        return $stmt->fetch() ?: null;
    }
}
