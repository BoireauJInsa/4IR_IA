<h1 align="center">
  <br>
    TP 1 IA - Algorithme A*
  <br>

</h1>

<h4 align="center">Application au taquin</h4>

<p align="center">
  <a href="#Familiarisation avec le problème du Taquin 3×3">Familiarisation avec le problème du Taquin 3×3</a> •
  <a href="#Développement des 2 heuristiques">Développement des 2 heuristiques </a> •
  <a href="#Implémentation de A*">Implémentation de A*</a> •
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
