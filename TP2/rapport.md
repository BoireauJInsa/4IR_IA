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

## Expérimentation et extensions
```prolog

```