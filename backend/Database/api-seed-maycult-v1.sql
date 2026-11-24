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
  ('Quiz', 'Question', 'Questions du quiz culturel.'),
  ('festival', 'Événement', 'Festivals culturels.'),
  ('ceremonie', 'Événement', 'Cérémonies et rencontres culturelles.'),
  ('tradition', 'Événement', 'Événements autour des traditions.'),
  ('concert', 'Événement', 'Concerts et soirées musicales.')
ON DUPLICATE KEY UPDATE id_categorie = LAST_INSERT_ID(id_categorie);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @article_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT 'Andriantsoly, le dernier sultan de Mayotte', 'Mamoudzou',
  'Andriantsoly, né Tsi Levalou, appartient à la famille royale sakalava d’Iboina, dans le nord-ouest de Madagascar. Après des conflits politiques dans la Grande Île, il se réfugie à Nosy Be puis à Mayotte en 1831. Il y entre au service du sultan, épouse une parente de celui-ci et reçoit d’abord une partie de l’île. En 1832, il devient sultan de Mayotte. Son règne se déroule dans un contexte de rivalités avec les souverains de Mohéli et d’Anjouan, ainsi qu’avec la monarchie merina de Madagascar. Sans allié sûr, il cherche l’appui français. Le 25 avril 1841, il cède à la France la souveraineté sur Mayotte par un traité conclu avec le capitaine Pierre Passot. L’accord prévoit notamment une rente personnelle. Il est ratifié par le gouvernement français en 1843. Il s’agit d’une décision du sultan dans un rapport de forces régional, et non d’un vote de la population mahoraise. Andriantsoly meurt en 1847. Son tombeau se trouve au sommet de la pointe Mahabou, à Mamoudzou. Pour approfondir : https://fr.wikipedia.org/wiki/Andriantsoly. Portrait : Édouard Charton (dir.), Le Magasin pittoresque, 1855, reproduction du domaine public sur Wikimedia Commons : https://commons.wikimedia.org/wiki/File:Andriantsoly.jpg',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE domaine = 'Histoires';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe
  (titre, contenu, description, image, origines, signification_culturelle, lieu_decouverte, id_contenu)
VALUES (
  'Personnage historique',
  'L’histoire d’Andriantsoly éclaire une période de rivalités politiques et de transformations dans l’archipel des Comores.',
  'Du prince sakalava devenu sultan de Mayotte à la cession de 1841 : un récit à replacer dans son contexte politique.',
  'https://upload.wikimedia.org/wikipedia/commons/f/f8/Andriantsoly.jpg',
  'Tsi Levalou est présenté par les sources historiques comme un héritier de la dynastie sakalava d’Iboina. Les récits situent sa conversion à l’islam vers 1820. Après sa défaite dans les conflits de Madagascar, il quitte la Grande Île et arrive à Mayotte en 1831. Son mariage avec une parente du sultan et son rôle dans les opérations militaires locales précèdent son accession au pouvoir en 1832.',
  'Andriantsoly occupe une place importante dans la mémoire politique de Mayotte. Son parcours montre comment les rivalités entre royaumes de l’archipel et de Madagascar ont pesé sur l’avenir de l’île. Le traité de 1841 est parfois résumé comme un choix de protection, mais il s’inscrit dans une situation de pressions et d’alliances complexes. Le rappeler permet de distinguer l’acte du sultan de l’expression collective d’une population. La pointe Mahabou conserve le souvenir de cette période.',
  'Pointe Mahabou, Mamoudzou.',
  @article_content_id
);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @article_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT 'Dembeni, un carrefour de l’océan Indien médiéval', 'Dembeni',
  'Sur la côte est de Mayotte, près de l’actuel village de Tsararano, le site ancien de Dembeni est l’un des principaux ensembles archéologiques médiévaux de l’île. Son occupation et sa prospérité se situent principalement entre le IXe et le XIIe siècle. Les vestiges indiquent une concentration importante d’habitants et des activités artisanales, notamment la métallurgie et le travail du fer. Les objets retrouvés témoignent de circulations entre Mayotte, Madagascar, la côte swahilie et des régions plus lointaines de l’océan Indien. Les recherches ont notamment proposé que le cristal de roche extrait à Madagascar ait été préparé à Dembeni avant d’être redistribué. Les céramiques et objets importés confirment l’existence de réseaux d’échanges, sans permettre de connaître précisément l’origine de chaque personne qui vivait sur le site. Dembeni décline à partir du XIIe siècle. La modification des routes commerciales est une explication envisagée, mais les causes ne sont pas entièrement établies. Les recherches n’ont pas livré toutes les réponses et le site a subi les effets de l’urbanisation. Pour approfondir : https://fr.wikipedia.org/wiki/Histoire_de_Mayotte. Photo : Pauly, Wikimedia Commons, CC BY-SA 3.0 : https://commons.wikimedia.org/wiki/File:Dembeni.jpg — Licence : https://creativecommons.org/licenses/by-sa/3.0/',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE domaine = 'Histoires';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe
  (titre, contenu, description, image, origines, signification_culturelle, lieu_decouverte, id_contenu)
VALUES (
  'Site archéologique',
  'Dembeni témoigne d’activités artisanales et d’échanges maritimes anciens, bien avant l’époque contemporaine.',
  'Un site médiéval majeur qui relie l’histoire de Mayotte aux circulations de l’océan Indien.',
  'https://upload.wikimedia.org/wikipedia/commons/0/0b/Dembeni.jpg',
  'Dembeni est connu par les fouilles archéologiques et les objets mis au jour. Les traces de métallurgie, les céramiques et les matières provenant de Madagascar documentent un établissement actif entre le IXe et le XIIe siècle. L’interprétation du rôle du site dans le commerce du cristal de roche a évolué avec les recherches. L’identité de ses habitants et les raisons exactes de son abandon restent en partie inconnues.',
  'Dembeni rend visible une histoire de Mayotte tournée vers la mer et reliée à de vastes échanges, plutôt qu’isolée de ses voisins. Le site constitue une mémoire matérielle : les objets archéologiques éclairent les activités et les contacts, tout en rappelant que le passé n’est jamais entièrement reconstitué. Sa préservation est essentielle pour permettre de nouvelles recherches et transmettre ce patrimoine aux générations futures.',
  'Site ancien de Dembeni, près de Tsararano, commune de Dembeni.',
  @article_content_id
);

INSERT INTO contribution (statut, charte_acceptee, id_utilisateur)
VALUES ('Validé', TRUE, @system_user_id);
SET @article_contribution_id = LAST_INSERT_ID();
INSERT INTO contenu (titre, village, texte, date_publication, id_categorie, id_contribution)
SELECT 'Les premiers peuplements : Mayotte, carrefour des mondes', 'Koungou',
  'Les traces archéologiques actuellement connues montrent que Mayotte est habitée depuis au moins le VIIIe siècle. À Koungou, des charbons datés par le carbone 14 témoignent d’une présence humaine à cette époque. Des vestiges retrouvés à Acoua et dans d’autres sites complètent progressivement ce tableau. À partir du IXe siècle, le site de Dembeni révèle une société insérée dans des échanges maritimes importants. L’histoire du peuplement ne se résume pas à une arrivée unique. Les données archéologiques, linguistiques et historiques évoquent des contacts entre la côte est-africaine, Madagascar et des populations venues de plus loin dans l’océan Indien. Les chercheurs discutent notamment d’apports bantous et austronésiens, parfois désignés comme protomalgaches. Les dates, les itinéraires et la composition exacte de ces migrations restent étudiés. Il faut distinguer les traces matérielles établies des hypothèses sur les origines. Les échanges ont continué à façonner l’île au fil des siècles. Les relations maritimes ont facilité la circulation des personnes, des objets, des langues et des pratiques. Les contacts avec des marchands musulmans ont également contribué à la diffusion progressive de l’islam dans l’archipel. Pour approfondir : https://fr.wikipedia.org/wiki/Histoire_de_Mayotte. Photo : Pauly, Wikimedia Commons, CC BY-SA 3.0 : https://commons.wikimedia.org/wiki/File:Koungou.jpg — Licence : https://creativecommons.org/licenses/by-sa/3.0/',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE domaine = 'Histoires';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe
  (titre, contenu, description, image, origines, signification_culturelle, lieu_decouverte, id_contenu)
VALUES (
  'Peuplement ancien',
  'Les traces archéologiques invitent à raconter une histoire plurielle, liée aux circulations entre l’Afrique orientale, Madagascar et l’océan Indien.',
  'Des traces datées du VIIIe siècle à Koungou aux échanges médiévaux de Dembeni, l’histoire ancienne de Mayotte se construit par étapes.',
  'https://upload.wikimedia.org/wikipedia/commons/e/e9/Koungou.jpg',
  'Les principaux repères sont archéologiques : des charbons datés du VIIIe siècle à Koungou, des vestiges à Acoua et le grand site de Dembeni pour les siècles suivants. Les chercheurs étudient les liens avec l’Afrique orientale et Madagascar. Les termes bantou et austronésien ou protomalgache renvoient à des ensembles linguistiques et historiques, non à une identité unique de tous les premiers habitants.',
  'Cette histoire met en valeur la pluralité des héritages de Mayotte et ses relations anciennes avec les îles voisines et les routes de l’océan Indien. Elle rappelle aussi l’importance de l’archéologie pour compléter les récits transmis oralement et les archives plus récentes. Présenter les incertitudes n’affaiblit pas l’histoire : cela respecte l’état des connaissances et laisse une place aux recherches futures.',
  'Repères archéologiques à Koungou, Acoua et Dembeni.',
  @article_content_id
);

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
SELECT 'Le Chakacha, danse traditionnelle mahoraise', 'Mayotte',
  'Le Chakacha est une danse festive portée par les rythmes et les mouvements. Les danseuses suivent le tempo dans une énergie collective qui invite au partage. Les pas, les gestes et les formes de la danse peuvent varier selon les groupes et les occasions. La musique et la danse font du Chakacha une expression vivante de la culture mahoraise.',
  CURRENT_TIMESTAMP, id_categorie, @article_contribution_id
FROM categorie WHERE nom = 'Traditions' AND domaine = 'Traditions';
SET @article_content_id = LAST_INSERT_ID();
INSERT INTO paragraphe (titre, contenu, description, id_contenu)
VALUES (
  'Danse traditionnelle',
  'Une danse mahoraise où le rythme et les mouvements créent un moment de partage.',
  'Une danse mahoraise où le rythme et les mouvements créent un moment de partage.',
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
