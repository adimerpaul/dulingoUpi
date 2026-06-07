<?php
class Respuesta extends Model {
    protected string $table = 'respuesta';

    public function findByPregunta(int $preguntaId): array {
        $stmt = $this->db->prepare("
            SELECT id, nombre, es_correcta FROM respuesta
            WHERE pregunta_id = ? AND deleted_at IS NULL
            ORDER BY id ASC
        ");
        $stmt->execute([$preguntaId]);
        return $stmt->fetchAll();
    }
}
