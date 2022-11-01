SELECT 
	VALOR.*,
	GERENCIA.Gerencia 

FROM 

(
SELECT
  C.CODCLI AS CODCLI,
  C.CLIENTE,
  --C.CEPENT AS CEP,
  --C.ENDERENT AS ENDERECO,
  --C.BAIRROENT AS BAIRRO,
  C.MUNICENT AS MUNICIPIO,
  --C.CGCENT AS CNPJ,
  --C.IEENT AS IE,
  C.BLOQUEIO,
  C.OBS AS "MOTIVO BLOQUEIO",
  C.CODUSUR1 AS CODRCA1,
  U.NOME AS RCA,
  S.CODSUPERVISOR,
  S.NOME AS SUPERVISOR,
  --C.FANTASIA,
  I.RAMO,
  --C.LIMCRED,
  C.DTULTCOMP,
  --C.ESTENT,
  C.DTBLOQ ,
  C.DTCADASTRO,
  --C.DTEXCLUSAO,
  --C.DTPRIMCOMPRA
FROM
  PCCLIENT C, PCUSUARI U, PCSUPERV S, PCATIVI I
WHERE
  C.CODUSUR1 = U.CODUSUR(+)
  AND I.CODATIV=C.CODATV1 
  AND U.CODSUPERVISOR = S.CODSUPERVISOR
  AND C.DTEXCLUSAO IS NULL
  
UNION ALL

SELECT
  C.CODCLI AS CODCLI,
  C.CLIENTE,
  --C.CEPENT AS CEP,
  --C.ENDERENT AS ENDERECO,
  --C.BAIRROENT AS BAIRRO,
  C.MUNICENT AS  MUNICIPIO,
  --C.CGCENT AS CNPJ,
  --C.IEENT AS IE,
  C.BLOQUEIO,
  C.OBS AS "MOTIVO BLOQUEIO",
  U2.CODUSUR AS CODRCA1,
  U.NOME AS RCA,
  S.CODSUPERVISOR,
  S.NOME AS SUPERVISOR,
  --C.FANTASIA,
  I.RAMO,
  --C.LIMCRED,
  C.DTULTCOMP,
  --C.ESTENT,
  C.DTBLOQ,
  C.DTCADASTRO
  --C.DTEXCLUSAO,
  --C.DTPRIMCOMPRA
FROM
  PCCLIENT C, PCUSUARI U, PCSUPERV S, PCUSURCLI U2, PCATIVI I
WHERE
  U2.CODUSUR = U.CODUSUR
  AND I.CODATIV=C.CODATV1
  AND U2.CODCLI=C.CODCLI
  AND U.CODSUPERVISOR = S.CODSUPERVISOR
  AND C.DTEXCLUSAO IS NULL 
 ) VALOR
 
LEFT JOIN 
 
(SELECT 
	S.codsupervisor AS COD_SUPERVISOR,
    	CASE 
	    WHEN S.CODSUPERVISOR IN (9111,9114,9116,9119,9121,9122,9124,9125,9131,9132,9137,9141,9142,9143,9145,9146,9147) THEN 'G.C Varejo'
            WHEN S.CODSUPERVISOR IN (9135) THEN 'G.A Regionais'
            WHEN S.CODSUPERVISOR IN (1) THEN 'G.A Atacado'
            WHEN S.CODSUPERVISOR IN (9107) THEN 'G.A Unipar'
            ELSE 'Outros' END AS Gerencia
    
FROM PCSUPERV S) GERENCIA 
ON GERENCIA.COD_SUPERVISOR = VALOR.CODSUPERVISOR

WHERE VALOR.SUPERVISOR LIKE '%EQUIPE%'
AND VALOR.CODSUPERVISOR NOT IN (9140,9136,9123,9133,9130)