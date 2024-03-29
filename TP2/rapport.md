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

**A) Quelle interprétation donnez-vous aux requêtes suivantes :**
```prolog
    ?- situation_initiale(S), joueur_initial(J).
```
Vrai si S situation initiale et J commence (renvoie le premier jouer à jouer et la configuration initiale)

```prolog
    ?- situation_initiale(S), nth1(3,S,Lig), nth1(2,Lig,o).
```
Insertion d'un "o" en ligne 3 colonne 2

**B) compléter le programme pour 
définir les différentes formes d’alignement retournées par le prédicat alignement(Ali, Matrice)**
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

**TODO**

rule(up,    1, Ini, S2).
rule(down, 1, Ini, S2).
rule(left,  1, Ini, S2).
rule(right, 1, Ini, S2).
findall (X, (member(X, [up, down, left, right]), rule(X, 1, Ini, S2)))

**E) quelle requête permet d'avoir ces 3 réponses regroupées dans une liste ? (cf. findall/3 en Annexe).**
```prolog
    initial_state(Ini), Dirs = [up,down,left,right], findall(Y, (member(X, Dirs), rule(X, 1, Ini, S2), Y = S2), Output).
```

**F) quelle requête permet d'avoir la liste de tous les couples [A, S] tels que S est la situation qui résulte de l'action A en U0 ?**
```prolog
    Dirs = [up,down,left,right], findall(Y, (member(X, Dirs), rule(X, 1, A, S), Y = [A, S]), Output).
```

## Développement de l’heuristique
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

## Développement de l’algorithme Negamax





## Expérimentation et extensions
