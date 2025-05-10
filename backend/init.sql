-- MariaDB-Initialisierungsskript

-- Sicherstellen, dass die Datenbank existiert
CREATE DATABASE IF NOT EXISTS homeschool;
USE homeschool;

CREATE USER IF NOT EXISTS 'marco'@'%' IDENTIFIED BY 'Jonas051214';
GRANT ALL PRIVILEGES ON homeschool.* TO 'marco'@'%';
FLUSH PRIVILEGES;

-- Tabelle für Ergebnisse erstellen, falls sie nicht existiert
CREATE TABLE IF NOT EXISTS results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    topic VARCHAR(255) NOT NULL,
    questions TEXT,
    user_answers TEXT,
    feedback TEXT,
    timestamp VARCHAR(30) NOT NULL,
    INDEX (user_id),
    INDEX (subject)
);

-- Testdaten einfügen (optional)
INSERT INTO results (user_id, subject, topic, questions, user_answers, feedback, timestamp)
VALUES 
('test-user', 'Mathematik', 'Addition', '["Was ist 1+1?", "Was ist 2+2?"]', '["2", "4"]', '["richtig", "richtig"]', '2023-06-01T12:00:00'),
('test-user', 'Deutsch', 'Grammatik', '["Was ist ein Substantiv?", "Was ist ein Verb?"]', '["Ein Hauptwort", "Ein Tätigkeitswort"]', '["richtig", "richtig"]', '2023-06-01T13:00:00');

-- Bestätigung
SELECT 'MariaDB-Initialisierung abgeschlossen' AS message;
