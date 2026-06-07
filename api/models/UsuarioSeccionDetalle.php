<?php
class UsuarioSeccionDetalle extends Model {
    protected string $table = 'usuario_seccion_detalle';

    public function findByUserAndDetalle(int $userId, int $detalleId): ?array {
        $stmt = $this->db->prepare("
            SELECT * FROM usuario_seccion_detalle
            WHERE usuario_id = ? AND seccion_detalle_id = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$userId, $detalleId]);
        return $stmt->fetch() ?: null;
    }
}
