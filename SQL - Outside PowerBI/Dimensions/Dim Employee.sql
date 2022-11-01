ALTER PROCEDURE [dim].[stpDimensao_Funcionario]
AS BEGIN

	  --Registro de número máximo da Dimensão
		DECLARE @Max_Id_Funcionario int
		SELECT @Max_Id_Funcionario = Max(Id_Funcionario) FROM dim.Dimensao_Funcionario

		 IF(@Max_Id_Funcionario IS NULL)
		 BEGIN
			SET @Max_Id_Funcionario = 0
		 END

		IF(OBJECT_ID('BI_DW.dim.Import_Funcionario') IS NOT NULL) DROP TABLE dim.Import_Funcionario
		CREATE TABLE dim.Import_Funcionario
		(
			Id_Funcionario INT,
			Cd_Empresa INT,
			Cd_Funcionario INT,
			Tipo_Col INT,
			Id_Organizacao INT,
			Ds_Funcionario VARCHAR(40),
			Sexo VARCHAR(1),
			Dt_Admissao DATETIME,
			Dt_Afastamento DATETIME,
			Id_Situacao INT,
			Cd_Situacao INT,
			Id_Local INT,
			Cd_Local INT,
			Ds_Local VARCHAR(60),
			Id_Centro_Custo INT,
			Cd_Centro_Custo VARCHAR(18),
			Cd_Categoria INT,
			Id_Cargo INT,
			Cd_Cargo VARCHAR(24),
			Cd_Empresa_Cargo INT
		)

		INSERT INTO dim.Import_Funcionario
		(
		    Id_Funcionario,
		    Cd_Empresa,
		    Cd_Funcionario,
		    Tipo_Col,
		    Id_Organizacao,
		    Ds_Funcionario,
		    Sexo,
		    Dt_Admissao,
			Dt_Afastamento,
		    Cd_Situacao,
		    Cd_Local,
		    Cd_Centro_Custo,
			Cd_Categoria,
			Cd_Cargo,
			Cd_Empresa_Cargo
		)
		SELECT B.Id_Funcionario,
			A.numemp,
			A.numcad,
			A.tipcol,
			A.taborg,
			A.nomfun,
			A.tipsex,
			A.datadm,
			A.datafa,
			A.sitafa,
			A.numloc,
			A.codccu,
			A.cateso,
			A.codcar,
			A.estcar
		FROM BI_Staging.carga.R034FUN A
		JOIN dim.Dimensao_Funcionario B ON A.numemp = B.Cd_Empresa AND A.numcad = B.Cd_Funcionario AND A.tipcol = B.Tipo_Col AND A.taborg = B.Id_Organizacao

		UNION

		SELECT ROW_NUMBER() OVER(ORDER BY A.numemp, A.numcad)+@Max_Id_Funcionario Id_Funcionario,
			A.numemp,
			A.numcad,
			A.tipcol,
			A.taborg,
			A.nomfun,
			A.tipsex,
			A.datadm,
			A.datafa,
			A.sitafa,
			A.numloc,
			A.codccu,
			A.cateso,
			A.codcar,
			A.estcar
		FROM BI_Staging.carga.R034FUN A
		LEFT JOIN dim.Dimensao_Funcionario B ON A.numemp = B.Cd_Empresa AND A.numcad = B.Cd_Funcionario AND A.tipcol = B.Tipo_Col AND A.taborg = B.Id_Organizacao
		WHERE B.Id_Funcionario IS NULL

		--Atualiza Situacao
		UPDATE A
		SET A.Id_Situacao = B.Id_Situacao
		FROM dim.Import_Funcionario A
		JOIN dim.Dimensao_Situacao B ON B.Cd_Situacao = A.Cd_Situacao


		--Atualiza Local
		UPDATE A
		SET A.Id_Local = B.Id_Local,
			A.Ds_Local = B.Ds_Local
		FROM dim.Import_Funcionario A
		JOIN dim.Dimensao_Local B ON B.Cd_Local = A.Cd_Local AND B.Id_Organizacao = A.Id_Organizacao

		UPDATE A
		SET A.Id_Local = 0
		FROM dim.Import_Funcionario A
		WHERE A.Id_Local IS NULL


		--Atualiza Centro de Custo
		UPDATE A
		SET A.Id_Centro_Custo = B.Id_Centro_Custo
		FROM dim.Import_Funcionario A
		JOIN dim.Dimensao_Centro_de_Custo B ON B.Cd_Centro_Custo = A.Cd_Centro_Custo AND B.Base = 'Vetorh'

		UPDATE A
		SET A.Id_Centro_Custo = 0
		FROM dim.Import_Funcionario A
		WHERE A.Id_Centro_Custo IS NULL


		--Atualiza Cargo
		UPDATE A
		SET A.Id_Cargo = B.Id_Cargo
		FROM dim.Import_Funcionario A
		JOIN dim.Dimensao_Cargo B ON B.CodCar = A.Cd_Cargo AND B.EstCar = A.Cd_Empresa_Cargo

		UPDATE A
		SET A.Id_Cargo = 0
		FROM dim.Import_Funcionario A
		WHERE A.Id_Cargo IS NULL


		EXEC dbo.stpETL_Upsert @Nm_Source = 'BI_DW.dim.Import_Funcionario',   -- varchar(max)
		                       @Nm_Target = 'BI_DW.dim.Dimensao_Funcionario',   -- varchar(max)
		                       @Cd_Join = 'Id_Funcionario',     -- varchar(max)
		                       @Cd_Chave = '',    -- varchar(max)
		                       @Fl_Update = 1, -- bit
		                       @Fl_Debug = 0   -- bit
		
		
		--Deletando tabelas que não são usadas
		IF(OBJECT_ID('BI_DW.dim.Import_Funcionario') IS NOT NULL) DROP TABLE dim.Import_Funcionario
	
END 