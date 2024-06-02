INSERT INTO CURSO_MINISTRADO(DATA_CURSO, CODIGO_SALA, CODIGO_CURSO, CODIGO_INSTRUTOR)
	VALUES('2014-02-12', 200, 100, 100), 
	      ('2014-06-15', 201, 101, 101), 
	      ('2015-02-10', 202, 102, 102),
	      ('2015-06-13', 203, 103, 103),
	      ('2016-02-12', 204, 104, 104),
	      ('2016-06-18', 204, 104, 104);
		  

ALTER SEQUENCE zauser_za_coduser_seq RESTART WITH 1;
UPDATE zuser SET zu_coduser = nextval('zauser_za_coduser_seq');


CREATE TABLE fornecedor (
    codigo BIGSERIAL,
    n_nota VARCHAR(50) NOT NULL,
    r_social VARCHAR(50) NOT NULL,
    c_fornec VARCHAR(120) NOT NULL,
    PRIMARY KEY(codigo)
);