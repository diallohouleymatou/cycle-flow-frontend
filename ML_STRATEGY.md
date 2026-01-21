# Stratégie d'Intégration Machine Learning (ML)
## "Smart Cycle Adaptation" - Au-delà du Calendrier

Pour que l'application se démarque et offre une véritable valeur ajoutée, notamment pour les cycles irréguliers (PCOS, préménopause, post-partum), elle doit abandonner les mathématiques statiques pour des probabilités dynamiques.

Voici la stratégie technique et fonctionnelle proposée pour intégrer une couche d'intelligence artificielle locale.

---

## 1. Concept Clé : "L'Empreinte Hormonale" (The Hormonal Fingerprint)

Chaque femme possède une signature physiologique unique qui précède ses règles ou son ovulation.
*   **Approche Classique :** "Dernières règles + 28 jours = Prochaines règles". (Échec total sur cycles irréguliers).
*   **Approche ML :** "La température de l'utilisatrice X a chuté, sa fréquence cardiaque de repos a augmenté de 3bpm et elle a signalé 'fatigue'. Historiquement, chez elle, cela signifie règles dans 48h (probabilité 85%), même si nous ne sommes qu'au jour 22."

## 2. Architecture Technique : Edge AI (On-Device)

Pour garantir la confidentialité (le point fort de "Secure-Repo"), **aucune donnée brute ne quitte le téléphone**. Le ML tourne en local.

*   **Framework :** `tflite_flutter` (TensorFlow Lite).
*   **Modèle :** Réseau de neurones léger (Lightweight Neural Network) ou Forêt Aléatoire (Random Forest) convertie en TFLite.
*   **Avantages :** Fonctionne hors ligne, zéro latence, privé par design.

## 3. Les Données d'Entrée (Features)

Pour détecter les cycles irréguliers, l'algorithme a besoin de signaux "non calendaires". Nous devons croiser trois types de données :

1.  **Biométrie Passive (Via Google Fit / Apple Health) :**
    *   **RHR (Resting Heart Rate) :** Augmente significativement (2-5 bpm) en phase lutéale (post-ovulation) et chute juste avant les règles. C'est le marqueur le plus fiable pour les cycles irréguliers.
    *   **Température (si dispo) :** Confirmation ovulation.
    *   **Qualité du sommeil :** Perturbations fréquentes en phase lutéale tardive (SPM).

2.  **Symptômes Subjectifs (Logs Utilisateur) :**
    *   Texture de la glaire (Cervical Mucus).
    *   Douleurs (Crampes, Seins douloureux).
    *   Humeur (Irritabilité, Anxiété).

3.  **Historique Cyclique :**
    *   Durée des 12 derniers cycles.
    *   Variance (Standard Deviation).

## 4. Stratégie pour les Cycles Irréguliers (PCOS)

C'est ici que l'application gagne sa "valeur ajoutée".

*   **Mode "Détection de Pattern" :**
    Si l'écart-type des cycles est élevé (> 5 jours), l'algorithme *désactive* la prédiction calendaire pure.
*   **Prédiction Probabiliste :**
    Au lieu de dire "Règles dans 10 jours", l'app dira : "Probabilité de règles aujourd'hui : 12%".
    Dès que les signaux biométriques (chute RHR + acné par exemple) s'alignent avec un pattern connu de l'utilisatrice, la probabilité bondit : "Probabilité : 80% (Vos signaux corporels indiquent une arrivée imminente)".

## 5. Implementation Roadmap (Flutter)

### Phase 1 : Collecte & Structure (Le Socle)
*   **Action :** Intégrer le package `health` pour récupérer RHR et Sommeil (avec permission).
*   **Action :** Enrichir `RecordModel` pour structurer ces données en vecteurs d'entraînement.
    *   Exemple vecteur : `[DayOfCycle, RHR_Avg, Sleep_Score, Mucus_Value, Mood_Value]`.

### Phase 2 : Modèle "Cold Start" (Le Démarrage)
*   L'application est livrée avec un modèle "générique" pré-entraîné sur un dataset public (anonymisé) de cycles variés.
*   Cela permet de donner des prédictions correctes dès le jour 1, même sans historique personnel.

### Phase 3 : "Personal Fine-Tuning" (L'Adaptation)
*   C'est le **Machine Learning Adaptatif**.
*   Chaque mois, quand l'utilisatrice confirme ses règles, l'application effectue un "retraining" léger du modèle local.
*   Le modèle ajuste ses poids : "Pour CETTE utilisatrice, la douleur aux seins est un prédicteur à 3 jours (poids fort), mais la température est inutile (poids faible)."

## 6. Pourquoi c'est différent ?

La plupart des applications "lissent" les irrégularités (elles les ignorent comme des erreurs).
**Nous, nous utilisons l'irrégularité comme une donnée.** Nous ne prédisons pas *quand* le cycle devrait finir mathématiquement, nous détectons *quand* il est physiquement en train de finir.
