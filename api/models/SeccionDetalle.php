<?php
class SeccionDetalle extends Model {
    protected string $table = 'seccion_detalle';

    public function findBySeccionWithProgress(int $seccionId, int $userId): array {
        $stmt = $this->db->prepare("
            SELECT sd.*, COALESCE(usd.realizado, 0) AS realizado
            FROM seccion_detalle sd
            LEFT JOIN usuario_seccion_detalle usd
                   ON usd.seccion_detalle_id = sd.id
                  AND usd.usuario_id = ?
                  AND usd.deleted_at IS NULL
            WHERE sd.seccion_id = ? AND sd.deleted_at IS NULL
            ORDER BY sd.orden ASC
        ");
        $stmt->execute([$userId, $seccionId]);
        return $stmt->fetchAll();
    }
}
