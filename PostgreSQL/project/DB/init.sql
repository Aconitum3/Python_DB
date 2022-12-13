CREATE TABLE mytable 
( 
    id int, 
    name char(20)
);

\COPY mytable FROM '/home/mytable.csv' DELIMITER ',' CSV HEADER;