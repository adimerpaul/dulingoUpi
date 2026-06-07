<?php
class Model {
    protected PDO    $db;
    protected string $table = '';

    public function __construct() {
        $this->db = Database::getInstance();
    }

    public function find(int $id): ?array {
        $stmt = $this->db->prepare("SELECT * FROM {$this->table} WHERE id = ? AND deleted_at IS NULL");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }

    public function create(array $data): int {
        $now = date('Y-m-d H:i:s');
        $data['created_at'] = $now;
        $data['updated_at'] = $now;
        $cols  = implode(',', array_keys($data));
        $ph    = implode(',', array_fill(0, count($data), '?'));
        $stmt  = $this->db->prepare("INSERT INTO {$this->table} ($cols) VALUES ($ph)");
        $stmt->execute(array_values($data));
        return (int)$this->db->lastInsertId();
    }

    public function update(int $id, array $data): void {
        $data['updated_at'] = date('Y-m-d H:i:s');
        $sets = implode(',', array_map(fn($k) => "$k=?", array_keys($data)));
        $stmt = $this->db->prepare("UPDATE {$this->table} SET $sets WHERE id = ?");
        $stmt->execute([...array_values($data), $id]);
    }

    public function softDelete(int $id): void {
        $this->update($id, ['deleted_at' => date('Y-m-d H:i:s')]);
    }
}
