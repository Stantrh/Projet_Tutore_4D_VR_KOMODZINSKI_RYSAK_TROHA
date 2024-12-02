# Projet 3D avec Godot Engine

Ce projet est la suite de mon **projet tutoré** pour ma 3e année en BUT Informatique. Le jeu 3D a été réalisé en suivant [cette playlist](https://www.youtube.com/watch?v=CI-cVKuSD1s&list=PLda3VoSoc_TTp8Ng3C57spnNkOw3Hm_35), avec une exploration approfondie des outils 3D de **Godot Engine** et de **Blender**.

## 🚀 Objectifs du Projet

- Apprendre à utiliser **Godot Engine** pour développer un jeu 3D.
- Comprendre les concepts de base du développement de jeux 3D, comme les **Vector3**, les matériaux, et les collisions.
- Concevoir mes propres textures et modèles 3D avec **Blender**.

## 📚 Notions Abordées

### 1. **Noeuds 3D et Scènes**
Dans Godot, les jeux 3D reposent sur des **noeuds spécifiques**, comme `Node3D`, `Spatial`, et `Camera3D`. J'ai appris à :
- Créer et structurer des scènes 3D pour modéliser des environnements immersifs.
- Gérer la hiérarchie des noeuds pour organiser les objets dans l'espace 3D.
- Utiliser des noeuds spécifiques, comme `MeshInstance`, pour afficher des modèles 3D.

### 2. **Vector3 et Mouvements du Joueur**
Un des aspects cruciaux du projet a été de comprendre et manipuler les **Vector3** pour gérer les mouvements du joueur et de la caméra. Voici ce que j'ai appris :
- Ajuster les déplacements du joueur sur une surface en prenant en compte l'axe Y (gravité et inclinaison).
- Créer une caméra dynamique avec `Camera3D` pour suivre le joueur et s'orienter correctement.
- Intégrer des **RayCast** pour détecter les collisions et ajuster les mouvements.

### 3. **Création de Modèles et Textures avec Blender**
Pour rendre le jeu unique, j'ai conçu mes propres assets 3D avec **Blender** :
- Création de modèles de base (formes simples pour débuter).
- Génération et application de textures personnalisées.
- Exportation de mes créations au format **GLTF** pour les intégrer dans Godot.

### 4. **Gestion des Matériaux**
Dans Godot, les matériaux définissent l'apparence des objets 3D. J'ai appris à :
- Appliquer des **ShaderMaterial** et **StandardMaterial3D** pour personnaliser les surfaces.
- Configurer des propriétés comme la réflexion, la transparence, et la texture.
- Gérer la lumière (ex : `DirectionalLight3D`) pour améliorer l'esthétique de la scène.

### 5. **Physique et Collisions**
Pour rendre le jeu interactif, j'ai exploré la **physique** 3D :
- Utilisation de `CollisionShape3D` pour définir les volumes de collision.
- Intégration de la gravité et gestion des interactions avec le sol.
- Paramétrage des zones d’interaction avec des noeuds comme `Area3D`.

## 💡 Ce que ça m’a Apporté

- Une compréhension des concepts fondamentaux du **développement 3D** dans Godot.
- Une meilleure maîtrise des **Vector3** pour manipuler les positions, rotations, et déplacements dans l'espace.
- Une introduction à la création de contenu 3D avec **Blender**, une compétence essentielle pour les projets futurs.
- Une amélioration de mes compétences en **scripting GDScript**, en particulier pour la gestion de la caméra et du joueur.


