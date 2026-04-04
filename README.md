<h1 align="center">YoungtimerRIF</h1>
<p align="center"><b>YoungtimerRIF</b> - Votre catalogue de voitures de collection</p>

---

## Description

**YoungtimerRIF** est une application web CRUD développée entièrement en Swift, permettant de consulter, ajouter, modifier et supprimer des annonces de voitures youngtimers - des véhicules de collection des années **1970 à 2010**.

Chaque annonce affiche la marque, le modèle, l'année, le kilométrage, le prix et l'état du véhicule. L'application propose également une **recherche** par marque, modèle ou couleur, ainsi qu'un **tri** par différents critères.

---

## Technologies

- **Swift 6.2**
- **Hummingbird 2** - Framework web Swift
- **SQLite** via SQLite.swift
- **GitHub Codespaces**

---

## Routes exposées

| Méthode | Route | Description |
|---------|-------|-------------|
| `GET` | `/` | Liste toutes les voitures - tri optionnel via `?sort=` |
| `GET` | `/search` | Recherche par marque, modèle ou couleur via `?q=` |
| `GET` | `/cars/:id` | Page de détail d'une voiture |
| `GET` | `/add` | Formulaire d'ajout d'une voiture |
| `GET` | `/edit/:id` | Formulaire de modification pré-rempli |
| `POST` | `/create` | Insertion d'une nouvelle voiture en base |
| `POST` | `/update/:id` | Mise à jour d'une voiture existante |
| `POST` | `/delete/:id` | Suppression d'une voiture |

---

## Instructions d'utilisation

### 1. Lancer l'application

```bash
./build.sh
./run.sh
```

L'application démarre sur le port **8080**.  
Dans GitHub Codespaces, ouvrez l'onglet **Ports** pour accéder à l'URL publique.

### 2. Naviguer dans le catalogue

- **Accueil** → `/` - voir toutes les annonces disponibles
- **Recherche** → barre de recherche en haut de page (`?q=mercedes`)
- **Tri** → boutons Marque / Année / Prix / Km (`?sort=brand`, `?sort=year`, `?sort=price`, `?sort=mileage`)

### 3. Gérer les annonces

- **Ajouter** → bouton **+ Ajouter** dans la barre de navigation → `/add`
- **Modifier** → bouton **Modifier** sur une carte ou depuis la page détail → `/edit/:id`
- **Supprimer** → bouton **Supprimer** depuis la page détail d'une voiture → `/delete/:id`

### 4. Base de données

Le fichier `youngtimer_garage.sqlite3` est créé automatiquement au premier lancement.  
Des données d'exemple sont insérées automatiquement si la base est vide.

---

## Auteur

**Kari Ihab** - Université Paris 8, 2026
