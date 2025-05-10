DECLARE @DataInicial DATE = '2025-05-08'
DECLARE @DataFinal DATE = '2025-05-08'
DECLARE @NomeTabelaPreco VARCHAR(20) = 'CUSTO'
DECLARE @Filial INT = 1
DECLARE @Classe INT
DECLARE @SubClasse INT
DECLARE @Grupo INT
DECLARE @Familia INT
DECLARE @Vendedor1 INT

SELECT
    PS.Codigo
    ,PS.Codigo_Adicional1
    ,PS.Nome
    ,SUM(CASE WHEN M.Tipo_Operacao IN ('VND', 'VPC', 'VEF', 'FPV') THEN MPS.Quantidade ELSE MPS.Quantidade * -1 END) QuantidadeVendida
    ,SUM(CASE WHEN M.Tipo_Operacao IN ('VND', 'VPC', 'VEF', 'FPV') THEN MPS.Preco_Final_Relatorio ELSE MPS.Preco_Final_Relatorio *-1 END) PrecoVenda
    ,MAX(Tabelas_Preco.Nome) TabelaPreco
    ,ROUND(MAX(Prod_Serv_Precos.Preco), 2) PrecoCusto
    ,MAX(EA.Qtde_Estoque_Atual) EstoqueAtual
    ,MAX(EA.Estoque_Minimo) EstoqueMinimo
    ,CONCAT(FORNECEDOR.Codigo, ' - ', FORNECEDOR.Nome) Fornecedor
    ,CONCAT(F.Codigo, ' - ', F.Nome) Filial
    ,CONCAT('Impresso em ', FORMAT(GETDATE(),'dd/MM/yyyy')) ImpressoEm
    ,CONCAT(FORMAT(@DataInicial,'dd/MM/yyyy') , ' at� ', FORMAT(@DataFinal,'dd/MM/yyyy')) DataPeriodo
    ,'V.1.0' VersaoRelatorio --Criado em 09/05/2025
    ,CASE WHEN @Classe IS NULL OR @Classe = '' OR @Classe = 0 THEN 'Todos' ELSE CONCAT(Classes.Codigo, ' - ', Classes.Nome) END FiltroClasse
    ,CASE WHEN @SubClasse IS NULL OR @SubClasse = '' OR @SubClasse = 0 THEN 'Todos' ELSE CONCAT(Subclasses.Codigo, ' - ', Subclasses.Nome) END FiltroSubclasse
    ,CASE WHEN @Grupo IS NULL OR @Grupo = '' OR @Grupo = 0 THEN 'Todos' ELSE CONCAT(Grupos.Codigo, ' - ', Grupos.Nome) END FiltroGrupo
    ,CASE WHEN @Familia IS NULL OR @Familia = '' OR @Familia = 0 THEN 'Todos' ELSE CONCAT(Familias.Codigo, ' - ', Familias.Nome) END FiltroFamilia
    ,CASE WHEN @Vendedor1 IS NULL OR @Vendedor1 = '' OR @Vendedor1 = 0 THEN 'Todos' ELSE CONCAT(MAX(Funcionarios.Codigo), ' - ', MAX(Funcionarios.Nome)) END FiltroVendedor

FROM
    Movimento M
    JOIN Movimento_Prod_Serv MPS ON M.Ordem = MPS.Ordem_Movimento
    JOIN Prod_Serv PS ON MPS.Ordem_Prod_Serv = PS.Ordem
    JOIN Filiais F ON F.Ordem = M.Ordem_Filial
    JOIN Classes ON Classes.Ordem = PS.Ordem_Classe
    JOIN Subclasses ON Subclasses.Ordem = PS.Ordem_Subclasse
    JOIN Operacoes ON Operacoes.Ordem = M.Ordem_Operacao
    JOIN Funcionarios ON Funcionarios.Ordem = MPS.Ordem_Vendedor
    JOIN Grupos ON Grupos.Ordem = PS.Ordem_Grupo
    JOIN Familias ON Familias.Ordem = PS.Ordem_Familia
    JOIN Prod_Serv_Precos ON Prod_Serv_Precos.Ordem_Prod_Serv = PS.Ordem
    JOIN Tabelas_Preco ON Tabelas_Preco.Ordem = Prod_Serv_Precos.Ordem_Tabela_Preco
    JOIN Estoque_Atual EA ON (EA.Ordem_Prod_Serv = PS.Ordem AND EA.Ordem_Filial = F.Ordem)
    JOIN Cli_For FORNECEDOR ON FORNECEDOR.Ordem = PS.Ordem_Fornecedor1

WHERE
    F.Ordem = CASE WHEN @Filial IS NULL OR @Filial = '' OR @Filial = 0 THEN F.Ordem ELSE @Filial END
    AND M.Data_Passou_Efetivacao_Estoque >= @DataInicial
    AND M.Data_Passou_Efetivacao_Estoque < DATEADD(D,1,@DataFinal)
    AND M.Data_Passou_Desefetivacao_Estoque IS NULL
    AND MPS.Linha_Excluida = 0
    AND Classes.Ordem = CASE WHEN @Classe IS NULL OR @Classe = '' OR @Classe = 0 THEN Classes.Ordem ELSE @Classe END
    AND Subclasses.Ordem = CASE WHEN @SubClasse IS NULL OR @SubClasse = '' OR @SubClasse = 0 THEN Subclasses.Ordem ELSE @SubClasse END
    AND Grupos.Ordem = CASE WHEN @Grupo IS NULL OR @Grupo = '' OR @Grupo = 0 THEN Grupos.Ordem ELSE @Grupo END
    AND Familias.Ordem = CASE WHEN @Familia IS NULL OR @Familia = '' OR @Familia = 0 THEN Familias.Ordem ELSE @Familia END
    AND Funcionarios.Ordem = CASE WHEN @Vendedor1 IS NULL OR @Vendedor1 = '' OR @Vendedor1 = 0 THEN Funcionarios.Ordem ELSE @Vendedor1 END
    AND M.Tipo_Operacao IN ('VND', 'VPC', 'VEF', 'FPV', 'DEV', 'CVE')
    AND Tabelas_Preco.Nome = @NomeTabelaPreco
    --AND Tabelas_Preco.Ordem = @NomeTabelaPreco


GROUP BY 
    PS.Codigo
    ,PS.Codigo_Adicional1
    ,PS.Nome
    ,CONCAT(FORNECEDOR.Codigo, ' - ', FORNECEDOR.Nome)
    ,F.Codigo
    ,F.Nome
    ,Classes.Codigo
    ,Classes.Nome
    ,Subclasses.Codigo
    ,Subclasses.Nome
    ,Grupos.Codigo
    ,Grupos.Nome
    ,Familias.Codigo
    ,Familias.Nome


HAVING 
    (MAX(EA.Qtde_Estoque_Atual) <=2 OR (MAX(EA.Qtde_Estoque_Atual) <= MAX(EA.Estoque_Minimo)))