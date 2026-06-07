<?php
class Seccion extends Model {
    protected string $table = 'seccion';

    public function findAll(): array {
        $stmt = $this->db->prepare("SELECT * FROM seccion WHERE deleted_at IS NULL ORDER BY id ASC");
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
