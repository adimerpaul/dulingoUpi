<?php
class SeccionController extends Controller {

    public function index(array $params): void {
        $userId   = (int)$_SERVER['AUTH_USER_ID'];
        $secciones = (new Seccion())->findAll();
        $detalleModel = new SeccionDetalle();

        foreach ($secciones as &$s) {
            $s['detalles'] = $detalleModel->findBySeccionWithProgress($s['id'], $userId);
            // Cast tipos correctos
            foreach ($s['detalles'] as &$d) {
                $d['realizado'] = (bool)$d['realizado'];
                $d['orden']     = (int)$d['orden'];
            }
        }

        $this->json(['secciones' => $secciones]);
    }
}
