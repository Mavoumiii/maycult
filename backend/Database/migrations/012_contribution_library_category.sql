ALTER TABLE contribution
  ADD COLUMN categorie_bibliotheque VARCHAR(100) NOT NULL DEFAULT 'Histoires'
  AFTER statut;
