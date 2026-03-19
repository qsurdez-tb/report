= Notes on admin creation

New users, uniquement validation des requêtes en cours.

Validation d'un compte de type X et ensuite connection à la DB pour changer le type exact de user en 1 ce qui correspond à Administrator

Petit bug lorsqu'on change le username ou autre dans l'interface new user !

Rate limiting mais on sait pas trop où ça se passe 

En tout et pour tout la procédure est complexe et ne semble pas maîtriser tous les edge cases qui sont offerts par l'application

Tables pour voir la table donneur !

Les images des tenprints sont segmentés. Template par fiche dactylographique. Semblable à AFIS.

Admin tu as accès à tout tout tout. Et tu peux télécharger. Trainer peut aussi download ce à quoi il a accès. 

Groupe d'annotateur spécialisé pour les targets. 

Traces produites étaient trop belles mais les traces targets c'est celles qui ont été ciblées. Les incidental sont celles qu'on a pris juste pour être sûr d'avoir tout tant qu'à faire. 5 targets choisies et ensuite 50 traces des 5 targets !

Close non match list  qui ont été détecté. Troisième groupe AFIS qui prenait les traces ui allaient rechercher dans le système AFIS des pays accord. Et remontage du close non mtach des AFIS ! 

Experts qui disent oh intéressant - prend les traces - Opérateur AFIS reprend les close non match des systèmes pour les remonter dans l'application.

Empreintes des gens ont pas donné leur accord pour avoir leur empreinte qui proviennent des AFIS. 

Les labos ont signé des docs et le pays qui signait pour ICNML donne aux autres law enforcement automatiquement. 

Très peu de personnes qui ont les accès. 

Belles informations de contexte. Metadonnées pour chaque trace. 

Lien pianos icnml qui n'est plus utilisé

Projet Américain financé par NIJ, où UNIL était sous-contractant

Tâche = infrastructure du projet

But du porjet = trouver des close non match + mutualisation de trace de donneur et ensuite faire initiative de faire des close non match + Margaux a trouvé que y'en a peu.

Si vous êtes trainer dans law enforcement agency et créer des paquets = utiliser ICNML pour faire le shopping d'exercices pour ensuite envoyer aux collaborateurs.

Partie à ajouter, quand on regarde les traces on inspecte les traces les unes par rapport aux autres. Si algo de qualité, on peut les trier par LUW. Pas de moyen de chercher des traces par niveau de difficulté.

Résultat du projet = pas de close non match à la pelle donc rassurant + base de données totalement clean d'une centaine d'individus avec 50-60 traces par individus. Les gens l'utilisent pas forcément pour faire du close non match.

L'inscription est toujours d'actualité, la db peut grandir encore

Gestion de la db, elle est pour le projet ICNML. 

Trainer interface, la principale actuellement
- On ne peut pas chercher un donneur en particulier
- Pas de recherche par donneur
- Affiche la trace ou segment ou la piche pour utiliser comme casus
- Pas de bouton delete pour les listes d'exercices qui sont créés
- Bcp de réflexion interface pour que ça soit plus user friendly 
- Dans le folder on peut plus regarder les métadonnées
- Process qui sont à revoir dans l'expérience utilisateur
- Watermark actuel que le code barre, Pas sûr d'avoir info de qui à quelle heure
- Users = liste d'emails de tes utilisateurs, liens pour préparer le zip avec watermark pour chaque user à qui on envoit. 
- Pas de tri par qualité 


