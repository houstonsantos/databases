-- ZABBIX - NÃO UTILIZAR (TESTE)
CREATE VIEW `alarms-zabbix` AS
    SELECT
        DISTINCT(h.hostid) AS "host.id",
        h.host  AS "host.hostname",
        it.ip AS "host.ip",
        p.eventid AS "event.id", 
        p.objectid AS "trigger.id", 
        FROM_UNIXTIME(p.clock) AS "event.start",
        CASE p.r_clock
            WHEN 0 THEN FROM_UNIXTIME(p.clock)
            ELSE FROM_UNIXTIME(p.r_clock)
        END AS "event.end",
        p.name AS "event.reason",
        CASE p.severity 
            WHEN 0 THEN "major"
            WHEN 2 THEN "warning"
            WHEN 3 THEN "minor"
            WHEN 4 THEN "critical"
        END AS "event.severity",
        t.value AS "event.status",
        'Zabbix' AS "event.dataset",
        'alerts' AS "event.module"
    FROM problem AS p
      INNER JOIN triggers AS t ON p.objectid = t.triggerid
      INNER JOIN functions AS f ON f.triggerid = t.triggerid
      INNER JOIN items AS i ON i.itemid = f.itemid
      INNER JOIN hosts AS h ON h.hostid = i.hostid
      INNER JOIN interface AS it ON it.hostid = h.hostid
    WHERE
       p.objectid NOT IN(SELECT triggerid_down FROM trigger_depends
    WHERE 
       triggerid_down IN(SELECT objectid FROM problem) AND
       triggerid_up IN(SELECT objectid FROM problem));


CREATE VIEW `alarms-zabbix` AS
    SELECT
        DISTINCT(h.hostid) AS "host.id",
        h.host  AS "host.hostname",
        it.ip AS "host.ip",
        p.eventid AS "event.id", 
        p.objectid AS "trigger.id", 
        FROM_UNIXTIME(p.clock) AS "event.start",
        CASE p.r_clock
            WHEN 0 THEN FROM_UNIXTIME(p.clock)
            ELSE FROM_UNIXTIME(p.r_clock)
        END AS "event.end",
        p.name AS "event.reason",
        CASE p.severity 
            WHEN 0 THEN "major"
            WHEN 2 THEN "warning"
            WHEN 3 THEN "minor"
            WHEN 4 THEN "critical"
        END AS "event.severity",
        IF(p.r_clock = 0, 1, 0) AS "event.status",
        'Zabbix' AS "event.dataset",
        'alerts' AS "event.module"
    FROM problem AS p
      INNER JOIN triggers AS t ON p.objectid = t.triggerid
      INNER JOIN functions AS f ON f.triggerid = t.triggerid
      INNER JOIN items AS i ON i.itemid = f.itemid
      INNER JOIN hosts AS h ON h.hostid = i.hostid
      INNER JOIN interface AS it ON it.hostid = h.hostid;


-- CMDB
CREATE VIEW "alarms-cmdb" AS
    SELECT
        a.id AS "event.id",
        DATEADD(s, a.last_mod_dt, CAST('1970-01-01' AS datetime2(0))) AS "event.last_updated_time",
        b.resource_name AS "host.hostname",
        b.ip_address AS "host.ip",
        c.parenttochild AS "host.relationship.type",
        d.resource_name AS "host.dependent.hostname",
        d.ip_address AS "host.dependent.ip",
        a.del AS "event.status",
        'CMDB' AS "event.dataset"
    FROM busmgt AS a
        INNER JOIN ca_owned_resource AS b ON b.own_resource_uuid = a.hier_parent
        INNER JOIN ci_rel_type AS c ON c.id = a.ci_rel_type
        INNER JOIN ca_owned_resource AS d ON d.own_resource_uuid = a.hier_child
    WHERE
        b.inactive = 0 AND
        d.inactive = 0


-- SPECTRUM
CREATE VIEW `alarms-spectrum` AS
    SELECT
        a.alarm_key AS 'event.key',
        a.alarm_id AS 'event.id',
        a.set_time AS 'event.start',
        CASE
          WHEN a.clear_time IS NULL THEN 1
          ELSE 0
        END AS 'event.status',
        CASE 
            WHEN a.clear_time IS NULL THEN a.set_time
            ELSE a.clear_time
        END AS 'event.end',
        lower(b.condition_name) AS 'event.severity',
        c.title AS 'event.reason',
        d.model_name AS 'host.hostname',
        d.device_type AS 'host.type',
        d.ip AS 'host.ip',
        d.mac AS 'host.mac',
        d.serial_nbr AS 'host.serial_number',
        d.location AS 'host.location',
        e.mclass_name AS 'event.category',
        f.event_msg AS 'event.original',
        'spectrum' AS 'event.dataset',
    	'alerts' AS 'event.module'
    FROM alarminfo AS a
    INNER JOIN alarmcondition AS b ON a.condition_id = b.condition_id
    INNER JOIN alarmtitle AS c ON a.alarm_title_id = c.alarm_title_id
    INNER JOIN devicemodel AS d ON a.model_key = d.model_key
    INNER JOIN modelclass AS e ON d.model_class = e.model_class
    INNER JOIN event AS f ON f.event_key = a.orig_event_key
    UNION ALL
    SELECT
        a.alarm_key AS 'event.key',
        a.alarm_id AS 'event.id',
        a.set_time AS 'event.start',
        CASE
          WHEN a.clear_time IS NULL THEN 1
          ELSE 0
        END AS 'event.status',
        CASE 
            WHEN a.clear_time IS NULL THEN a.set_time
            ELSE a.clear_time
        END AS 'event.end',
        lower(b.condition_name)  AS 'event.severity',
        c.title AS 'event.reason',
        d.model_name AS 'host.hostname',
        g.device_type AS 'host.type',
        d.ip AS 'host.ip',
        d.mac AS 'host.mac',
        g.serial_nbr AS 'host.serial_number',
        g.location AS 'host.location',
        e.mclass_name AS 'event.category',
        f.event_msg AS 'event.original',
        'spectrum' AS 'event.dataset',
        'alerts' AS 'event.module'
    FROM alarminfo AS a
    INNER JOIN alarmcondition AS b ON a.condition_id = b.condition_id
    INNER JOIN alarmtitle AS c ON a.alarm_title_id = c.alarm_title_id
    INNER JOIN interfacemodel AS d ON a.model_key = d.model_key
    INNER JOIN modelclass AS e ON d.model_class = e.model_class
    INNER JOIN event AS f ON f.event_key = a.orig_event_key
    INNER JOIN devicemodel AS g ON g.model_key = d.device_model_key;


-- UIM
CREATE VIEW "alarms-uim" AS
    USE uimdb
    SELECT
        CAST(SUBSTRING(b.nimid, 3, 8) + SUBSTRING(b.nimid, 12, 16) AS BIGINT) AS 'event.id',
        b.nimid AS 'event.key',
        CONVERT(datetime2(0), b.nimts) AS 'event.start',
        CASE 
            WHEN b.closed IS NULL THEN CONVERT(datetime2(0), b.nimts)
            ELSE CONVERT(datetime2(0), b.closed)
        END AS 'event.end',
        b.severity AS 'event.severity',
        b.message AS 'event.reason',
        CASE
            WHEN d.dev_ip IS NOT NULL THEN d.dev_ip 
            ELSE '0.0.0.0'
        END AS 'host.ip',
        b.hostname AS 'host.hostname',
        'uim' AS 'event.dataset',
        'alerts' AS 'event.module',
        CASE 
            WHEN a.time_origin IS NULL THEN 0
            ELSE 1
        END AS 'event.status'
    FROM nas_alarms AS a
    FULL OUTER JOIN nas_transaction_summary AS b ON a.nimid = b.nimid
    LEFT JOIN cm_device AS d ON d.dev_id = b.dev_id
    LEFT JOIN cm_computer_system AS e ON e.cs_id = d.cs_id
    WHERE a.nimts IS NOT NULL OR b.nimts IS NOT NULL
    --ORDER BY 'event.status' DESC


-- ENTRADA (PIRAMIDE)
CREATE OR REPLACE VIEW "notas-entrada" AS    
    SELECT
        a.entrada,
        CASE
            WHEN a.versions_operation = 'D' THEN (a.versions_starttime - INTERVAL '1' SECOND)
            ELSE a.versions_starttime
        END AS stime,
        CASE
            WHEN a.versions_operation = 'I' THEN  'INSERT'
            WHEN a.versions_operation = 'U' THEN  'UPDATE'
            WHEN a.versions_operation = 'D' THEN  'DELETE'
        END AS operation,
        b.dsc_complemento,
        a.filial,
        a.empresa,
        a.serie,
        a.nf,
        a.fatura,
        TO_CHAR(a.dt_emissao, 'DD/MM/YYYY') AS dt_emissao,
        TO_CHAR(a.dt_entrada, 'DD/MM/YYYY') AS dt_entrada,
        a.val_frete,
        a.val_seguro,
        a.val_outras_desp,
        a.val_total_nota,
        a.desconto,
        TO_CHAR(a.dt_entrada_emp, 'DD/MM/YYYY') AS dt_entrada_emp,
        a.fornecedor,
        c.fantasia,
        c.nome,
        a.grupo_lanc,
        a.cod_tipo_documento,
        TO_CHAR(a.dat_aceite, 'DD/MM/YYYY') AS dat_aceite,
        a.val_seguro_servico,
        a.val_outras_desp_servico,
        a.val_desconto_servico,
        a.num_contrato,
        a.val_frete_t1,
        TRIM(a.cod_condpag) AS cod_condpag,
        a.cod_tipo_entrada,
        a.cod_comprador,
        TO_CHAR(a.dat_inclusao_registro, 'DD/MM/YYYY') AS dat_inclusao_registro,
        a.cod_tipo_documento_titulo,
        a.cod_portador_titulo,
        a.cod_agencia_titulo,
        a.cod_conta_corrente_titulo,
        TO_CHAR(a.dat_inicio_servico, 'DD/MM/YYYY') AS dat_inicio_servico,
        TO_CHAR(a.dat_fim_servico, 'DD/MM/YYYY') AS dat_fim_servico,
        TO_CHAR(a.dat_alteracao_registro, 'DD/MM/YYYY') AS dat_alteracao_registro
    FROM (entrada VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE) a
    LEFT JOIN PIRAMIDE.observacao_entrada b ON a.entrada = b.cod_entrada
    INNER JOIN PIRAMIDE.fornec c ON c.codigo = a.fornecedor
    INNER JOIN (SELECT MAX(d.versions_starttime) AS maxd FROM entrada VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE d WHERE d.versions_starttime IS NOT NULL GROUP BY d.entrada) e ON a.versions_starttime = e.maxd
    WHERE 
        a.entrada IN (SELECT f.entrada FROM entrada VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE f GROUP BY f.entrada HAVING COUNT(*) < 3) OR
        (a.entrada IN (SELECT f.entrada FROM entrada VERSIONS BETWEEN TIMESTAMP MINVALUE AND MAXVALUE f GROUP BY f.entrada HAVING COUNT(*) = 3) AND a.versions_operation != 'D')
    ORDER BY a.entrada DESC;
