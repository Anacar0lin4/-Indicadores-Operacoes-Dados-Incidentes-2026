CREATE OR REPLACE TABLE default.incidentes_bi AS
WITH TABELA_INCIAL AS (
SELECT 
        id_incidente,
        ROW_NUMBER() OVER(PARTITION BY id_incidente ORDER BY data_incidente DESC) AS rn_id,
        ROW_NUMBER() OVER(PARTITION BY id_incidente ORDER BY updated_at DESC) AS rn_id_2,
        descricao_incidente,
        area_origem,
        sistema_afetado,
        tipo_sistema,
        ambiente,
        categoria_problema,
        subcategoria_problema,
        tipo_incidente,
        prioridade,
        SLA_min,
        origem_incidente,
        causa_raiz,
        reincidente,
        data_incidente,
        area_responsavel,
        data_inicio_tratativa,
        data_redirecionamento_incidente,
        data_incidente_resolvido,
        origem_incidente,
        updated_at
 FROM workspace.default.incidentes_banco_digital_1
)

SELECT 
        id_incidente,
        REPLACE(area_origem,'_',' ') AS area_origem,
        REPLACE(categoria_problema,'_',' ') AS categoria_problema,
        REPLACE(subcategoria_problema,'_',' ') AS subcategoria_problema,
        REPLACE(tipo_incidente,'_',' ') AS tipo_incidente,
        REPLACE(sistema_afetado,'_',' ') AS sistema_afetado,
        REPLACE(tipo_sistema, '_',' ') AS tipo_sistema,
        ambiente,
        area_responsavel,
        prioridade,
        AVG(TIMESTAMPDIFF(MINUTE,data_inicio_tratativa, data_incidente_resolvido)) AS mttr_minutos,
        AVG(TIMESTAMPDIFF(MINUTE,data_inicio_tratativa, data_incidente)) AS mdt_minutos,
        CASE WHEN AVG(TIMESTAMPDIFF(MINUTE,data_inicio_tratativa, data_incidente_resolvido)) > SLA_min THEN 'Não' ELSE 'Sim' END AS SLA_NO_PRAZO,
        CASE WHEN data_incidente_resolvido IS NULL THEN 'Aberto' ELSE 'Fechado' END AS status_geral,
        CASE WHEN data_inicio_tratativa IS NULL THEN 'Aberto' 
             WHEN data_incidente_resolvido IS NULL THEN 'Em tratativa'
             WHEN TIMESTAMPDIFF(MINUTE,data_inicio_tratativa, data_incidente_resolvido) <= SLA_min THEN 'Fechado no prazo' ELSE 'Fechado fora do prazo' END AS status_operacional,
        CASE WHEN prioridade = 'P0' THEN 'Critica' 
             WHEN prioridade = 'P1' THEN 'Alta'
             WHEN prioridade = 'P2' THEN 'Media'
             ELSE 'Baixa' END AS severidade,
        REPLACE(descricao_incidente,'_', ' ') AS descricao_incidente,
        SLA_min,
        origem_incidente,
        REPLACE(causa_raiz, '_', ' ') AS causa_raiz,
        reincidente,
        data_incidente,
        DATE_FORMAT(data_incidente,'yyyy-MM-dd') as data_incidente_format,
        DATE_FORMAT(data_incidente, 'yyyy-MM') as safra_incidente,
        data_inicio_tratativa,
        data_redirecionamento_incidente,
        data_incidente_resolvido,
        DATE_FORMAT(data_incidente_resolvido,'yyyy-MM') as safra_resolucao 
FROM TABELA_INCIAL
WHERE rn_id = 1 AND rn_id_2 = 1
GROUP BY ALL



