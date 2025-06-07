<?php
    namespace src\Models\Entity;

    class Medico {
        private $id_medico;
        private $id_usuario;
        private $crm_medico;

        public function __construct($id_usuario, $crm_medico) {
            $this->id_usuario = $id_usuario;
            $this->crm_medico = $crm_medico;
        }

        public function getIdMedico() {
            return $this->id_medico;
        }

        public function setIdMedico($id_medico) {
            $this->id_medico = $id_medico;
        }

        public function getIdUsuario() {
            return $this->id_usuario;
        }

        public function setIdUsuario($id_usuario) {
            $this->id_usuario = $id_usuario;
        }

        public function getCrmMedico() {
            return $this->crm_medico;
        }

        public function setCrmMedico($crm_medico) {
            $this->crm_medico = $crm_medico;
        }
    }
?>