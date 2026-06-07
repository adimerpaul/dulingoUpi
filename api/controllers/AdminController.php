<?php
class AdminController extends Controller {
    private array $resources = [
        'seccion' => [
            'table'  => 'seccion',
            'fields' => ['nombre'],
        ],
        'seccion_detalle' => [
            'table'  => 'seccion_detalle',
            'fields' => ['seccion_id', 'nombre', 'tipo', 'color', 'orden'],
        ],
        'preguntas' => [
            'table'  => 'preguntas',
            'fields' => ['seccion_detalle_id', 'nombre', 'tipo_pregunta', 'config'],
        ],
        'respuesta' => [
            'table'  => 'respuesta',
            'fields' => ['pregunta_id', 'nombre', 'es_correcta'],
        ],
        'usuario_seccion_detalle' => [
            'table'  => 'usuario_seccion_detalle',
            'fields' => ['usuario_id', 'seccion_detalle_id', 'realizado', 'fecha_creacion'],
        ],
    ];

    public function index(array $params): void {
        $resource = $this->resource($params['resource'] ?? '');
        $meta = $this->resources[$resource];

        $stmt = Database::getInstance()->prepare("
            SELECT *
            FROM {$meta['table']}
            WHERE deleted_at IS NULL
            ORDER BY id ASC
        ");
        $stmt->execute();

        $this->json([
            'resource' => $resource,
            'fields'   => $meta['fields'],
            'rows'     => $stmt->fetchAll(),
        ]);
    }

    public function update(array $params): void {
        $resource = $this->resource($params['resource'] ?? '');
        $id = (int)($params['id'] ?? 0);
        if (!$id) {
            $this->error('ID requerido', 422);
        }

        $meta = $this->resources[$resource];
        $current = $this->findRow($meta['table'], $id);
        if (!$current) {
            $this->error('Registro no encontrado', 404);
        }

        $data = $this->filterInput($this->input(), $meta['fields']);
        if (!$data) {
            $this->error('No hay campos validos para modificar', 422);
        }

        $this->validateResourceData($resource, $data);

        $data['updated_at'] = date('Y-m-d H:i:s');
        $sets = implode(',', array_map(fn($field) => "$field = ?", array_keys($data)));
        $stmt = Database::getInstance()->prepare("UPDATE {$meta['table']} SET $sets WHERE id = ?");
        $stmt->execute([...array_values($data), $id]);

        $this->json([
            'message' => 'Registro actualizado',
            'row'     => $this->findRow($meta['table'], $id),
        ]);
    }

    private function resource(string $resource): string {
        if (!isset($this->resources[$resource])) {
            $this->error('Recurso administrativo no permitido', 404);
        }
        return $resource;
    }

    private function filterInput(array $input, array $fields): array {
        $data = [];
        foreach ($fields as $field) {
            if (!array_key_exists($field, $input)) {
                continue;
            }
            $value = $input[$field];
            if ($field === 'config' && is_array($value)) {
                $value = json_encode($value, JSON_UNESCAPED_UNICODE);
            }
            if (in_array($field, ['seccion_id', 'seccion_detalle_id', 'pregunta_id', 'usuario_id', 'orden'], true)) {
                $value = (int)$value;
            }
            if (in_array($field, ['es_correcta', 'realizado'], true)) {
                $value = (int)(bool)$value;
            }
            $data[$field] = $value;
        }
        return $data;
    }

    private function validateResourceData(string $resource, array $data): void {
        if (isset($data['seccion_id'])) {
            $this->assertExists('seccion', (int)$data['seccion_id'], 'La seccion no existe');
        }
        if (isset($data['seccion_detalle_id'])) {
            $this->assertExists('seccion_detalle', (int)$data['seccion_detalle_id'], 'El detalle de seccion no existe');
        }
        if (isset($data['pregunta_id'])) {
            $this->assertExists('preguntas', (int)$data['pregunta_id'], 'La pregunta no existe');
        }
        if (isset($data['usuario_id'])) {
            $this->assertExists('usuario', (int)$data['usuario_id'], 'El usuario no existe');
        }
        if (isset($data['tipo']) && !in_array($data['tipo'], ['lesson', 'review', 'chest', 'crown'], true)) {
            $this->error('tipo invalido', 422);
        }
        if (isset($data['tipo_pregunta']) && !in_array($data['tipo_pregunta'], ['multiple_choice', 'build', 'match'], true)) {
            $this->error('tipo_pregunta invalido', 422);
        }
        if ($resource === 'preguntas' && isset($data['config']) && $data['config'] !== null && $data['config'] !== '') {
            json_decode((string)$data['config'], true);
            if (json_last_error() !== JSON_ERROR_NONE) {
                $this->error('config debe ser JSON valido', 422);
            }
        }
    }

    private function assertExists(string $table, int $id, string $message): void {
        if ($id <= 0) {
            $this->error($message, 422);
        }

        $stmt = Database::getInstance()->prepare("SELECT id FROM $table WHERE id = ? AND deleted_at IS NULL LIMIT 1");
        $stmt->execute([$id]);
        if (!$stmt->fetch()) {
            $this->error($message, 422);
        }
    }

    private function findRow(string $table, int $id): ?array {
        $stmt = Database::getInstance()->prepare("SELECT * FROM $table WHERE id = ? AND deleted_at IS NULL LIMIT 1");
        $stmt->execute([$id]);
        return $stmt->fetch() ?: null;
    }
}
