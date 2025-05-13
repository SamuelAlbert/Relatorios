DECLARE @DataInicial DATE = '2025-04-01'
DECLARE @DataFinal DATE = '2025-04-30'
DECLARE @NomeTabelaPreco VARCHAR(20) = 'CUSTO'
DECLARE @Filial INT = 0
DECLARE @Classe INT
DECLARE @SubClasse INT
DECLARE @Grupo INT
DECLARE @Familia INT
DECLARE @Vendedor1 INT

SELECT
    CONCAT(F.Codigo, ' - ', F.Nome) Filial
	,SUM(CASE WHEN M.Tipo_Operacao IN ('VND', 'VPC', 'VEF', 'FPV') THEN M.Preco_Final_Somado ELSE M.Preco_Final_Somado *-1 END) PrecoTotal
	--,Operacoes.Codigo Operacao
    ,CONCAT('Impresso em ', FORMAT(GETDATE(),'dd/MM/yyyy')) ImpressoEm
    ,CONCAT(FORMAT(@DataInicial,'dd/MM/yyyy') , ' ate ', FORMAT(@DataFinal,'dd/MM/yyyy')) DataPeriodo
    ,'V.1.0' VersaoRelatorio --Criado em 09/05/2025

FROM
    Movimento M
    JOIN Filiais F ON F.Ordem = M.Ordem_Filial
    JOIN Operacoes ON Operacoes.Ordem = M.Ordem_Operacao

WHERE
    F.Ordem = CASE WHEN @Filial IS NULL OR @Filial = '' OR @Filial = 0 THEN F.Ordem ELSE @Filial END
    AND M.Data_Passou_Efetivacao_Estoque >= @DataInicial
    AND M.Data_Passou_Efetivacao_Estoque < DATEADD(D,1,@DataFinal)
    AND M.Data_Passou_Desefetivacao_Estoque IS NULL
    AND M.Tipo_Operacao IN ('VND', 'VPC', 'VEF', 'FPV', 'DEV', 'CVE')
	AND Operacoes.Codigo IN ('520', '60', '62', '871', '867', '853', '854', '860', '864')
    --AND Tabelas_Preco.Ordem = @NomeTabelaPreco


GROUP BY 
	F.Codigo
    ,F.Nome
	--,Operacoes.Codigo
