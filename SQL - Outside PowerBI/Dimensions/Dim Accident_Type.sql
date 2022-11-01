ALTER PROCEDURE [dim].[stpEspecie_Acidente]
AS

	TRUNCATE TABLE [dim].[Dimensao_EspecieAcidente]


			INSERT INTO [dim].[Dimensao_EspecieAcidente]
		(
			[CodEsp] ,
			[DesEsp] ,
			[EspCat] ,
			[CdNB18] ,
			[DesCpl] ,
			[ObsAgt] 
		)
		SELECT 
			[CodEsp] ,
			[DesEsp] ,
			[EspCat] ,
			[CdNB18] ,
			[DesCpl] ,
			[ObsAgt] 
		  FROM BI_Staging.[carga].[R086ESP]


UPDATE [dim].Dimensao_EspecieAcidente
SET Classificacao_Geral = 'SMS'
WHERE CodEsp  IN (1,2)
UPDATE [dim].Dimensao_EspecieAcidente
SET Descritivo_Geral = 'Sem Maior Significância'
WHERE CodEsp  IN (1,2)


UPDATE [dim].Dimensao_EspecieAcidente
SET Classificacao_Geral = 'SAA'
WHERE CodEsp  IN (3,4)
UPDATE [dim].Dimensao_EspecieAcidente
SET Descritivo_Geral = 'Simples Atendimento Laboratorial'
WHERE CodEsp  IN (3,4)


UPDATE [dim].Dimensao_EspecieAcidente
SET Classificacao_Geral = 'SPT'
WHERE CodEsp  IN (5,6)
UPDATE [dim].Dimensao_EspecieAcidente
SET Descritivo_Geral= 'Sem Perda de Tempo'
WHERE CodEsp  IN (5,6)


UPDATE [dim].Dimensao_EspecieAcidente
SET Classificacao_Geral = 'CPT'
WHERE CodEsp  IN (7,8)
UPDATE [dim].Dimensao_EspecieAcidente
SET Descritivo_Geral = 'Com Perda de Tempo'
WHERE CodEsp  IN (7,8)


UPDATE [dim].Dimensao_EspecieAcidente
SET Classificacao_Geral = DesEsp
WHERE CodEsp NOT IN (1,2,3,4,5,6,7,8)
UPDATE [dim].Dimensao_EspecieAcidente
SET Descritivo_Geral = DesCpl
WHERE CodEsp NOT IN (1,2,3,4,5,6,7,8)
