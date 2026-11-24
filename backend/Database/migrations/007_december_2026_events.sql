INSERT INTO utilisateur (nom, prenom, email, mot_de_passe_hash)
VALUES ('Administration', 'MayCult', 'system@maycult.invalid', '!disabled!')
ON DUPLICATE KEY UPDATE id_utilisateur = LAST_INSERT_ID(id_utilisateur);

SET @system_user_id = (
  SELECT id_utilisateur FROM utilisateur WHERE email = 'system@maycult.invalid'
);

INSERT INTO categorie (nom, domaine, description)
VALUES
  ('festival', 'Événement', 'Festivals culturels.'),
  ('concert', 'Événement', 'Concerts et soirées musicales.')
ON DUPLICATE KEY UPDATE id_categorie = LAST_INSERT_ID(id_categorie);

INSERT INTO evenement
  (titre, description, date_debut, date_fin, lieu_texte, statut, id_categorie, id_utilisateur_proposant)
SELECT
  'Momojou en fête 2026',
  'Foire de la Ville de Mamoudzou du 1er au 6 décembre 2026, de 8h à 18h (clôture à 17h le dimanche). Place de la République. Marché des commerçants et artisans, produits locaux, animations pour les enfants et concerts gratuits le samedi 5 décembre de 15h à 18h. Programme officiel : https://www.mamoudzou.yt/evenements/momojou-en-fete-2026/',
  '2026-12-01 08:00:00', '2026-12-06 17:00:00', 'Place de la République, Mamoudzou', 'Validé',
  categorie.id_categorie, @system_user_id
FROM categorie
WHERE nom = 'festival' AND domaine = 'Événement'
  AND NOT EXISTS (
    SELECT 1 FROM evenement
    WHERE titre = 'Momojou en fête 2026' AND DATE(date_debut) = '2026-12-01'
  );

INSERT INTO evenement
  (titre, description, date_debut, date_fin, lieu_texte, statut, id_categorie, id_utilisateur_proposant)
SELECT
  'Soirée live – Congo Acoustic Band et DJ Ynzou',
  'Concert du Congo Acoustic Band à 20h, suivi du set de DJ Ynzou à partir de 23h jusqu’à 2h le dimanche 6 décembre. Entrée gratuite. La Table du Viking, Pamandzi. Source : https://mayotte-agenda.yt/evenement/soiree-live-a-la-table-du-viking-avec-congo-acoustic-band-et-dj-ynzou-2026-12-05',
  '2026-12-05 20:00:00', '2026-12-06 02:00:00', 'La Table du Viking, Pamandzi', 'Validé',
  categorie.id_categorie, @system_user_id
FROM categorie
WHERE nom = 'concert' AND domaine = 'Événement'
  AND NOT EXISTS (
    SELECT 1 FROM evenement
    WHERE titre = 'Soirée live – Congo Acoustic Band et DJ Ynzou' AND DATE(date_debut) = '2026-12-05'
  );
