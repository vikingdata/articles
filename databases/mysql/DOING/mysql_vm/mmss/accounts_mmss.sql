

CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';


CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitor';
GRANT select ON *.* TO 'monitor'@'%';


flush PRIVILEGES;
