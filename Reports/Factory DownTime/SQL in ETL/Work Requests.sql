SELECT 
	[Bem/Localiz],
	[Centro_Custo],
	[Dt_Abertura],
	[Tipo_Servico],
	[Cod_Empresa],
	[Situacao_SS] 
FROM FATO.TQB_SOLICITACAO_SERVICO
WHERE Dt_Abertura BETWEEN '2020-01-01' AND CONVERT(DATE,GETDATE())