LOAD DATA INFILE 'FL_insurance_sample.csv'
INTO TABLE insured
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
SELECT * FROM insured
LIMIT 10
SELECT AVG(tiv_2012) - AVG(tiv_2011);
SELECT construction, COUNT(*) as frequency
FROM insured
GROUP BY construction;
