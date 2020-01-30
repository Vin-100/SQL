CREATE DATABASE dataia_Nancy;
-- commentaire 123

DROP TABLE dataia_Nancy.dataia_Nancy;

CREATE TABLE dataia_Nancy.dataia_Nancy
(
resilies INT,
parcours INT,
anciennete INT,
demenagement INT,
sinistre INT,
devis INT,
desequip INT,
revision INT,
satisfaction INT
);

SHOW VARIABLES LIKE "secure_file_priv";
+------------------+------------------------------------------------+
| Variable_name    | Value                                          |
+------------------+------------------------------------------------+
| secure_file_priv | C:\ProgramData\MySQL\MySQL Server 5.6\Uploads\ |
+------------------+------------------------------------------------+


USE dataia_Nancy;

LOAD DATA LOCAL INFILE 'C:/base1.txt' INTO TABLE dataia_Nancy
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n';

# afficher les 10 premières lignes
select * from dataia_Nancy limit 10;

# Nombre de lignes dans la table
SELECT COUNT(*) FROM dataia_Nancy;

# Changer le texte 0/1 pour non résilié / résilié
# Creation d une colonne de texte...

ALTER TABLE dataia_Nancy ADD tresilies VARCHAR(15);

UPDATE dataia_Nancy
SET tresilies = 'Résilié'
WHERE resilies = '1';
# Query OK, 48577 rows affected (0.86 sec)
UPDATE dataia_Nancy
SET tresilies = 'Non résilié'
WHERE resilies = '0';
# Query OK, 999998 rows affected (28.09 sec)

ALTER TABLE dataia_Nancy ADD tester INT;
update dataia_Nancy set tester = resilies;
ALTER TABLE dataia_Nancy MODIFY tester VARCHAR(15);

UPDATE dataia_Nancy SET tester = 'Résilié' WHERE tester = '1';
UPDATE dataia_Nancy SET tester = 'Non résilié' WHERE tester = '0';

UPDATE dataia_Nancy SET tresilies = (case resilies when 1 then 'Résilié' else 'Non résilié' end );
UPDATE dataia_Nancy SET tester    = (case when resilies=1 then 'Résilié' else 'Non résilié'	end );

# Affichage de la moyenne de l ancienneté sans décimale
select round(avg(anciennete),0) from dataia_Nancy;

# Nb d individus en fonction de l anciennete et du sinistre
select anciennete, sinistre, count(*) from dataia_Nancy group by anciennete, sinistre;
+------------+----------+----------+
| anciennete | sinistre | count(*) |
+------------+----------+----------+
|          1 |        1 |    54221 |
|          1 |        2 |    29924 |
|          2 |        1 |    29630 |
|          2 |        2 |    54772 |
|          3 |        1 |    80471 |
|          3 |        2 |    46388 |
|          4 |        1 |   195280 |
|          4 |        2 |   557889 |
+------------+----------+----------+

# Ajout du %
SELECT anciennete, sinistre, count(*),
	ROUND(count(*) / (SELECT count(*) FROM dataia_nancy) * 100) 
	AS pourcentage 
	FROM dataia_nancy 
	GROUP BY anciennete, sinistre
	ORDER BY pourcentage DESC;
# Sous requete dans une fonction select, exprimée entre parenthese, multipliée par 100 pour avoir un %age
SELECT anciennete,sinistre, count(*) / (SELECT count(*) from dataia_Nancy)*100 AS Ratio
FROM dataia_Nancy
GROUP BY anciennete,sinistre ;

###  VERIFIER POURQUOI CES SCRIPTS NE FOONCTIONNENT PAS....
SELECT t1.anciennete, t1.sinistre, count(*) AS `count`, count(*) / t2.total AS percent
  FROM dataia_Nancy AS t1
  JOIN (
    SELECT anciennete, sinistre, count(*) AS total 
      FROM dataia_Nancy
      GROUP BY anciennete, sinistre
  ) AS t2
  ON t1.anciennete = t2.anciennete and t1.sinistre=t2.sinistre
  GROUP BY anciennete, sinistre;

SELECT t1.sex, employed, count(*) AS `count`, count(*) / t2.total AS percent
  FROM my_table AS t1
  JOIN (
    SELECT sex, count(*) AS total 
      FROM my_table
      GROUP BY sex
  ) AS t2
  ON t1.sex = t2.sex
  GROUP BY t1.sex, employed;

select sex, employed, COUNT(*) / CAST( SUM(count(*)) over (partition by sex) as float)
  from my_table
 group by sex, employed
 
select sex, COUNT(*) / CAST( SUM(count(*)) over () as float)
  from my_table
 group by sex

SELECT a.Course, a.Grade,
	COUNT(a.Grade) as 'TotalGrades',
	pt= convert(varchar(50),convert(int, COUNT(a.Grade)*100/w.cCount)) + '%'
FROM Grades a
inner join
(
	select cCount=count(course), course from Grades group by course
) w on w.Course=a.course
GROUP BY a.Course, a.Grade, w.cCount
order by a.Course, a.Grade

SELECT i.Course, i.Grade, CONVERT(decimal(5, 2), COUNT(i.Grade)) / CONVERT(decimal(5, 2), (SELECT COUNT([Grade]) AS 'TotalGrades' FROM Grades WHERE (Course = i.Course))) * 100 AS 'Percentage'
FROM Grades i
GROUP BY i.Course, i.Grade



-- Parmi les non résiliés, cb ont un nb de sinitres > à la moyenne
SELECT count(*),(select avg(sinistre) from dataia_Nancy where resilies=0) AS Moyenne from dataia_Nancy
where sinistre > (select avg(sinistre) from dataia_Nancy where resilies=0) and resilies=0;

-- table projetA : resilies, parcours, anciennete, demenagement
-- table projetB : resilies, parcours, sinitres, devis, revision, satisfaction
CREATE TABLE projetA
  AS (SELECT @rownum := @rownum + 1 AS rank, resilies, parcours, anciennete, demenagement FROM dataia_Nancy,(SELECT @rownum := 0) r);
CREATE TABLE projetB
  AS (SELECT @rownum := @rownum + 1 AS rank, resilies, parcours, sinistre, devis, revision, satisfaction FROM dataia_Nancy,(SELECT @rownum := 0) r);


-- créer la table projetC à partir des tables projetA et projetB en utilisant
-- dans un premier temps un « join » et
-- dans un deuxieme temps « with »
DROP TABLE projetA;
DROP TABLE projetB;
DROP TABLE projetC;
CREATE TABLE projetA
  AS (SELECT @rownum := @rownum + 1 AS rank, resilies, parcours, anciennete, demenagement FROM dataia_Nancy,(SELECT @rownum := 0) r);
CREATE UNIQUE INDEX index_rank ON projeta (rank);
CREATE TABLE projetB
  AS (SELECT @rownum := @rownum + 1 AS rank, resilies, parcours, sinistre, devis, revision, satisfaction FROM dataia_Nancy,(SELECT @rownum := 0) r);
CREATE UNIQUE INDEX index_rank ON projetb (rank);
CREATE TABLE projetC AS
	(SELECT *
	FROM projetA natural join projetB);
-- En choisissant ce que l'on veut...
CREATE TABLE projetC AS
	(SELECT ta.rank, ta.resilies, ta.parcours, anciennete, demenagement, sinistre, devis, revision, satisfaction FROM projetA ta, projetB tb where ta.rank=tb.rank);





