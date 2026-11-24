INSERT INTO utilisateur (nom, prenom, email, mot_de_passe_hash)
VALUES ('Administration', 'MayCult', 'system@maycult.invalid', '!disabled!')
ON DUPLICATE KEY UPDATE id_utilisateur = LAST_INSERT_ID(id_utilisateur);

INSERT INTO categorie (nom, domaine, description)
VALUES ('Musique', 'Musique', 'Musique et créations sonores.')
ON DUPLICATE KEY UPDATE id_categorie = LAST_INSERT_ID(id_categorie);

SET @system_user_id = (
  SELECT id_utilisateur FROM utilisateur WHERE email = 'system@maycult.invalid'
);
SET @music_category_id = (
  SELECT id_categorie FROM categorie WHERE domaine = 'Musique' LIMIT 1
);
SET @mbiwi_title = 'Le Mbiwi, danse traditionnelle de Mayotte';
SET @mbiwi_content = 'Le Mbiwi est une danse traditionnelle mahoraise portée par les chants et le rythme des bâtons de bambou frappés l’un contre l’autre. Les danseuses évoluent en cadence tandis que les voix et les percussions donnent vie à la musique. Pratiqué lors de rencontres et de célébrations, le Mbiwi rassemble les participantes et le public. La danse, les chants et les rythmes transmettent un patrimoine vivant et partagé entre générations.';
SET @mbiwi_description = 'Une danse traditionnelle mahoraise où les chants, les mouvements et les rythmes de bambou font vivre la musique et rassemblent.';

UPDATE contenu c
JOIN categorie cat ON cat.id_categorie = c.id_categorie
SET c.titre = @mbiwi_title, c.texte = @mbiwi_content
WHERE cat.domaine = 'Musique' AND LOWER(TRIM(c.titre)) = 'mariage';

UPDATE paragraphe p
JOIN contenu c ON c.id_contenu = p.id_contenu
JOIN categorie cat ON cat.id_categorie = c.id_categorie
SET p.titre = 'Danse traditionnelle',
    p.contenu = @mbiwi_description,
    p.description = @mbiwi_description,
    p.image = NULL,
    p.video = NULL,
    p.origines = 'Le Mbiwi est une pratique musicale et dansée traditionnelle de Mayotte. Ses chants, ses rythmes et ses gestes se transmettent au fil des générations.',
    p.signification_culturelle = 'Le Mbiwi fait vivre la culture mahoraise. Par la danse et la musique, il crée un moment collectif de rencontre et de transmission.'
WHERE cat.domaine = 'Musique' AND c.titre = @mbiwi_title;

INSERT INTO paragraphe
  (titre, contenu, description, image, video, origines, signification_culturelle, id_contenu)
SELECT
  'Danse traditionnelle', @mbiwi_description, @mbiwi_description, NULL, NULL,
  'Le Mbiwi est une pratique musicale et dansée traditionnelle de Mayotte. Ses chants, ses rythmes et ses gestes se transmettent au fil des générations.',
  'Le Mbiwi fait vivre la culture mahoraise. Par la danse et la musique, il crée un moment collectif de rencontre et de transmission.',
  c.id_contenu
FROM contenu c
JOIN categorie cat ON cat.id_categorie = c.id_categorie
LEFT JOIN paragraphe p ON p.id_contenu = c.id_contenu
WHERE cat.domaine = 'Musique' AND c.titre = @mbiwi_title AND p.id_paragraphe IS NULL;

SET @create_mbiwi = (
  SELECT COUNT(*) = 0
  FROM contenu c
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  WHERE cat.domaine = 'Musique' AND c.titre = @mbiwi_title
);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
SELECT 'Validé', TRUE, @system_user_id
WHERE @create_mbiwi = 1;
SET @mbiwi_contribution_id = LAST_INSERT_ID();

INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT @mbiwi_title, 'Mayotte', @mbiwi_content, CURRENT_TIMESTAMP, @music_category_id, @mbiwi_contribution_id
WHERE @create_mbiwi = 1;
SET @mbiwi_content_id = LAST_INSERT_ID();

INSERT INTO paragraphe
  (titre, contenu, description, image, video, origines, signification_culturelle, id_contenu)
SELECT
  'Danse traditionnelle', @mbiwi_description, @mbiwi_description, NULL, NULL,
  'Le Mbiwi est une pratique musicale et dansée traditionnelle de Mayotte. Ses chants, ses rythmes et ses gestes se transmettent au fil des générations.',
  'Le Mbiwi fait vivre la culture mahoraise. Par la danse et la musique, il crée un moment collectif de rencontre et de transmission.',
  @mbiwi_content_id
WHERE @create_mbiwi = 1;
