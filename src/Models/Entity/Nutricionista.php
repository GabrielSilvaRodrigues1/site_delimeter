<?php
    namespace src\Models\Entity;

    class Nutricionista {
        private $id_nutricionista;
        private $id_usuario;
        private $crm_nutricionista;

        public function __construct($id_usuario, $crm_nutricionista) {
            $this->id_usuario = $id_usuario;
            $this->crm_nutricionista = $crm_nutricionista;
        }

        public function getIdNutricionista() {
            return $this->id_nutricionista;
        }

        public function setIdNutricionista($id_nutricionista) {
            $this->id_nutricionista = $id_nutricionista;
        }

        public function getIdUsuario() {
            return $this->id_usuario;
        }

        public function setIdUsuario($id_usuario) {
            $this->id_usuario = $id_usuario;
        }

        public function getCrmNutricionista() {
            return $this->crm_nutricionista;
        }

        public function setCrmNutricionista($crm_nutricionista) {
            $this->crm_nutricionista = $crm_nutricionista;
        }
    }
?>