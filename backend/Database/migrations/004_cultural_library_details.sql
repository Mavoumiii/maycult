ALTER TABLE paragraphe
  ADD COLUMN origines TEXT NULL,
  ADD COLUMN signification_culturelle TEXT NULL,
  ADD COLUMN lieu_decouverte TEXT NULL;

INSERT INTO categorie (nom, domaine, description)
VALUES ('Histoires', 'Histoires', 'Récits, mémoires et histoires de Mayotte.')
ON DUPLICATE KEY UPDATE description = VALUES(description);
