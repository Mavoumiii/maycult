CREATE TABLE IF NOT EXISTS administrateur (
  id_administrateur BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  mot_de_passe_hash TEXT NOT NULL,
  date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_administrateur),
  UNIQUE KEY administrateur_email_unique (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO administrateur (nom, prenom, email, mot_de_passe_hash)
SELECT nom, prenom, email, mot_de_passe_hash
FROM utilisateur
WHERE role = 'admin'
  AND email <> 'system@maycult.invalid'
  AND mot_de_passe_hash <> '!disabled!'
ON DUPLICATE KEY UPDATE email = VALUES(email);

UPDATE utilisateur
SET email = CONCAT('admin-legacy-', id_utilisateur, '@maycult.invalid'),
    mot_de_passe_hash = '!disabled!'
WHERE role = 'admin'
  AND email <> 'system@maycult.invalid'
  AND mot_de_passe_hash <> '!disabled!';

ALTER TABLE utilisateur DROP COLUMN role;
