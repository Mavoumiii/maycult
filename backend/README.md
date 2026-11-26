# Backend May’Cult

L’API utilise Node.js, Express et MariaDB. Les sources sont classées par rôle dans `src/` :

```text
src/
├── app.js, server.js
├── config/        # configuration, connexion et migrations de la base
├── controllers/   # traitement des requêtes HTTP
├── middlewares/   # authentification et erreurs
├── models/        # accès aux données
├── router/        # routes de l’API
└── services/      # règles métier
```

## Base de données

```text
Database/
├── migrations/                  # changements versionnés du schéma et des données
└── api-seed-maycult-v1.sql      # données initiales, chargées une seule fois
```

Chaque migration utile est exécutée une seule fois et suivie par son nom de fichier dans `schema_migrations`. Les migrations déjà publiées ne doivent pas être renommées, renumérotées, modifiées ou fusionnées : pour toute évolution future, ajouter une nouvelle migration SQL séquentielle. Les numéros manquants correspondent à d’anciens fichiers vides retirés lors du nettoyage ; ils ne signalent pas une étape manquante. Les migrations `009` à `011` sont conservées car elles ajustent les données existantes.

Le nom du fichier de seed est conservé, car `database_seeds` l’utilise pour éviter de charger les données initiales une deuxième fois.

Les contributions membres enregistrent également la catégorie de bibliothèque choisie (`Histoires`, `Savoir-faire` ou `Traditions`). Cette catégorie est conservée séparément de la catégorie technique utilisée pour la modération.

Depuis la racine du dépôt :

```sh
npm run db:init      # migrations et données initiales
npm run db:migrate   # migrations uniquement
npm start            # démarrer l’API
```

Les paramètres de connexion et les secrets sont configurés dans le fichier `.env` du backend. Ne pas ajouter ce fichier au dépôt.
