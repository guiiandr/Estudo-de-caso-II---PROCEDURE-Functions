
CREATE OR REPLACE PROCEDURE pRegistrarMatricula(v_EstudanteID IN NUMBER, v_CursoID IN NUMBER) IS
BEGIN
	INSERT INTO Matriculas 
    	(DataMatricula, Status, EstudanteID, CursoID)
	VALUES
		(SYSDATE, 'Ativo', v_EstudanteID, v_CursoID);
END pRegistrarMatricula;


CREATE OR REPLACE PROCEDURE pRegistrarAvaliacao (v_CursoID IN NUMBER, v_EstudanteID IN NUMBER, v_Nota IN DECIMAL, v_Comentario IN VARCHAR2) IS
BEGIN
	INSERT INTO Avaliacoes
		(Nota, Comentario, CursoID, EstudanteID)
	VALUES
		(v_Nota, v_Comentario, v_CursoID, v_EstudanteID);
END pRegistrarAvaliacao;


CREATE OR REPLACE PROCEDURE pAtualizarCurso (v_CursoID IN NUMBER, v_Nome IN VARCHAR2, v_Descricao IN VARCHAR2, v_InstrutorID IN NUMBER, v_Preco IN DECIMAL) IS
BEGIN
	UPDATE Cursos SET
        Nome=v_Nome,
        Descricao=v_Descricao,
    	Preco=v_Preco
	WHERE 
		CursoID = v_CursoID;
	DELETE FROM Instrui WHERE CursoID = v_CursoID;
	INSERT INTO Instrui VALUES (v_InstrutorID, v_CursoID);
END pAtualizarCurso;


CREATE OR REPLACE PROCEDURE pRemoverCurso (v_CursoID IN NUMBER) IS
BEGIN
    DELETE FROM Instrui WHERE CursoID = v_CursoID;
	DELETE FROM Cursos WHERE CursoID = v_CursoID;
END pRemoverCurso;


CREATE OR REPLACE PROCEDURE pCadastrarProfessor (v_Nome IN VARCHAR2, v_Especialidade IN VARCHAR2, v_Email IN VARCHAR2, v_CursoID IN NUMBER)
IS
    v_InstrutorID Instrutores.InstrutorID%TYPE;
BEGIN
	INSERT INTO Instrutores
		(Nome, Especialidade, Email)
	VALUES
		(v_Nome, v_Especialidade, v_Email)
    RETURNING InstrutorID INTO v_InstrutorID;
	INSERT INTO Instrui VALUES (v_InstrutorID, v_CursoID);
END pCadastrarProfessor;



CREATE OR REPLACE FUNCTION fCalcularMediaNotasCurso (CursoID IN NUMBER) 
RETURN NUMBER IS
    v_media NUMBER(4,2);
BEGIN
    SELECT AVG(Nota) 
    INTO v_media
    FROM Avaliacoes
    WHERE CursoID = CursoID;
    
    IF v_media IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN v_media;
END fCalcularMediaNotasCurso; 


CREATE OR REPLACE FUNCTION fObterDetalhesEstudante (EstudanteID IN NUMBER)
RETURN VARCHAR2 IS
  v_result VARCHAR2(4000);
BEGIN
    SELECT 
        e.Nome || ' está matriculado no curso ' || c.Nome ||
        '  Data de Matrícula: ' || TO_CHAR(m.DataMatricula, 'DD-MM-YYYY') ||
        '  Status: ' || m.Status ||
        '  Nota: ' || NVL(TO_CHAR(a.Nota), 'Nenhuma nota')
    INTO v_result
    FROM Estudantes e
    JOIN Matriculas m ON e.EstudanteID = m.EstudanteID
    JOIN Cursos c ON m.CursoID = c.CursoID
    INNER JOIN Avaliacoes a ON a.EstudanteID = e.EstudanteID AND a.CursoID = c.CursoID;

    RETURN v_result;
END fObterDetalhesEstudante;



CREATE OR REPLACE FUNCTION f_Contar_estudantes_por_curso(Curso_ID IN NUMBER) 
    RETURN NUMBER 
IS
    num_estudantes NUMBER;
BEGIN
    SELECT COUNT(*) INTO num_estudantes
    FROM Matriculas
    WHERE Curso_ID = f_Contar_estudantes_por_curso.Curso_ID 
    AND Status = 'Ativo';
    
    RETURN num_estudantes;

END f_Contar_estudantes_por_curso;



CREATE OR REPLACE FUNCTION f_Curso_Mais_Avaliado 
    RETURN NUMBER 
IS
    vCurso_mais_avaliado NUMBER;
BEGIN
    SELECT CursoID INTO vCurso_mais_avaliado
    FROM (
        SELECT CursoID, COUNT(*) AS num_avaliacoes
        FROM Avaliacoes
        GROUP BY CursoID
        ORDER BY num_avaliacoes DESC
    ) 
    WHERE ROWNUM = 1;
    RETURN vCurso_mais_avaliado;
    
END f_Curso_Mais_Avaliado;


CREATE OR REPLACE PACKAGE pckGestaoCursos IS
   

    PROCEDURE pRegistrarMatricula(v_EstudanteID IN NUMBER, v_CursoID IN NUMBER);
    PROCEDURE pRegistrarAvaliacao(v_CursoID IN NUMBER, v_EstudanteID IN NUMBER, v_Nota IN DECIMAL, v_Comentario IN VARCHAR2);
    PROCEDURE pAtualizarCurso(v_CursoID IN NUMBER, v_Nome IN VARCHAR2, v_Descricao IN VARCHAR2, v_InstrutorID IN NUMBER, v_Preco IN DECIMAL);
    PROCEDURE pRemoverCurso(v_CursoID IN NUMBER);
    PROCEDURE pCadastrarProfessor(v_Nome IN VARCHAR2, v_Especialidade IN VARCHAR2, v_Email IN VARCHAR2, v_CursoID IN NUMBER);

    
    FUNCTION fCalcularMediaNotasCurso(CursoID IN NUMBER) RETURN NUMBER;
    FUNCTION fObterDetalhesEstudante(EstudanteID IN NUMBER) RETURN VARCHAR2;
    FUNCTION f_Contar_estudantes_por_curso(Curso_ID IN NUMBER) RETURN NUMBER;
    FUNCTION f_Curso_Mais_Avaliado RETURN NUMBER;
END pckGestaoCursos;


CREATE OR REPLACE PACKAGE BODY pckGestaoCursos IS

    
    PROCEDURE pRegistrarMatricula(v_EstudanteID IN NUMBER, v_CursoID IN NUMBER) IS
    BEGIN
        INSERT INTO Matriculas (DataMatricula, Status, EstudanteID, CursoID)
        VALUES (SYSDATE, 'Ativo', v_EstudanteID, v_CursoID);
    END pRegistrarMatricula;

    
    PROCEDURE pRegistrarAvaliacao (v_CursoID IN NUMBER, v_EstudanteID IN NUMBER, v_Nota IN DECIMAL, v_Comentario IN VARCHAR2) IS
    BEGIN
        INSERT INTO Avaliacoes (Nota, Comentario, CursoID, EstudanteID)
        VALUES (v_Nota, v_Comentario, v_CursoID, v_EstudanteID);
    END pRegistrarAvaliacao;

    PROCEDURE pAtualizarCurso (v_CursoID IN NUMBER, v_Nome IN VARCHAR2, v_Descricao IN VARCHAR2, v_InstrutorID IN NUMBER, v_Preco IN DECIMAL) IS
    BEGIN
        UPDATE Cursos
        SET Nome = v_Nome, Descricao = v_Descricao, Preco = v_Preco
        WHERE CursoID = v_CursoID;

        DELETE FROM Instrui WHERE CursoID = v_CursoID;
        INSERT INTO Instrui VALUES (v_InstrutorID, v_CursoID);
    END pAtualizarCurso;

 
    PROCEDURE pRemoverCurso (v_CursoID IN NUMBER) IS
    BEGIN
        DELETE FROM Instrui WHERE CursoID = v_CursoID;
        DELETE FROM Cursos WHERE CursoID = v_CursoID;
    END pRemoverCurso;

   
    PROCEDURE pCadastrarProfessor (v_Nome IN VARCHAR2, v_Especialidade IN VARCHAR2, v_Email IN VARCHAR2, v_CursoID IN NUMBER) IS
        v_InstrutorID Instrutores.InstrutorID%TYPE;
    BEGIN
        INSERT INTO Instrutores (Nome, Especialidade, Email)
        VALUES (v_Nome, v_Especialidade, v_Email)
        RETURNING InstrutorID INTO v_InstrutorID;

        INSERT INTO Instrui VALUES (v_InstrutorID, v_CursoID);
    END pCadastrarProfessor;

    
    FUNCTION fCalcularMediaNotasCurso (CursoID IN NUMBER) RETURN NUMBER IS
        v_media NUMBER(4,2);
    BEGIN
        SELECT AVG(Nota) 
        INTO v_media
        FROM Avaliacoes
        WHERE CursoID = CursoID;

        IF v_media IS NULL THEN
            RETURN NULL;
        END IF;

        RETURN v_media;
    END fCalcularMediaNotasCurso;

    
    FUNCTION fObterDetalhesEstudante (EstudanteID IN NUMBER) RETURN VARCHAR2 IS
        v_result VARCHAR2(4000);
    BEGIN
        SELECT e.Nome || ' está matriculado no curso ' || c.Nome ||
               '  Data de Matrícula: ' || TO_CHAR(m.DataMatricula, 'DD-MM-YYYY') ||
               '  Status: ' || m.Status ||
               '  Nota: ' || NVL(TO_CHAR(a.Nota), 'Nenhuma nota')
        INTO v_result
        FROM Estudantes e
        JOIN Matriculas m ON e.EstudanteID = m.EstudanteID
        JOIN Cursos c ON m.CursoID = c.CursoID
        LEFT JOIN Avaliacoes a ON a.EstudanteID = e.EstudanteID AND a.CursoID = c.CursoID;

        RETURN v_result;
    END fObterDetalhesEstudante;

   
    FUNCTION f_Contar_estudantes_por_curso (Curso_ID IN NUMBER) RETURN NUMBER IS
        num_estudantes NUMBER;
    BEGIN
        SELECT COUNT(*) INTO num_estudantes
        FROM Matriculas
        WHERE Curso_ID = Curso_ID AND Status = 'Ativo';

        RETURN num_estudantes;
    END f_Contar_estudantes_por_curso;

   
    FUNCTION f_Curso_Mais_Avaliado RETURN NUMBER IS
        vCurso_mais_avaliado NUMBER;
    BEGIN
        SELECT CursoID INTO vCurso_mais_avaliado
        FROM (
            SELECT CursoID, COUNT(*) AS num_avaliacoes
            FROM Avaliacoes
            GROUP BY CursoID
            ORDER BY num_avaliacoes DESC
        )
        WHERE ROWNUM = 1;

        RETURN vCurso_mais_avaliado;
    END f_Curso_Mais_Avaliado;

END pckGestaoCursos;

