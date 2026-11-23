# CulVite

Application Vue 3 avec une API Express et une base MariaDB.

## Préparer MariaDB

DBeaver est un client de base de données : MariaDB doit être installé et démarré séparément.

1. Dans le panneau Alwaysdata, créez la base et l’utilisateur MariaDB. Pour le compte actuel, les valeurs configurées sont `maycult`.
2. Copiez `.env.example` en `.env`, puis remplacez `DB_PASSWORD` par le mot de passe MariaDB et renseignez `AUTH_TOKEN_SECRET`, `ADMIN_EMAIL`, `ADMIN_PASSWORD` et `ADMIN_TOKEN` avec des valeurs secrètes uniques.
3. Dans DBeaver, créez une connexion **MariaDB** avec l’hôte `mysql-maycult.alwaysdata.net`, le port `3306`, la base `maycult` et l’utilisateur `maycult`. Saisissez le mot de passe MariaDB et laissez le tunnel SSH désactivé.
4. À la racine du projet, appliquez les migrations et chargez les données initiales :

   ```sh
   npm run db:init
   ```

   Pour appliquer uniquement les migrations ultérieures, sans recharger les données initiales, utilisez `npm run db:migrate`.

5. Démarrez l’API :

   ```sh
   npm start
   ```

L’API écoute sur `http://localhost:3000`. Vérifiez la connexion à MariaDB sur `http://localhost:3000/api/health`.

Pour lancer le site Vue dans un autre terminal : `npm run dev`. En développement, Vite relaie `/api` vers `http://localhost:3000`. Si le frontend et l’API sont déployés sur des origines différentes, définissez `VITE_API_URL` lors de la compilation du frontend, avec le préfixe `/api` (par exemple `https://api.exemple.fr/api`).

## Organisation

- `frontend/` : application Vue, vues, composants, styles, images et configuration Vite.
- `backend/src/config/db.js` : variables d’environnement, connexion MariaDB et lanceur de migrations.
- `backend/Database/migrations/` : migrations SQL versionnées, appliquées une seule fois.
- `backend/Database/api-seed-maycult-v1.sql` : données initiales adaptées au schéma MayCult, chargées une seule fois.
- `backend/src/models` : requêtes paramétrées vers la base.
- `backend/src/services` : validation et règles de publication.
- `backend/src/controllers` : traitement des requêtes HTTP.
- `backend/src/middlewares` : authentification admin, erreurs et gestion asynchrone.
- `backend/src/router` : routes `/api`.

Les événements proposés et les contributions sont reliés au compte membre connecté et enregistrés en attente de modération. Seuls les éléments validés sont retournés par les routes publiques. Les contenus, lieux et questions du quiz sont stockés dans les tables françaises du MLD et gérés depuis l’espace administrateur. La gestion des artistes n’est pas incluse dans le schéma MayCult et n’est donc pas disponible dans l’API.

La migration `001_maycult_schema.sql` crée le schéma MayCult et supprime les anciennes tables anglaises de l’API et leurs données. La migration `002_admin_accounts.sql` sépare les comptes dans `administrateur` des comptes membres dans `utilisateur` et retire le champ `role` des utilisateurs. Elle transfère les anciens comptes admin utilisables. La migration `003_admin_session_version.sql` permet de révoquer les sessions après un changement de mot de passe. Sauvegardez la base avant d’exécuter les migrations si elle contient des informations à conserver. Le seed MayCult crée des exemples de contenus, lieux, quiz et événements ; il ne crée pas d’artistes.

## Hébergement Alwaysdata

Les variables `DB_HOST`, `DB_PORT` (3306), `DB_NAME`, `DB_USER`, `DB_PASSWORD` et `DB_SSL` sont chargées depuis `.env`. Ne placez jamais le mot de passe dans le code ou dans le dépôt. Lancez `npm run db:init` une fois les paramètres renseignés.

La migration du schéma et des données existantes depuis PostgreSQL n’est pas automatique : sauvegardez et convertissez les données avant de basculer une base déjà utilisée.

La première connexion administrateur utilise `ADMIN_EMAIL` et `ADMIN_PASSWORD` de `.env` pour créer son compte dans `administrateur`, avec un mot de passe haché. Les connexions suivantes vérifient les comptes en base. `ADMIN_TOKEN` sert de secret de signature pour les sessions admin, lesquelles expirent et sont révoquées après un changement de mot de passe ou la suppression du compte. Après cette mise à jour, les admins doivent se reconnecter pour obtenir un nouveau jeton signé. Les comptes membres sont enregistrés séparément dans `utilisateur`, avec leurs mots de passe hachés. Les images et médias sont référencés par URL ; les fichiers ne sont pas téléversés sur le serveur. Les favoris ne sont pas encore persistés.

## Routes principales

- `GET /api/events` : événements validés.
- `POST /api/admin/login` : connexion administrateur.
- `GET /api/admin/admins`, `POST /api/admin/admins`, `PUT /api/admin/admins/:id`, `DELETE /api/admin/admins/:id` : gestion protégée des comptes administrateurs. `POST` attend `nom`, `prenom`, `email` et `password`; `PUT` attend `nom`, `prenom`, `email` et accepte un `password` facultatif. Les mots de passe doivent contenir de 10 à 200 caractères; la suppression du dernier compte est refusée.
- `POST /api/events/proposals` : soumettre une proposition d’événement.
- `GET /api/admin/events` et `PATCH /api/admin/events/:id/status` : gestion admin des événements.
- `POST /api/contributions` : soumettre une contribution.
- `GET /api/contributions/published` : contributions validées.
- `GET /api/contributions`, `PATCH /api/contributions/:id/status`, `PUT /api/contributions/:id`, `DELETE /api/contributions/:id` : gestion admin des contributions.
- `GET /api/contributors` : contributeurs issus des contributions validées.
- `GET /api/catalog/articles`, `/api/catalog/places` et `/api/catalog/quiz` : contenus publics du catalogue.
- `POST /api/catalog/:resource`, `PUT /api/catalog/:resource/:id` et `DELETE /api/catalog/:resource/:id` : gestion administrateur du catalogue (`articles`, `places`, `quiz`).

Les champs image et média en base sont des URL/métadonnées ; le stockage des fichiers eux-mêmes nécessite un service de fichiers ou une route d’upload, qui n’est pas encore configuré.
Learn more about IDE Support for Vue in the [Vue Docs Scaling up Guide](https://vuejs.org/guide/scaling-up/tooling.html#ide-support).
