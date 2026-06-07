<?php
class Pregunta extends Model {
    protected string $table = 'preguntas';

    public function findByDetalle(int $detalleId): array {
        $stmt = $this->db->prepare("
            SELECT * FROM preguntas
            WHERE seccion_detalle_id = ? AND deleted_at IS NULL
            ORDER BY id ASC
        ");
        $stmt->execute([$detalleId]);
        return $stmt->fetchAll();
    }
}
