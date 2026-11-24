SET @traditions_category_id = (
  SELECT id_categorie FROM categorie WHERE domaine = 'Traditions' LIMIT 1
);
SET @mgodro_content_id = (
  SELECT c.id_contenu
  FROM contenu c
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  WHERE cat.domaine = 'Musique' AND LOWER(c.titre) LIKE '%godro%'
  LIMIT 1
);
SET @mgodro_contribution_id = (
  SELECT id_contribution FROM contenu WHERE id_contenu = @mgodro_content_id
);
SET @chants_content_id = (
  SELECT c.id_contenu
  FROM contenu c
  JOIN categorie cat ON cat.id_categorie = c.id_categorie
  WHERE cat.domaine = 'Musique'
    AND LOWER(TRIM(c.titre)) = 'les chants traditionnels et la parole chantée'
  LIMIT 1
);
SET @chakacha_title = 'Le Chakacha, danse traditionnelle mahoraise';
SET @chakacha_content = 'Le Chakacha est une danse festive portée par les rythmes et les mouvements. Les danseuses suivent le tempo dans une énergie collective qui invite au partage. Les pas, les gestes et les formes de la danse peuvent varier selon les groupes et les occasions. La musique et la danse font du Chakacha une expression vivante de la culture mahoraise.';
SET @chakacha_description = 'Une danse mahoraise où le rythme et les mouvements créent un moment de partage.';

DELETE FROM question_quiz WHERE id_contenu = @mgodro_content_id;
DELETE FROM paragraphe WHERE id_contenu = @mgodro_content_id;
DELETE FROM contenu WHERE id_contenu = @mgodro_content_id;
DELETE FROM contribution WHERE id_contribution = @mgodro_contribution_id;

UPDATE contenu
SET titre = @chakacha_title, texte = @chakacha_content, id_categorie = @traditions_category_id
WHERE id_contenu = @chants_content_id;

UPDATE paragraphe
SET titre = 'Danse traditionnelle',
    contenu = @chakacha_description,
    description = @chakacha_description,
    image = NULL,
    video = NULL,
    origines = 'Le Chakacha est une pratique dansée mahoraise transmise par les gestes, les rythmes et la participation.',
    signification_culturelle = 'La danse rassemble les participantes et le public autour de la musique et d’un moment collectif.'
WHERE id_contenu = @chants_content_id;

INSERT INTO paragraphe
  (titre, contenu, description, image, video, origines, signification_culturelle, id_contenu)
SELECT
  'Danse traditionnelle', @chakacha_description, @chakacha_description, NULL, NULL,
  'Le Chakacha est une pratique dansée mahoraise transmise par les gestes, les rythmes et la participation.',
  'La danse rassemble les participantes et le public autour de la musique et d’un moment collectif.',
  @chants_content_id
WHERE @chants_content_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM paragraphe WHERE id_contenu = @chants_content_id
  );

UPDATE contenu c
JOIN categorie cat ON cat.id_categorie = c.id_categorie
SET c.id_categorie = @traditions_category_id
WHERE cat.domaine = 'Musique';

DELETE FROM categorie
WHERE domaine = 'Musique'
  AND NOT EXISTS (
    SELECT 1 FROM contenu WHERE id_categorie = categorie.id_categorie
  )
  AND NOT EXISTS (
    SELECT 1 FROM evenement WHERE id_categorie = categorie.id_categorie
  );
