# FeynmanSketch

Outil de génération de code Typst à partir d'un diagramme de Feynman dessiné dans une interface graphique (GUI).

Le projet est principalement écrit en **Swift**, avec un usage ponctuel de **C** pour les objets de diagramme, et **JSON** comme format de stockage.

## Architecture générale

1. **Dessin** — une interface graphique permet à l'utilisateur de représenter n'importe quel diagramme de Feynman.
2. **Conversion** — le dessin est converti en une structure de diagramme (nœuds et arêtes), sérialisable en JSON.
3. **Génération** — le code Typst est généré à partir de la représentation JSON.

## Architecture technique

Le projet est structuré en **4 packages Swift (SPM)**, séparant strictement les couches portables des couches spécifiques à la plateforme :

- **`DiagramModel`** — modèle de données du diagramme (nœuds, arêtes, types de particules)
- **`DiagramConversion`** — conversion du modèle vers la représentation JSON / Typst
- **`DiagramCompilation`** — appel au binaire `typst` pour générer un aperçu SVG
- **`FeynmanSketchApp`** — couche vue (SwiftUI), non portable par construction

**Principe directeur pour la portabilité Linux :** seules les couches *Model* et *ViewModel* (MVVM) sont conçues pour être portables ; la couche *View* sera réécrite intégralement pour chaque plateforme. Les types partagés (comme `Point`, une paire de `Double`) sont définis indépendamment de `CGPoint`/`CGFloat` dès le départ, pour éviter tout verrou macOS dans le code partagé.

## État d'avancement

- [x] Choix de l'architecture (packages, séparation Model/ViewModel/View)
- [x] Mise en place des packages Swift (`Package.swift`, build fonctionnel)
- [ ] GUI de dessin (SwiftUI, palette d'outils fermion / photon / gluon / scalaire, macOS uniquement dans un premier temps)
- [ ] Conversion du dessin en structure de diagramme (nœuds / arêtes)
- [x] Génération de code Typst à partir du diagramme (via `fletcher`)
- [ ] Chargement du JSON dans une structure de diagramme
- [ ] Documentation

## Développements futurs

- [ ] Portage de la GUI sur Linux
- [ ] Compilation du code généré directement dans l'outil (aperçu du résultat)
- [ ] Génération de code LaTeX (en plus de Typst)
- [ ] Ajout de tags aux objets du diagramme
- [ ] Export du diagramme en image (PNG, SVG, etc.)
- [ ] et sérialisation JSON
- [ ] Fonction annuler/rétablir (undo/redo) en stockant un historique d'une dizaine de diagramGraph() sous forme d'une pile de snapshot