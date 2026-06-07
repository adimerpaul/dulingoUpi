<?php
class PreguntaController extends Controller {

    public function index(array $params): void {
        $detalleId = (int)($params['detalleId'] ?? 0);

        $detalle = (new SeccionDetalle())->find($detalleId);
        if (!$detalle) {
            $this->error('Nodo no encontrado', 404);
        }

        $preguntas = (new Pregunta())->findByDetalle($detalleId);
        $respuestaModel = new Respuesta();

        foreach ($preguntas as &$p) {
            if ($p['tipo_pregunta'] === 'multiple_choice') {
                $p['respuestas'] = $respuestaModel->findByPregunta($p['id']);
                foreach ($p['respuestas'] as &$r) {
                    $r['es_correcta'] = (bool)$r['es_correcta'];
                }
            } else {
                $p['respuestas'] = [];
            }

            if ($p['config']) {
                $p['config'] = json_decode($p['config'], true);
            }
        }

        $this->json(['preguntas' => $preguntas, 'detalle' => $detalle]);
    }
}
