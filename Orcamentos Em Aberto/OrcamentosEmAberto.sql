DECLARE @Filial	INT = 1
DECLARE @Funcionario INT = 0

SELECT Operacoes.Codigo
 ,CONCAT([Funcionarios].[Codigo], ' - ', [Funcionarios].[Nome]) AS Vendedor
 ,Movimento.Preco_Final_Somado
 ,FORMAT(Movimento.Data, 'dd/MM/yyyy') Data
 ,Movimento.Sequencia
 ,CONCAT([Cli_For].[Codigo], ' - ', [Cli_For].[Nome]) AS Cliente
 ,Movimento.Observacao
 ,Movimento.Referencia_Interna
 ,CONCAT(Filiais.Codigo, ' - ', Filiais.Nome) Filial
 ,CASE WHEN @Funcionario = 0 OR @Funcionario IS NULL OR @Funcionario = '' THEN 'Todos' ELSE CONCAT([Funcionarios].[Codigo], ' - ', [Funcionarios].[Nome]) END FiltroFuncionario
 ,CONCAT('Impresso em ', FORMAT(GETDATE(),'dd/MM/yyyy')) ImpressoEm
 ,'V.1.0' VersaoRelatorio
FROM (
 (
  Operacoes INNER JOIN (
   Movimento INNER JOIN Filiais ON Movimento.Ordem_Filial = Filiais.Ordem
   ) ON Operacoes.Ordem = Movimento.Ordem_Operacao
  ) INNER JOIN Funcionarios ON Movimento.Ordem_Vendedor1 = Funcionarios.Ordem
 )
INNER JOIN Cli_For ON Movimento.Ordem_Cli_For = Cli_For.Ordem
WHERE (
  ((Filiais.Codigo) = 22)
  AND ((Operacoes.Codigo) = 550)
  AND ((Operacoes.Entrada_Saida) = 'S')
  AND ((Movimento.Apagado) = 0)
  AND Funcionarios.Ordem = CASE WHEN @Funcionario = 0 OR @Funcionario IS NULL OR @Funcionario = '' THEN Funcionarios.Ordem ELSE @Funcionario END
  AND Filiais.Ordem = CASE WHEN @Filial = 0 OR @Filial IS NULL OR @Filial = '' THEN Filiais.Ordem ELSE @Filial END
  AND Movimento.Data < CAST(GETDATE() AS DATE)
  )
ORDER BY CONCAT([Funcionarios].[Codigo], ' - ', [Funcionarios].[Nome])
 ,Movimento.Data;