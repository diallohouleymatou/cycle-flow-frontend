# Gestion Avancée et Adaptative du Cycle Menstruel

Ce document décrit la stratégie technique et fonctionnelle pour mettre en place un système de gestion du cycle menstruel qui s'adapte à chaque utilisatrice, dépassant le simple calcul calendaire standard ("méthode Rythmique").

## 1. Philosophie : L'Adaptabilité avant le Calcul

Le problème des applications standards est qu'elles appliquent une règle mathématique rigide (Cycle = 28 jours, Ovulation = J-14). Notre système doit traiter chaque utilisatrice comme un cas unique en apprenant de ses données historiques et de ses symptômes temps réel.

## 2. Algorithme de Prédiction Hybride

Le moteur de prédiction ne doit pas se baser sur une seule formule. Il doit utiliser une approche pondérée :

### A. Moyenne Pondérée Dynamique (Smart Average)
Au lieu d'une moyenne simple des cycles passés, nous utilisons une moyenne pondérée donnant plus d'importance aux cycles récents.
*   *Formule proposée :* `Durée_Prevue = (C_1 * 0.5) + (C_2 * 0.3) + (C_3 * 0.2)`
    *   `C_1` : Durée du dernier cycle.
    *   `C_2` : Durée de l'avant-dernier cycle.
    *   `C_3` : Moyenne des cycles antérieurs.

### B. Détection de la Variabilité (Gestion des Cycles Irréguliers)
Le système calcule l'écart-type des 6 derniers cycles.
*   **Si Écart-type < 3 jours :** Cycle considéré "Régulier". L'algorithme standard s'applique avec une fenêtre de confiance étroite.
*   **Si Écart-type > 3 jours :** Cycle "Irrégulier".
    *   **Action :** Élargir la fenêtre de fertilité affichée (ex: 8 jours au lieu de 5).
    *   **Action :** Afficher un indicateur de fiabilité ("Prédiction à faible certitude").
    *   **Action :** Suggérer davantage de tracking de symptômes physiques pour compenser l'incertitude calendaire.

## 3. Affinement par les Symptômes (Corrélation Biomtrique)

Le calcul calendaire ne donne qu'une "fenêtre théorique". La "valeur ajoutée" vient de la confirmation par les signaux corporels.

### Indicateurs Clés à Tracker
Le `RecordModel` doit inclure ces champs spécifiques pour affiner la prédiction :
1.  **Température Basale (BBT) :** Une hausse légère (0.3°C - 0.5°C) confirme que l'ovulation *a eu lieu*.
    *   *Logique :* Si `BBT` monte et reste haute 3 jours -> Décaler la phase Lutéale pour qu'elle commence à ce moment-là, recalculer la date des prochaines règles (`Date_Ovulation_Detectée + 14 jours`).
2.  **Glaire Cervicale :**
    *   *Type "Blanc d'œuf" :* Indique une fertilité maximale imminente. Si détecté avant la date prévue, avancer la prédiction d'ovulation.
3.  **Libido & Douleurs (Mittelschmerz) :**
    *   Utilisés comme signaux faibles pour confirmer l'entrée dans la fenêtre fertile.

## 4. Architecture des Données "Privacy-First"

Pour résoudre l'ambiguïté actuelle (dépendance au serveur), le modèle de données doit être **Local-First**.

### Structure Proposée (Local Storage sécurisé)
```dart
class UserCycleProfile {
  int averageLength;
  int lutealPhaseLength; // Par défaut 14, mais ajustable (12-16)
  bool isIrregular;
  List<CompletedCycle> history; // Les 12 derniers mois
}

class DailyLog {
  DateTime date;
  double? temperature;
  String? mucusTexture; // dry, sticky, creamy, egg_white
  int? ovulationTestResult; // 0=neg, 1=pos
}
```
*   **Synchronisation :** Les données sont stockées chiffrées en local (`flutter_secure_storage` ou base SQL chiffrée) et ne sont envoyées au serveur que pour la sauvegarde (SyncService), jamais pour le calcul primaire. L'appli fonctionne à 100% hors ligne.

## 5. Boucle de Feedback Utilisateur (Apprentissage)

Le système doit demander explicitement une validation en cas de décalage.
*   *Scénario :* L'utilisatrice note ses règles 3 jours plus tôt que prévu.
*   *Réaction Système :*
    1.  Ne pas juste accepter la date.
    2.  Demander : "Vos règles sont arrivées plus tôt. Était-ce un flux normal ou du spotting ?" (Pour éviter de confondre spotting d'ovulation et règles).
    3.  Si confirmé : Intégrer ce cycle court dans la moyenne pondérée immédiatement pour ajuster le mois suivant.

## 6. Roadmap Technique

1.  **Refactor `CycleProvider` :** Supprimer la date fictive (`DateTime.now().subtract(days: 12)`). Implémenter la persistance locale des dates réelles.
2.  **Update `RecordModel` :** Ajouter les champs bio-marqueurs (température, glaire).
3.  **Créer `AdaptiveCycleEngine` :** Une classe dédiée contenant la logique pondérée décrite ci-dessus, séparée de l'UI.
