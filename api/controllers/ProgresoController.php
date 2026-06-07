<?php
class ProgresoController extends Controller {

    public function get(array $params): void {
        $userId = (int)$_SERVER['AUTH_USER_ID'];
        $stmt = Database::getInstance()->prepare("
            SELECT seccion_detalle_id, realizado
            FROM usuario_seccion_detalle
            WHERE usuario_id = ? AND deleted_at IS NULL
        ");
        $stmt->execute([$userId]);
        $rows = $stmt->fetchAll();

        $completados = array_map(
            fn($r) => (int)$r['seccion_detalle_id'],
            array_filter($rows, fn($r) => $r['realizado'])
        );

        $this->json(['completados' => array_values($completados)]);
    }

    public function post(array $params): void {
        $userId    = (int)$_SERVER['AUTH_USER_ID'];
        $in        = $this->input();
        $detalleId = (int)($in['seccion_detalle_id'] ?? 0);

        if (!$detalleId) {
            $this->error('seccion_detalle_id requerido', 422);
        }

        $detalle = (new SeccionDetalle())->find($detalleId);
        if (!$detalle) {
            $this->error('Nodo no encontrado', 404);
        }

        $model    = new UsuarioSeccionDetalle();
        $existing = $model->findByUserAndDetalle($userId, $detalleId);

        if ($existing) {
            $model->update($existing['id'], ['realizado' => 1]);
        } else {
            $model->create([
                'usuario_id'         => $userId,
                'seccion_detalle_id' => $detalleId,
                'realizado'          => 1,
                'fecha_creacion'     => date('Y-m-d H:i:s'),
            ]);
        }

        $this->json(['message' => 'Progreso guardado', 'seccion_detalle_id' => $detalleId]);
    }
}
