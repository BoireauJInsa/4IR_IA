<h1 align="center">
  <br>
    TP 1 IA - Algorithme A*
  <br>

</h1>

<h4 align="center">Application au taquin</h4>

<p align="center">
  <a href="#familiarisation-avec-le-problème-du-taquin-33">Familiarisation avec le problème du Taquin 3×3</a> •
  <a href="#développement-des-2-heuristiques">Développement des 2 heuristiques </a> •
  <a href="#Implémentation-de-A*">Implémentation de A</a> •
</p>


## Familiarisation avec le problème du Taquin 3×3

**A) Quelle clause Prolog permettrait de représenter la situation finale du Taquin 4x4 ?**
```prolog
final_state([[1,  2,  3,  4],
            [5,  6,  7,  8],
            [9,  10, 11, 12],
            [13, 14, 15, vide]]).
```

**B) A quelles questions permettent  de répondre les requêtes suivantes :**
```prolog
?- initial_state(Ini), nth1(L,Ini,Ligne), nth1(C,Ligne, d).
```
Est vrai si 'd' se situe dans la ligne L et la colonne C

```prolog
?- final_state(Fin), nth1(3,Fin,Ligne), nth1(2,Ligne,P)
```
Est vrai si P se trouve en L3C2 (ligne 3 colonne 2)

**C Quelle requête Prolog permettrait de savoir si une pièce donnée P (ex : a)  est bien placée dans U0 (par rapport à F) ?**
```prolog
initial_state(Ini), nth1(L,Ini,Ligne), nth1(C,Ligne, X),
final_state(Fin), nth1(L,Fin,Ligne), nth1(C,Ligne,X).
```
Avec X la pièce donnée

**D) quelle requête permet de trouver une situation suivante de l'état initial du Taquin 3×3 (3 sont possibles) ?**

Pour trouver une situation suivante possible :
```prolog
initial_state(Ini), rule(R,1,Ini,Suivant).
```

**E) quelle requête permet d'avoir ces 3 réponses regroupées dans une liste ? (cf. findall/3 en Annexe).**
```prolog
initial_state(Ini), Dirs = [up,down,left,right], findall(Y, (member(X, Dirs), rule(X, 1, Ini, S2), Y = S2), Output).
```

**F) quelle requête permet d'avoir la liste de tous les couples [A, S] tels que S est la situation qui résulte de l'action A en U0 ?**
```prolog
Dirs = [up,down,left,right], findall(Y, (member(X, Dirs), rule(X, 1, A, S), Y = [A, S]), Output).
```

## Développement des 2 heuristiques
Des tests unitaires sont fournis dans le fichier taquin.pl

**2.1) heuristique du nombre de pièces mal placées :**
```prolog
good(X, U) :-           % Vrai si une pièce X est bien placée dans un état U
    final_state(Fin),
    nth1(L,U,Ligne), nth1(C,Ligne, X),
    not(X = vide),
    nth1(L,Fin,Ligne2), nth1(C,Ligne2, X2),
    not(X = X2).

heuristique1(U, H) :- 
    findall(Y, good(Y, U), Result),     %Liste les pièces bien placées
    length(Result, H).
```

**2.2) heuristique basée sur la distance de Manhattan :**
```prolog
mantan(X, U, R) :- % Vrai si la pièce X dans l'état U a une distance de Manhattan R de son état final
    final_state(Fin),
    nth1(L1,U,Ligne), nth1(C1,Ligne, X),
    nth1(L2,Fin,Ligne2), nth1(C2,Ligne2, X),
    SL is abs( L1 - L2),
    SC is abs( C1 - C2),
    R is SL + SC.

heuristique2(U, H) :- 
    findall(A, good(A, U), Result),
    findall(Y, (member(X, Result), mantan(X, U, R), Y = R), ManList),
    sumlist(ManList, H).
```

## Implémentation de A*

Des tests unitaires sont disponibles dans le fichier aetoile.pl. Leur nom commence toujours par "test".

```prolog
------- Time performance -------

Initial : [ [b, h, c],     
            [a, f, d],       
            [g,vide,e] ],

heuristique1 : 0.292s, 0.282s, 0.278s, 0.278s
heuristique2 : 0.275s, 0.280s, 0.290s, 0.267s

--------

Initial : [ [ a, b, c],        
            [ g, h, d],
            [vide,f, e] ]

heurisitique1 : 0.164s, 0.150s, 0.151s, 0.133s 
heuristique2 : 0.158s, 0.151s, 0.140s, 0.138s


------
 Initial : [ [b, c, d],
            [a,vide,g],
            [f, h, e]  ]
h1 : 0.507s, 0.493s, 0.486s, 0.486s
h2 : 0.491s, 0.472s, 0.476s, 0.472s

-----
Initial : [ [f, g, a],
            [h,vide,b],
            [d, c, e]  ]

h1 : Fail
h2 : 0.896s, 0.891s, 0.904s, 0.967s

------
The rest just fails
```

<hr/>
<hr/>


<h1 align="center">
  <br>
    TP 2 IA - Algorithme MinMax
  <br>

</h1>

<h4 align="center">Application au TicTacToe</h4>

<p align="center">
  <a href="# Familiarisation avec le problème du TicTacToe 3×3">Familiarisation avec le problème du TicTacToe 3×3</a> •
  <a href="# Développement de l’heuristique">Développement de l’heuristique</a> •
  <a href="# Développement de l’algorithme Negamax">Développement de l’algorithme Negamax</a> •
  <a href="# Expérimentation et extensions">Expérimentation et extensions</a> •
</p>


## Familiarisation avec le problème du TicTacToe 3×3

**1) Quelle interprétation donnez-vous aux requêtes suivantes :**
```prolog
    ?- situation_initiale(S), joueur_initial(J).
```
Vrai si S situation initiale et J commence (renvoie le premier jouer à jouer et la configuration initiale)

```prolog
    ?- situation_initiale(S), nth1(3,S,Lig), nth1(2,Lig,o).
```
Insertion d'un "o" en ligne 3 colonne 2

**2) compléter le programme pour définir les différentes formes d’alignement retournées par le prédicat lignement(Ali, Matrice)**
```prolog
    colonne(C,M) :-
        transpose(M, Ts),
        ligne(C, Ts).

    diagonale(D, M) :-
        length(M, X),
        seconde_diag(X, D, M).

    seconde_diag(_,[],[]).
    seconde_diag(K,[E|D],[Ligne|M]) :-
        nth1(K,Ligne,E),
        K1 is K-1,
        seconde_diag(K1,D,M).
```
**Définir le prédicat possible(Ali, Joueur)**
```prolog
    possible([X|L], J) :- unifiable(X,J), possible(L,J).
    possible( [],  _).

    unifiable(X,_) :-
        var(X),
        !.

    unifiable(X, X).
```
**Définir les prédicats alignement_gagnant(A, J) et alignement_perdant(A, J)**
```prolog
    alignement_gagnant(Ali, J) :-
        ground(Ali),
        possible(Ali, J).

    alignement_perdant(Ali, J) :- 
        adversaire(J, G),
        alignement_gagnant(Ali, G).
```

TODO: tests unitaires pour tous

## Développement de l’heuristique
```prolog
    heuristique(J,Situation,H) :-
        adversaire(J, G),
        
        findall(_, (alignement(L, Situation), possible(L, J)), ListOutJ),
        findall(_, (alignement(L, Situation), possible(L, G)), ListOutG),
        length(ListOutJ, Lj),
        length(ListOutG, Lg),
        H is Lj - Lg.
```

TODO: tests unitaires

## Développement de l’algorithme Negamax

**Quel prédicat permet de connaître sous forme de liste l’ensemble des couples [Coord, Situation_Resultante]  tels que chaque élément (couple) associe le coup d’un joueur et la situation qui en résulte à partir d’une situation donnée ?**

Pour un joueur J et un état donné Etat, on a :
```prolog
    ?- successeurs(J,Etat,Succ).
```


TODO: tests unitaires

## Expérimentation et extensions

**1) Quel est le meilleur coup à jouer et le gain espéré pour une profondeur d’analyse de 1, 2, 3, 4 , 5 , 6 , 7, 8, 9 ? Expliquer les résultats obtenus pour 9 (toute la grille remplie).**

| Pmax 	| 1      	| 2      	| 3      	| 4      	| 5      	| 6      	| 7      	| 8     	| 9     	|
|------	|--------	|--------	|--------	|--------	|--------	|--------	|--------	|-------	|-------	|
| Coup 	| [2, 2] 	| [2, 2] 	| [2, 2] 	| [2, 2] 	| [2, 2] 	| [2, 2] 	| [2, 2] 	| Error 	| Error 	|
| Gain 	| 4      	| 1      	| 3      	| 1      	| 3      	| 1      	| 2      	| Error 	| Error 	|

Pour Pmax = 8 et Pmax = 9, erreur Stack limit exceeded.

**2) Comment ne pas développer inutilement des situations symétriques de situations déjà développées ?**

Avant d'évaluer l'état actuel, il faudrait aussi vérifier les rotations de cet état et vérifier que ces nouveaux états ne correspondent pas à un état déjà évalué.

**3) Que faut-il reprendre pour passer au jeu du puissance 4 ?**

Il faudrait modifier les prédicats d'alignement (pour 4 pions et chaques diagonales possibles), et mettre en place un système de pile sur chaque colonne (un pion placé doit arriver en bas).

**4) Comment améliorer l’algorithme en élaguant certains coups inutiles (recherche Alpha-Beta) ?**

Il faut comparer le meilleur coup (en gain) de la branche que l'on souhaite développer avec le meilleur coup des branches développées. On ne développe cette branche que si son meilleur coup est est plus élevé que les autres.