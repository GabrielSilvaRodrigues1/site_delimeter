<?php
namespace src\Services;
use src\Repositories\AlunoRepository;
use src\Models\Entity\Aluno;

class AlunoServices{
    private $aluno;

    public function __construct($aluno){
        $this->aluno = new AlunoRepository($aluno);
    }
    public function criar(Aluno $aluno){
        $aluno = new Aluno($nome, $genero);
        $this->aluno->save($aluno);
    }
}


?>