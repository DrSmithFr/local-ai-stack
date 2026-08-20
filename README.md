# Stack IA locale

Stack complète pour l'IA en local, orchestrée avec Docker Compose. Elle regroupe OpenWebUI, SearXNG, Open Terminal et Whisper, tous accessibles via un reverse proxy Nginx.

## Vue d'ensemble

Le reverse proxy Nginx expose chaque service sous son propre nom d'hôte. Pour activer le SSL sur ces noms, deux options existent :

- Ajouter une entrée dans le fichier `hosts` de la machine cliente, pointant `openwebui` et `searxng` vers l'IP du reverse proxy.
- Déployer un second reverse proxy en amont, dédié à la terminaison SSL, qui relaie ensuite vers ce reverse proxy interne.

## Architecture

| Composant | Rôle |
|---|---|
| `nginx` | Reverse proxy interne, route les requêtes vers chaque service selon le nom d'hôte. |
| `openwebui` | Interface de chat pour les modèles IA locaux. |
| `searxng` | Moteur de recherche utilisé comme source web par OpenWebUI. |
| `open-terminal` | Terminal accessible depuis l'interface, pour l'exécution de commandes. |
| `whisper` | Service de transcription audio. |
| `postgres` (+ `pgvector`) | Base de données d'OpenWebUI, avec support des embeddings vectoriels. |
| `redis` | Instance partagée entre OpenWebUI et SearXNG, avec des tables distinctes pour chaque service. |

## Prérequis

- Docker et Docker Compose.
- `make`, pour utiliser la Makefile fournie.
- Un certificat TLS valide, si le SSL est terminé sur ce reverse proxy plutôt que sur un reverse proxy en amont.

## Configurer l'accès réseau

Pour accéder aux services par leur nom plutôt que par IP, ajoutez les lignes suivantes au fichier `hosts` :

```
<ip_reverse_proxy> openwebui
<ip_reverse_proxy> searxng
```

Remplacez `<ip_reverse_proxy>` par l'adresse IP du reverse proxy Nginx.

Facultatif : pour terminer le SSL en amont plutôt que sur ce reverse proxy, déployez un second reverse proxy chargé des certificats, puis faites-le pointer vers ce reverse proxy interne.

## Utiliser la Makefile

La Makefile centralise les opérations courantes sur la stack.

| Cible | Effet |
|---|---|
| `make start` | Construit les images puis démarre les conteneurs en arrière-plan. |
| `make stop` | Arrête les conteneurs sans les supprimer. |
| `make kill` | Force l'arrêt immédiat des conteneurs. |
| `make reload` | Enchaîne `kill` puis `start`, pour redémarrer la stack. |
| `make remove` | Supprime les conteneurs arrêtés. |
| `make clean` | Enchaîne `kill`, `remove`, puis purge les conteneurs, volumes et réseaux orphelins. |
| `make update` | Arrête la stack, récupère les images à jour, reconstruit, puis redémarre. |

Pour démarrer la stack pour la première fois, exécutez `make start` depuis le dossier du projet.

## Base de données et cache

OpenWebUI stocke ses données dans `postgres`, avec l'extension `pgvector` pour la recherche par similarité sur les embeddings. `searxng` et `openwebui` partagent la même instance `redis`, chacun via ses propres tables, pour éviter toute collision de clés.

## Sécurité

Le reverse proxy Nginx applique un ensemble d'en-têtes de sécurité (HSTS, CSP, isolation cross-origin, entre autres) sur les services exposés. La CSP est volontairement stricte par défaut ; si un service échoue à charger une ressource (script inline, image en `data:` URI, connexion WebSocket), ajustez la directive correspondante plutôt que de désactiver la CSP entière.
