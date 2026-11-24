SET @traditions_category_id = (
  SELECT id_categorie FROM categorie WHERE domaine = 'Traditions' LIMIT 1
);
SET @mariage_content_id = (
  SELECT c.id_contenu
  FROM contenu c
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  WHERE cat.domaine = 'Traditions'
    AND LOWER(TRIM(c.titre)) = 'le mariage : préparatifs et moments de partage'
  LIMIT 1
);
SET @music_mbiwi_content_id = (
  SELECT c.id_contenu
  FROM contenu c
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  WHERE cat.domaine = 'Musique'
    AND LOWER(TRIM(c.titre)) = 'le mbiwi, danse traditionnelle de mayotte'
  LIMIT 1
);
SET @music_mbiwi_contribution_id = (
  SELECT id_contribution FROM contenu WHERE id_contenu = @music_mbiwi_content_id
);
SET @mbiwi_title = 'Le Mbiwi, danse traditionnelle de Mayotte';
SET @mbiwi_content = 'Le Mbiwi est une danse traditionnelle mahoraise portée par les chants et le rythme des bâtons de bambou frappés l’un contre l’autre. Les danseuses évoluent en cadence tandis que les voix et les percussions donnent vie à la musique. Pratiqué lors de rencontres et de célébrations, le Mbiwi rassemble les participantes et le public. La danse, les chants et les rythmes transmettent un patrimoine vivant et partagé entre générations.';
SET @mbiwi_description = 'Une danse traditionnelle mahoraise où les chants, les mouvements et les rythmes de bambou font vivre la musique et rassemblent.';
SET @mbiwi_origins = 'Le Mbiwi est une pratique musicale et dansée traditionnelle de Mayotte. Ses chants, ses rythmes et ses gestes se transmettent au fil des générations.';
SET @mbiwi_meaning = 'Le Mbiwi fait vivre la culture mahoraise. Par la danse et la musique, il crée un moment collectif de rencontre et de transmission.';

UPDATE contenu
SET titre = @mbiwi_title, texte = @mbiwi_content
WHERE id_contenu = @mariage_content_id;

UPDATE contenu
SET id_categorie = @traditions_category_id
WHERE id_contenu = @music_mbiwi_content_id
  AND @mariage_content_id IS NULL;

UPDATE paragraphe
SET titre = 'Danse traditionnelle',
    contenu = @mbiwi_description,
    description = @mbiwi_description,
    image = NULL,
    video = NULL,
    origines = @mbiwi_origins,
    signification_culturelle = @mbiwi_meaning
WHERE id_contenu = @mariage_content_id;

INSERT INTO paragraphe
  (titre, contenu, description, image, video, origines, signification_culturelle, id_contenu)
SELECT
  'Danse traditionnelle', @mbiwi_description, @mbiwi_description, NULL, NULL,
  @mbiwi_origins, @mbiwi_meaning, @mariage_content_id
WHERE @mariage_content_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM paragraphe WHERE id_contenu = @mariage_content_id
  );

DELETE FROM question_quiz
WHERE id_contenu = @music_mbiwi_content_id
  AND @mariage_content_id IS NOT NULL;
DELETE FROM paragraphe
WHERE id_contenu = @music_mbiwi_content_id
  AND @mariage_content_id IS NOT NULL;
DELETE FROM contenu
WHERE id_contenu = @music_mbiwi_content_id
  AND @mariage_content_id IS NOT NULL;
DELETE FROM contribution
WHERE id_contribution = @music_mbiwi_contribution_id
  AND @mariage_content_id IS NOT NULL;
