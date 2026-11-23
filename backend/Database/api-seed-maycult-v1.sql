INSERT INTO utilisateur (nom, prenom, email, mot_de_passe_hash)
VALUES ('Administration', 'MayCult', 'system@maycult.invalid', '!disabled!')
ON DUPLICATE KEY UPDATE id_utilisateur = LAST_INSERT_ID(id_utilisateur);

SET @system_user_id = (
  SELECT id_utilisateur FROM utilisateur WHERE email = 'system@maycult.invalid'
);

INSERT INTO categorie (nom, domaine, description)
VALUES
  ('Traditions', 'Traditions', 'Traditions et pratiques culturelles.'),
  ('Savoir-faire', 'Savoir-faire', 'Gestes et savoir-faire transmis.'),
  ('Musique', 'Musique', 'Musique et créations sonores.'),
  ('Quiz', 'Question', 'Questions du quiz culturel.'),
  ('festival', 'Événement', 'Festivals culturels.'),
  ('ceremonie', 'Événement', 'Cérémonies et rencontres culturelles.'),
  ('tradition', 'Événement', 'Événements autour des traditions.')
ON DUPLICATE KEY UPDATE id_categorie = LAST_INSERT_ID(id_categorie);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @article_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT 'Le deba, une danse pleine de grâce', 'Pamandzi',
  'Le deba rassemble les générations autour du chant, du rythme et de la transmission.',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE nom = 'Traditions' AND domaine = 'Traditions';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe (titre, contenu, description, id_contenu)
VALUES (
  'Vidéo & récit',
  'Une pratique collective où les voix et les gestes racontent la mémoire des femmes de Mayotte.',
  'Une pratique collective où les voix et les gestes racontent la mémoire des femmes de Mayotte.',
  @article_content_id
);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @article_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT 'L’art du tressage en feuilles de cocotier', 'Mtsamboro',
  'Le tressage est un savoir-faire qui demande observation, patience et précision.',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE nom = 'Savoir-faire' AND domaine = 'Savoir-faire';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe (titre, contenu, description, id_contenu)
VALUES (
  'Photo & témoignage',
  'Des gestes précis et patients pour transformer les fibres locales en objets du quotidien.',
  'Des gestes précis et patients pour transformer les fibres locales en objets du quotidien.',
  @article_content_id
);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @article_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT 'Les rythmes du m’godro', 'Mamoudzou',
  'Le m’godro accompagne les fêtes et les moments de partage.',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE nom = 'Musique' AND domaine = 'Musique';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe (titre, contenu, description, id_contenu)
VALUES (
  'Audio & portrait',
  'Rencontre avec une nouvelle génération de musiciens qui fait dialoguer héritage et création.',
  'Rencontre avec une nouvelle génération de musiciens qui fait dialoguer héritage et création.',
  @article_content_id
);

INSERT INTO lieu (nom, description, village, conditions_acces)
VALUES
  ('Musée de Mayotte', 'Un lieu consacré au patrimoine de Mayotte.', 'Dzaoudzi', 'Ouvert'),
  ('Maison de l’artisanat', 'Un espace de découverte des savoir-faire locaux.', 'Mamoudzou', 'Ouvert'),
  ('Médiathèque de Bandraboua', 'Un lieu de lecture et de transmission.', 'Bandraboua', 'Sur réservation'),
  ('Place de la mairie', 'Un espace public pour les rencontres et événements.', 'Koungou', 'Libre accès');

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quelle pratique est associée au chant et à la danse collective ?',
  'Quelle pratique est associée au chant et à la danse collective ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quelle pratique est associée au chant et à la danse collective ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le deba', TRUE, @quiz_id), ('Le tressage', FALSE, @quiz_id), ('Le pilou', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel matériau est souvent utilisé dans le tressage traditionnel ?',
  'Quel matériau est souvent utilisé dans le tressage traditionnel ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel matériau est souvent utilisé dans le tressage traditionnel ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('La feuille de cocotier', TRUE, @quiz_id), ('Le cuivre', FALSE, @quiz_id), ('Le verre', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Que permet principalement la transmission orale ?',
  'Que permet principalement la transmission orale ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Que permet principalement la transmission orale ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Faire vivre la mémoire', TRUE, @quiz_id), ('Remplacer les événements', FALSE, @quiz_id), ('Créer une météo', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel est le nom de la pâte cosmétique traditionnelle utilisée à Mayotte ?',
  'Quel est le nom de la pâte cosmétique traditionnelle utilisée à Mayotte ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel est le nom de la pâte cosmétique traditionnelle utilisée à Mayotte ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le msindzano', TRUE, @quiz_id), ('Le henné', FALSE, @quiz_id), ('Le karité', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quelle langue locale est parlée à Mayotte ?',
  'Quelle langue locale est parlée à Mayotte ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quelle langue locale est parlée à Mayotte ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le shimaore', TRUE, @quiz_id), ('Le shibushi', FALSE, @quiz_id), ('Le malgache classique', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel type d’événement rassemble traditionnellement plusieurs villages à Mayotte ?',
  'Quel type d’événement rassemble traditionnellement plusieurs villages à Mayotte ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel type d’événement rassemble traditionnellement plusieurs villages à Mayotte ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le carnaval', FALSE, @quiz_id), ('Le mariage traditionnel (manzaraka)', TRUE, @quiz_id), ('La foire agricole', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel instrument accompagne souvent le deba ?',
  'Quel instrument accompagne souvent le deba ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel instrument accompagne souvent le deba ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le piano', FALSE, @quiz_id), ('La guitare électrique', FALSE, @quiz_id), ('Le tambourin', TRUE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel savoir-faire artisanal est traditionnellement transmis de mère en fille à Mayotte ?',
  'Quel savoir-faire artisanal est traditionnellement transmis de mère en fille à Mayotte ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel savoir-faire artisanal est traditionnellement transmis de mère en fille à Mayotte ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('La forge', FALSE, @quiz_id), ('Le tressage de nattes', TRUE, @quiz_id), ('La poterie tournée', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'À quoi sert principalement le msindzano ?',
  'À quoi sert principalement le msindzano ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('À quoi sert principalement le msindzano ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Teindre les vêtements', FALSE, @quiz_id), ('Conserver les aliments', FALSE, @quiz_id), ('Protéger et embellir la peau', TRUE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel plat est emblématique de la cuisine mahoraise ?',
  'Quel plat est emblématique de la cuisine mahoraise ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel plat est emblématique de la cuisine mahoraise ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le riz au coco', TRUE, @quiz_id), ('La choucroute', FALSE, @quiz_id), ('La paella', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel fruit tropical est particulièrement cultivé et consommé à Mayotte ?',
  'Quel fruit tropical est particulièrement cultivé et consommé à Mayotte ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel fruit tropical est particulièrement cultivé et consommé à Mayotte ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('La banane', TRUE, @quiz_id), ('L’ylang-ylang', FALSE, @quiz_id), ('La cannelle', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Comment appelle-t-on le tissu traditionnel porté par les femmes mahoraises ?',
  'Comment appelle-t-on le tissu traditionnel porté par les femmes mahoraises ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Comment appelle-t-on le tissu traditionnel porté par les femmes mahoraises ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le kimono', FALSE, @quiz_id), ('Le salouva', TRUE, @quiz_id), ('Le boubou', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quelle fleur est cultivée à Mayotte pour la parfumerie ?',
  'Quelle fleur est cultivée à Mayotte pour la parfumerie ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quelle fleur est cultivée à Mayotte pour la parfumerie ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('La rose', FALSE, @quiz_id), ('L’ylang-ylang', TRUE, @quiz_id), ('Le jasmin', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel rôle jouent les bibi dans la transmission culturelle ?',
  'Quel rôle jouent les bibi dans la transmission culturelle ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel rôle jouent les bibi dans la transmission culturelle ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Aucun rôle particulier', FALSE, @quiz_id), ('Elles transmettent contes et savoirs traditionnels', TRUE, @quiz_id), ('Elles gèrent uniquement l’agriculture', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quelle danse traditionnelle est souvent pratiquée lors des fêtes à Mayotte ?',
  'Quelle danse traditionnelle est souvent pratiquée lors des fêtes à Mayotte ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quelle danse traditionnelle est souvent pratiquée lors des fêtes à Mayotte ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le mgodro', TRUE, @quiz_id), ('La salsa', FALSE, @quiz_id), ('Le tango', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quel matériau est traditionnellement utilisé pour construire les cases mahoraises ?',
  'Quel matériau est traditionnellement utilisé pour construire les cases mahoraises ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quel matériau est traditionnellement utilisé pour construire les cases mahoraises ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('Le béton', FALSE, @quiz_id), ('La terre et les feuilles de cocotier', TRUE, @quiz_id), ('Le métal', FALSE, @quiz_id);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @quiz_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, texte, date_publication, id_categorie, id_contribution)
SELECT 'Quelle cérémonie marque traditionnellement le passage à l’âge adulte pour les garçons ?',
  'Quelle cérémonie marque traditionnellement le passage à l’âge adulte pour les garçons ?',
  CURRENT_TIMESTAMP, id_categorie, @quiz_contribution_id
FROM categorie WHERE nom = 'Quiz' AND domaine = 'Question';
SET @quiz_content_id = LAST_INSERT_ID();
INSERT INTO question_quiz (titre, id_contenu)
VALUES ('Quelle cérémonie marque traditionnellement le passage à l’âge adulte pour les garçons ?', @quiz_content_id);
SET @quiz_id = LAST_INSERT_ID();
INSERT INTO reponse (texte, est_correcte, id_quiz)
VALUES ('La circoncision', TRUE, @quiz_id), ('Le baptême', FALSE, @quiz_id), ('Le mariage', FALSE, @quiz_id);

INSERT INTO evenement
  (titre, description, date_debut, date_fin, lieu_texte, statut, id_categorie, id_utilisateur_proposant)
SELECT
  'Festival des arts de Mayotte',
  'Une scène ouverte aux artistes, danseurs et conteurs de l’île.',
  '2026-09-24 00:00:00', '2026-09-24 23:59:59', 'Dzaoudzi', 'Validé',
  categorie.id_categorie, @system_user_id
FROM categorie WHERE nom = 'festival' AND domaine = 'Événement';

INSERT INTO evenement
  (titre, description, date_debut, date_fin, lieu_texte, statut, id_categorie, id_utilisateur_proposant)
SELECT
  'Célébration du mariage traditionnel',
  'Une journée pour découvrir les rites, les chants et les parures du mariage mahorais.',
  '2026-10-15 00:00:00', '2026-10-15 23:59:59', 'Koungou', 'Validé',
  categorie.id_categorie, @system_user_id
FROM categorie WHERE nom = 'ceremonie' AND domaine = 'Événement';

INSERT INTO evenement
  (titre, description, date_debut, date_fin, lieu_texte, statut, id_categorie, id_utilisateur_proposant)
SELECT
  'Soirée traditionnelle',
  'Une soirée de chants et de rythmes traditionnels au cœur de la capitale.',
  '2026-11-05 00:00:00', '2026-11-05 23:59:59', 'Mamoudzou', 'Validé',
  categorie.id_categorie, @system_user_id
FROM categorie WHERE nom = 'tradition' AND domaine = 'Événement';
