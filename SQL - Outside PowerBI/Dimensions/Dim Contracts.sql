USE [BI_DW]
GO
/****** Object:  StoredProcedure [dim].[stpDimensao_Local]    Script Date: 01/11/2022 07:58:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dim].[stpDimensao_Local]
AS BEGIN
    
	/*
	Never drop and truncate this table

	IF drop this table, excute the following code below
	INSERT INTO dim.Dimensao_Local SELECT 0, 0, 0, 'Sem Local', ''


	CREATE TABLE dim.Dimensao_Local
	(
		Id_Local INT NOT NULL,
		Id_Organizacao INT,
		Cd_Local INT,
		Ds_Local VARCHAR(60),
		Ordem_Local VARCHAR(150)
	)

	ALTER TABLE dim.Dimensao_Local ADD Ordem_Pai VARCHAR(150)
	ALTER TABLE dim.Dimensao_Local ADD Flag_Pai INT 
	ALTER TABLE dim.Dimensao_Local ADD Segmento varchar(200)
	ALTER TABLE dim.Dimensao_Local ADD Nome_Ordem_Pai VARCHAR(100)

	*/

		IF(OBJECT_ID('BI_DW.dim.Import_Local') IS NOT NULL) DROP TABLE dim.Import_Local
		CREATE TABLE dim.Import_Local
		(
			Id_Local INT,
			Id_Organizacao INT,
			Cd_Local INT,
			Ds_Local VARCHAR(60),
			Ordem_Local VARCHAR(150),
			CN VARCHAR(60)
		)

		INSERT INTO dim.Import_Local
		(
			Id_Local,
			Id_Organizacao,
			Cd_Local,
			Ds_Local,
			Ordem_Local,
			CN
		)
		SELECT Id_Local,
			   A.TabOrg,
			   A.NumLoc,
			   A.NomLoc,
			   C.CodLoc,
			   '' CN
		FROM BI_Staging.carga.R016ORN A
		LEFT JOIN dim.Dimensao_Local B ON A.TabOrg = B.Id_Organizacao AND A.NumLoc = B.Cd_Local
		LEFT JOIN BI_Staging.carga.R016HIE C ON C.NumLoc = A.NumLoc AND C.TabOrg = A.TabOrg
		where A.TabOrg  in (5,8,9,10,13,14)

		--Insere registros novos
		IF(OBJECT_ID('BI_DW.dim.Novo_Local') IS NOT NULL) DROP TABLE dim.Novo_Local
		SELECT Identity(int,1,1) Id_Local,
			Id_Organizacao,
			Cd_Local,
			Ds_Local,
			Ordem_Local,
			'' CN
		INTO dim.Novo_Local
		FROM dim.Import_Local A 
		WHERE A.Id_Local IS NULL
		ORDER BY 1

		--Registro de número máximo da Dimensão
		DECLARE @Max_Id_Local int
		SELECT @Max_Id_Local = Max(Id_Local) FROM dim.Dimensao_Local

		--Caso não existe/For a primeira vez, atualiza como zero
		IF (@Max_Id_Local IS NULL)
		BEGIN
			SET @Max_Id_Local = 0
		END

		INSERT INTO dim.Dimensao_Local
		(
		    Id_Local,
		    Id_Organizacao,
		    Cd_Local,
		    Ds_Local,
			Ordem_Local,
			CN
		)
		SELECT Id_Local + @Max_Id_Local,
		    Id_Organizacao,
		    Cd_Local,
		    Ds_Local,
			Ordem_Local,
			'' CN
		FROM dim.Novo_Local


		UPDATE A
		SET A.Ordem_Pai = CLR.dbo.fncSplit_Ate(Ordem_Local, '.', 3)
		FROM dim.Dimensao_Local A
		
		UPDATE A
		SET A.Flag_Pai = CASE WHEN Ordem_Local = Ordem_Pai THEN 1 ELSE 0 END
		FROM dim.Dimensao_Local A

		UPDATE A
		SET A.NOME_ORDEM_PAI = B.DS_LOCAL
		FROM dim.Dimensao_Local A
		JOIN (SELECT * FROM BI_DW.dim.Dimensao_Local WHERE Flag_Pai = 1) B
        ON B.Id_Organizacao = A.Id_organizacao AND B.Ordem_Pai= A.Ordem_Pai

		-- Updating the Cost Centers

		--1
		update A
        set A.CN = right(A.Ds_Local,9)
		FROM dim.Dimensao_Local A

		--2
		update A
        set A.CN = right(SUBSTRING(A.Ds_Local,-3,patindex('%tom%',A.ds_local)),9)
		FROM dim.Dimensao_Local A
        where left( right(SUBSTRING(A.Ds_Local,-3,patindex('%tom%',A.ds_local)),9),2) = '10'

		--3
		update A
        set A.CN = '1'+A.CN
		FROM dim.Dimensao_Local A
        where left(A.CN,2) <> '10'
        and left(A.CN,1) = '0'

		--4
		update A
        set A.CN = right(SUBSTRING(A.Ds_Local,-2,patindex('%tom%',A.ds_local)),9)
		FROM dim.Dimensao_Local A
        where left(A.CN,2) <> '10'

		--5
		update A
        set A.CN = rtrim( ltrim( right( SUBSTRING(A.Ds_Local,12,patindex('% - %',A.ds_local)),10)))
		FROM dim.Dimensao_Local A
        where left(A.CN,2) <> '10'

		--6
		update A
        set A.CN= replace(rtrim(ltrim( right(SUBSTRING(A.Ds_Local,10,patindex('%10%',A.ds_local)),11))),'-','')
        FROM dim.Dimensao_Local A
		where left(A.CN,2) <> '10'
        and left(A.CN,2) <> '11'

		--7 REMOVENDO ESPAÇOS
		update A
        set A.CN = ltrim(rtrim(A.CN))
		FROM dim.Dimensao_Local A

		--8 adicionando ds_centro_custo
		update A
        set A.ds_centro_custo = b.Ds_Centro_Custo
        FROM bi_dw.dim.Dimensao_Local A
		left join bi_dw.dim.Dimensao_Centro_de_Custo b on a.cn = b.Cd_Centro_Custo
		
		-- alteração nas gerencias 01.06.11 para 01.06.10 

		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
        where cn = '106120202'

		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
        where cn = '106120302'
		
		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
		where cn = '106120101'


		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
		where Ordem_Local = '01.06.11.001'

		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
		where Ordem_Local = '01.06.11.001.001'

		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
		where Ordem_Local = '01.06.11.002'

		update bi_dw.dim.Dimensao_Local
        set Ordem_Pai = '01.06.10'
		where Ordem_Local = '01.06.11.002.001'

		--alterando o nome da gerencia
		

		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
        where cn = '106120202'

		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
        where cn = '106120302'
		
		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
		where cn = '106120101'


		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
		where Ordem_Local = '01.06.11.001'

		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
		where Ordem_Local = '01.06.11.001.001'

		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
		where Ordem_Local = '01.06.11.002'

		update bi_dw.dim.Dimensao_Local
        set Nome_Ordem_Pai = 'Gerência Negócios de Base - 106110101'
		where Ordem_Local = '01.06.11.002.001'

		IF(OBJECT_ID('BI_DW.dim.Import_Local') IS NOT NULL) DROP TABLE dim.Import_Local
		IF(OBJECT_ID('BI_DW.dim.Novo_Local') IS NOT NULL) DROP TABLE dim.Novo_Local
END