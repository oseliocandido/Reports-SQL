SELECT 
	[Cod_Empresa],
	[Bem],
	[Centro_Custo],
	[nome_servico],
	CONVERT(CHAR,[Real_Parada_DTInicio]) + ' ' + [Real_Parada_HInicio] + ':00' AS 'Inicio',
 	CONVERT(CHAR,[Real_Parada_DTFim]) + ' ' + [Real_Parada_HFim] + ':00' AS 'Fim',
	[Termino],
 	[Situacao_OS],
 	[Ordem_Serv] + [Plano_Manut] AS 'Relacio_ordem_plano' 
FROM [DW].[fato].[STJ_OS_MANUTENCAO]
WHERE [Real_Parada_DTInicio] BETWEEN '2020-01-01' 
AND CONVERT(DATE,GETDATE()) AND [Real_Parada_HInicio] <> ' ' 
AND [Real_Parada_HInicio] <> ' : '"]),