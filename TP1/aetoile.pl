%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************
test_state([ [a, b, c],
            [vide, h, d],
            [g,f,e] ]).

main :-
	% initialisations Pf, Pu et Q 
	test_state(S0),
	heuristique(S0, H0),
	G0 is 0,
	F0 is H0 + G0,
	Pf0 = nil,
	Pu0 = nil,
	insert([S0, [F0, H0, G0], nil, nil], nil, Q),
	insert([S0, [F0, H0, G0], nil, nil], Pu0, Pu),
	insert([[F0, H0, G0], S0], Pf0, Pf),
	
	% lancement de Aetoile

	aetoile(Pf, Pu, Q).



%*******************************************************************************

aetoile(Pf, Pu, _):-
	empty(Pf),
	empty(Pu),
	write('Pas de solution : L état final n est pas atteignable').

aetoile(Pf, _, Q):-
	
	suppress_min([[_, _, _], Sf], Pf, _),
	final_state(Sf),
	write('P0\n'),
	affiche_solution(Sf, Q).


aetoile(Pf, Pu, Q) :-
	suppress_min([[F, H, G], U], Pf, Pf_bis),
	not(final_state(U)),
	write('P1\n'),
	suppress([U, [F, H, G], Pere, A], Pu, Pu_bis),
	insert([U, [F, H, G], Pere, A], Q, Q_new),
	write('P2\n'),
	findall([Sx, [Fx, Hx, Gx], U, Ax], (expand(U, [F, H, G], Sx, [Fx, Hx, Gx], Ax)), L),
	write('P3\n'),
	loop_successors(L, Pf_bis, Pu_bis, Q, Pf_new, Pu_new),
	write('P4\n'),
	aetoile(Pf_new, Pu_new, Q_new).
	

affiche_solution(nil, _, _):-	
	write('Fin solution').

affiche_solution(U, Q):-
	suppress([U, [_, _, _], Pere, A], Q, Q_new),
	write(U),
	write('  :  '),
	write(A),
	write('.   \n'),
	affiche_solution(Pere, Q_new).

expand(U, [_, _, Gu], S, [Fs, Hs, Gs], A):-
	rule(A, C, U, S),
	Gs is Gu + C,
	heuristique(S, Hs),
	Fs is Gs + Hs.


loop_successors([], Pf, Pu, _, Pf, Pu).

loop_successors([[U, [_, _, _], _, _]|Stail], Pf, Pu, Q, Pf_new, Pu_new):-
	belongs([U, [_, _, _], _, _], Q),
	loop_successors(Stail, Pf, Pu, Q, Pf_new, Pu_new).  

loop_successors([[U, [F, _, _], _, _]|Stail], Pf, Pu, Q, Pf_new, Pu_new):-
	not(belongs([U, [_, _, _], _, _], Q)),
	belongs([U, [F_pu, _, _], _, _], Pu),
	not(F < F_pu),
	loop_successors(Stail, Pf, Pu, Q, Pf_new, Pu_new).  

loop_successors([[U, [F, H, G], Pere, A]|Stail], Pf, Pu, Q, Pf_new, Pu_new):-
	not(belongs([U, [_, _, _], _, _], Q)),
	belongs([U, [F_pu, H_pu, G_pu], _, _], Pu),
	F < F_pu,
	suppress([U, [F_pu, H_pu, G_pu], _, _], Pu, Puapres),
	insert([U, [F, H, G], Pere, A], Puapres, Pulast),
	supress([[F_pu, H_pu, G_pu], U], Pf, Pfapres),
	insert([[F, H, G], U], Pfapres, Pflast),
	loop_successors(Stail, Pflast, Pulast, Q, Pf_new, Pu_new).

loop_successors([[U, [F, H, G], Pere, A]|Stail], Pf, Pu, Q, Pf_new, Pu_new):-
	not(belongs([U, [_, _, _], _, _], Q)),
	not(belongs([U, [_, _, _], _, _], Pu)),

	insert([[F, H, G], U], Pf, Pfapres),
	insert([U, [F, H, G], Pere, A], Pu, Puapres),
	loop_successors(Stail, Pfapres, Puapres, Q, Pf_new, Pu_new).


%*******************************************************************************
% Tests unitaires

