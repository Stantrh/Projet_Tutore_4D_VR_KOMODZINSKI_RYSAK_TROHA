# README - Apprentissage Godot 3D Jeu RPG RYSAK Hugo

Dans le cadre de cette première itération, j'ai suivi un tutoriel pour développé un jeu 3D avec le moteur Godot, ce qui m'a permis d'en apprendre plus sur Godot et me familiariser avec son interface 3D. Voici les points principaux que j'ai abordés :

1. Création et gestion du monde 3D

### Points abordés :

GridMap : Création d'environnements modulaires avec des grilles 3D.
World Environment : Configuration de l’atmosphère du monde (lumière, ombres, brouillard).
Level Design : Structuration de niveaux en utilisant des outils de design intégrés.
Torch & VFX : Ajout d'effets visuels tels que des lumières dynamiques et des particules.

### Application au projet :

Puisque nous travaillerons dans la 3 ème dimensions (pour représenter la 4 ème) nous pourrions utilsier ces gridmap pour Représenter différents hyperplans 3D d’un espace 4D. Chaque hyperplan peut être conçu comme un GridMap distinct, avec des environnements spécifiques.

2. Contrôle et interaction du joueur

### Points abordés :

Ajout du joueur : Intégration d’un personnage contrôlable.
Camera Controller : Mise en place d’une caméra dynamique suivant le joueur.
Player Movement : Gestion des déplacements avec des animations fluides.
Player Animation : Synchronisation des animations avec les actions du joueur.

### Application au projet :

Il est important de savoir comment controler la caméra et le joueur, puisque nous en implémenterons un dans notre projet, ces connaisances sont donc essentielles et nous faciliterons grandemant la tâche le moment de l'impémentation venu.


3. IA et interactions dynamiques

### Points abordés :

Finite State Machines (FSM) : Modélisation des comportements avec des états tels que Idle, Run, et Attack.
Monster Setup & Animation : Création et animation de monstres.
Player/Monster Interaction : Implémentation des systèmes d’attaque et de dégâts.

### Application au projet :

Bien qu'il ne soit pas prévu d'ajouter quelconque NPC à l'application, savoir comment faire des animation et manipuler les Finite State Machine peut toujours s'avérer utile



4. Interface utilisateur et ressources

### Points abordés :

GUI Setup : Création d’éléments d’interface tels que la barre de santé ou les inventaires.
Inventory System : Système d’objets (ajout, gestion et utilisation).
Game Over Overlay : Gestion des écrans de fin de partie.

### Application au projet :

Puisque nous allons concevoir une interface utilisateur nottament pour démarrer le jeu, changer de forme, de vue ect... les connaisances que m'a procurer ce tutoriel font surement s'avérer très utile pour l'implémentation d'une future UI


5. Effets visuels et sonores

### Points abordés :

Sound Effects : Ajout de sons pour enrichir l’expérience.
Custom Theme : Création de thèmes visuels personnalisés.
Torch & VFX : Effets de lumière et particules.

### Application au projet :

Les effets visuels peuvent être utilse et rajouter une sensation d'immersion au jeu et de polisage (par exemple un effet lorsque que l'on change de plan). Il peut être intéressant d'utilser les sons pour guider l'utilisateur dans la 4 ème dimension.



6. Progression et personnalisation

### Points abordés :

Level Up : Gestion de la progression du joueur.
Total Stats : Calcul et affichage des statistiques du joueur.
Profile & Equipment : Systèmes de personnalisation.

### Application au projet :

Ici ce système est purement utilisé pour les RPG, bien qu'il m'a permit d'en savoir plus sur GODOT, nous ne comptons pas implémenter des éléments de RPG dans notre application


## Résumé général

Ce tutoriel m’a permis de maîtriser des concepts essentiels pour la création d’un jeu en 3D, allant de la conception du monde et des interactions du joueur à la création d’interfaces et d’effets visuels. Ces compétences peuvent être directement appliquées à notre projet VR et me serons sûrement primordial pour le développement de l'application.



[lien vers la vidéo](https://www.youtube.com/watch?v=ouqgx1qKSdY&t=15157s&ab_channel=freeCodeCamp.org)