CREATE TABLE IF NOT EXISTS profil (
  id_profil BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_profil),
  UNIQUE KEY profil_nom_unique (nom)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS utilisateur (
  id_utilisateur BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom VARCHAR(100) NOT NULL,
  prenom VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  mot_de_passe_hash TEXT NOT NULL,
  role VARCHAR(50) NOT NULL,
  date_inscription TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_profil BIGINT UNSIGNED NULL,
  PRIMARY KEY (id_utilisateur),
  UNIQUE KEY utilisateur_email_unique (email),
  KEY utilisateur_profil_idx (id_profil),
  CONSTRAINT fk_utilisateur_profil
    FOREIGN KEY (id_profil) REFERENCES profil (id_profil)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contribution (
  id_contribution BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  statut VARCHAR(50) NOT NULL,
  motif_refus TEXT NULL,
  charte_acceptee BOOLEAN NOT NULL DEFAULT FALSE,
  date_soumission TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_moderation TIMESTAMP NULL,
  id_utilisateur BIGINT UNSIGNED NOT NULL,
  id_moderateur BIGINT UNSIGNED NULL,
  PRIMARY KEY (id_contribution),
  KEY contribution_auteur_idx (id_utilisateur),
  KEY contribution_moderateur_idx (id_moderateur),
  CONSTRAINT fk_contribution_auteur
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateur (id_utilisateur)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_contribution_moderateur
    FOREIGN KEY (id_moderateur) REFERENCES utilisateur (id_utilisateur)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categorie (
  id_categorie BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom VARCHAR(150) NOT NULL,
  description TEXT NULL,
  domaine VARCHAR(100) NOT NULL DEFAULT '',
  PRIMARY KEY (id_categorie),
  UNIQUE KEY categorie_nom_domaine_unique (nom, domaine)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contenu (
  id_contenu BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titre VARCHAR(255) NOT NULL,
  village VARCHAR(150) NULL,
  texte LONGTEXT NULL,
  date_publication TIMESTAMP NULL,
  date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_categorie BIGINT UNSIGNED NOT NULL,
  id_contribution BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_contenu),
  UNIQUE KEY contenu_contribution_unique (id_contribution),
  KEY contenu_categorie_idx (id_categorie),
  CONSTRAINT fk_contenu_categorie
    FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_contenu_contribution
    FOREIGN KEY (id_contribution) REFERENCES contribution (id_contribution)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS paragraphe (
  id_paragraphe BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titre VARCHAR(255) NULL,
  contenu LONGTEXT NULL,
  description TEXT NULL,
  image TEXT NULL,
  video TEXT NULL,
  id_contenu BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_paragraphe),
  KEY paragraphe_contenu_idx (id_contenu),
  CONSTRAINT fk_paragraphe_contenu
    FOREIGN KEY (id_contenu) REFERENCES contenu (id_contenu)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS question_quiz (
  id_quiz BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titre VARCHAR(255) NOT NULL,
  description TEXT NULL,
  id_contenu BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_quiz),
  KEY question_quiz_contenu_idx (id_contenu),
  CONSTRAINT fk_question_quiz_contenu
    FOREIGN KEY (id_contenu) REFERENCES contenu (id_contenu)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reponse (
  id_reponse BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  texte TEXT NOT NULL,
  est_correcte BOOLEAN NOT NULL DEFAULT FALSE,
  id_quiz BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (id_reponse),
  KEY reponse_quiz_idx (id_quiz),
  CONSTRAINT fk_reponse_question_quiz
    FOREIGN KEY (id_quiz) REFERENCES question_quiz (id_quiz)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS lieu (
  id_lieu BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nom VARCHAR(255) NOT NULL,
  description TEXT NULL,
  village VARCHAR(150) NULL,
  adresse TEXT NULL,
  conditions_acces TEXT NULL,
  latitude DECIMAL(9,6) NULL,
  longitude DECIMAL(9,6) NULL,
  PRIMARY KEY (id_lieu),
  CONSTRAINT chk_lieu_latitude CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CONSTRAINT chk_lieu_longitude CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS evenement (
  id_evenement BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  titre VARCHAR(255) NOT NULL,
  description TEXT NULL,
  date_debut TIMESTAMP NOT NULL,
  date_fin TIMESTAMP NULL,
  lieu_texte TEXT NULL,
  image_url TEXT NULL,
  statut VARCHAR(50) NOT NULL,
  motif_refus TEXT NULL,
  date_creation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  date_moderation TIMESTAMP NULL,
  id_lieu BIGINT UNSIGNED NULL,
  id_categorie BIGINT UNSIGNED NULL,
  id_utilisateur_proposant BIGINT UNSIGNED NOT NULL,
  id_utilisateur_moderateur BIGINT UNSIGNED NULL,
  PRIMARY KEY (id_evenement),
  KEY evenement_lieu_idx (id_lieu),
  KEY evenement_categorie_idx (id_categorie),
  KEY evenement_proposant_idx (id_utilisateur_proposant),
  KEY evenement_moderateur_idx (id_utilisateur_moderateur),
  KEY evenement_statut_date_idx (statut, date_debut),
  CONSTRAINT fk_evenement_lieu
    FOREIGN KEY (id_lieu) REFERENCES lieu (id_lieu)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_evenement_categorie
    FOREIGN KEY (id_categorie) REFERENCES categorie (id_categorie)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_evenement_proposant
    FOREIGN KEY (id_utilisateur_proposant) REFERENCES utilisateur (id_utilisateur)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_evenement_moderateur
    FOREIGN KEY (id_utilisateur_moderateur) REFERENCES utilisateur (id_utilisateur)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_evenement_dates CHECK (date_fin IS NULL OR date_fin >= date_debut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS cultural_contents, artists, places, quiz_questions, events, contributions, villages;
SET FOREIGN_KEY_CHECKS = 1;
