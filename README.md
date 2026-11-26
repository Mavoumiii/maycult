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

5. Démarrez l’API :

   ```sh
   npm start
   ```

L’API écoute sur `http://localhost:3000`. Vérifiez la connexion à MariaDB sur `http://localhost:3000/api/health`.

Pour lancer le site Vue dans un autre terminal : `npm run dev`. En développement, Vite relaie `/api` vers `http://localhost:3000`. Si le frontend et l’API sont déployés sur des origines différentes, définissez `VITE_API_URL` lors de la compilation du frontend, avec le préfixe `/api` (par exemple `https://api.exemple.fr/api`).

## Déployer le frontend sur GitHub Pages

Le workflow `.github/workflows/deploy-frontend.yml` compile le frontend et le publie sur GitHub Pages après chaque push sur la branche par défaut. Dans les paramètres du dépôt, activez **Pages** avec **GitHub Actions** comme source de déploiement. Le backend reste hébergé séparément sur Alwaysdata.

Le build utilise `https://maycult.alwaysdata.net/api` par défaut. Pour changer l’URL, ajoutez une variable de dépôt `VITE_API_URL` dans **Settings > Secrets and variables > Actions > Variables**. Cette URL est publique dans le navigateur : n’y mettez aucun secret.

Pour autoriser les appels depuis le site publié, configurez `CLIENT_ORIGIN` dans l’environnement backend avec les deux origines, séparées par une virgule : `http://localhost:5173,https://mavoumiii.github.io`, puis redémarrez l’API. Le backend autorise également cette origine GitHub Pages par défaut.

Les pages publiques ont chacune leur propre chemin : Accueil `/`, Explorer `/explorer`, Lieux de mémoire `/lieux-de-memoire`, Événements `/evenements`, Quiz `/quiz`, Profil `/profil`, Contribuer `/contribuer`, Proposer un événement `/proposer-evenement`, Diaspora `/diaspora`, À propos `/a-propos` et Contact `/contact`. Le workflow publie aussi une page de repli pour que les liens directs et le rechargement de ces URL fonctionnent sur GitHub Pages.

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

Les événements proposés et les contributions sont reliés au compte membre connecté et enregistrés en attente de modération. Le formulaire de contribution permet de choisir Histoires, Savoir-faire ou Traditions; la catégorie est conservée à la validation et détermine le classement dans la bibliothèque. Seuls les éléments validés sont retournés par les routes publiques. Les contenus, lieux et questions du quiz sont stockés dans les tables françaises du MLD et gérés depuis l’espace administrateur. La gestion des artistes n’est pas incluse dans le schéma MayCult et n’est donc pas disponible dans l’API.

La migration `002_maycult_schema.sql` crée le nouveau schéma puis supprime les anciennes tables anglaises de l’API et leurs données. Cette réinitialisation est destructive : sauvegardez la base avant d’exécuter `npm run db:init` si elle contient des informations à conserver. Le seed MayCult crée des exemples de contenus, lieux, quiz et événements ; il ne crée pas d’artistes.

## Hébergement Alwaysdata

Les variables `DB_HOST`, `DB_PORT` (3306), `DB_NAME`, `DB_USER`, `DB_PASSWORD` et `DB_SSL` sont chargées depuis `.env`. Ne placez jamais le mot de passe dans le code ou dans le dépôt. Lancez `npm run db:init` une fois les paramètres renseignés.

La migration du schéma et des données existantes depuis PostgreSQL n’est pas automatique : sauvegardez et convertissez les données avant de basculer une base déjà utilisée.

La connexion administrateur utilise `ADMIN_EMAIL`, `ADMIN_PASSWORD` et `ADMIN_TOKEN` configurés dans `.env`. Le jeton obtenu via `POST /api/admin/login` est utilisé pour les opérations d’administration. Les comptes membres sont enregistrés en base et leurs mots de passe sont stockés sous forme de hachage. Les images et médias sont référencés par URL ; les fichiers ne sont pas téléversés sur le serveur. Les favoris ne sont pas encore persistés.

## Routes principales

- `GET /api/events` : événements validés.
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
