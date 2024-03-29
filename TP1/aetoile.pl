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
:- lib(swi).
:- lib(util).

%*******************************************************************************

main :-
	% initialisations Pf, Pu et Q 

    S0 = [ [e, f, g],
                [d,vide,h],
                [c, b, a]  ],
    
	initial_state(S0),

    Final = [[a, b,  c],
             [h,vide, d],
             [g, f,  e]], 

    final_state(Final),

    heuristique2(S0, H0, Final),
    G0 is 0,
    F0 is H0 + G0,
    
    empty(Pf),
    empty(Pu),
    empty(Q),
    
    insert([[F0,H0,G0], S0], Pf, NewPf),
    insert([S0, [F0, H0, G0], nil, nil], Pu, NewPu),
    
    aetoile(NewPf, NewPu, Q, Final).

    % Calculer F0, H0, G0
    
    % Creer AVL Pf, Pu et Q, vide � la base
   
    % Inserer [[F0,H0,G0], S0] dans Pf
    % Inserer [S0, [F0, H0, G0, nil, nil]] dans Pu
    % Appeler aetoile sur Pf, Pu et Q
    
    %Comment marche Pu et Pf
    
    % Pf sont ordonn�s par valeurs F puis H croissantes
    % Minimal est le plus � gauuche dans l'arbre
    % -> EX: [[4,4,0],[[b,h,c],[a,f,d],[g,vide,e]]] pour U0 .
    % Strucuture : [[F,H,G], U]
    
    % Pu sont ordonn�s lexicogaphiquement 
    % (Pour m�moriser les �tats non d�velopp�s, et mettre � jours chemin)
    % -> Ex :[[[b,h,c],[a,f,d],[g,vide,e]], [4,4,0], nil, nil] pour U0.
    % Structure : [U, [F,H,G], Pere, A]
    
    % Q pour m�moriser les �tats d�velopp�s
	% Structure : [Etat, FHG ,Pere,Action]
    
    



%*******************************************************************************
affiche_solution(_,nil).
affiche_solution(Q, Etat) :-
    belongs([Etat, _, Pere, Action], Q),
    affiche_solution(Q ,Pere),
    (Action = nil ->  
    	writeln("Situation initiale:"),
        write_state(Etat),
        writeln("")
        ;   
    writeln(Action),
    write_state(Etat),
    writeln("")).

expand([[_F,_H,G],P],Successors,Final) :-
	findall([Etat,[Fs,Hs,Gs],P, A],(rule(A,Cout,P,Etat),
				     heuristique2(Etat,Hs,Final),
				     Gs is G + Cout,
				     Fs is Hs + Gs), Successors).

loop_a_successor([Succ, FHG_Succ, Pere, Action], Pu, Pf, Q, AuxPu, AuxPf):-
    (belongs([Succ,_,_,_] , Q) -> 
    	AuxPf = Pf,
        AuxPu = Pu;
  	((suppress([Succ, FHG, _, _], Pu, SuprPu)), suppress_min([FHG, Succ], Pf, SuprPf))  ->
    	(FHG_Succ @< FHG ->  
        	insert([Succ, FHG_Succ, Pere, Action], SuprPu, AuxPu),
            insert([FHG_Succ, Succ], SuprPf, AuxPf)
        ;   
        	AuxPf = Pf,
        	AuxPu = Pu
    	);
    insert([Succ, FHG_Succ, Pere, Action],Pu, AuxPu),
    insert([FHG_Succ, Succ],Pf, AuxPf)
	).

% Si dans Q, oublier
% Si dans Pu, garder la meilleur evaluation dans Pu et Pf
% Si pas pr�sents inserer dans Pu et Pf
loop_successors([], Pu, Pf, Q, Pu, Pf).
loop_successors([Succ|Rest], Pu, Pf, Q, NewPu, NewPf) :-
    loop_a_successor(Succ, Pu, Pf, Q, AuxPu, AuxPf),
	loop_successors(Rest, AuxPu, AuxPf, Q, NewPu, NewPf).


aetoile([],[],_,_):-
    writeln("PAS DE SOLUTION ! L'ETAT FINAL N'EST PAS ATTEIGNABLE !").
% Pf et Pu  vides -> pas de solution

aetoile(Pf, Ps, Q, Final) :- 
    suppress_min([[_,_,G],U], Pf, SuprPf),
    % Si Situation Terminal, alors solution

    /*
    write("\nPf:  "),
    put_flat(Pf),
    write("\nPs:  "),
    put_flat(Ps),
    write("\nQ:  "),
    put_flat(Q),
    */

    (U = Final ->  
        writeln("\n ------- Solution trouvé -------"),
        suppress([U,FHG,P,A],Ps,_),
		insert([U,FHG,P,A], Q, NewQ),
    	affiche_solution(NewQ, U)
    ; 
    % Sinon, on explore
    	% On enleve de Pf le noeuds � developper (F min) et son noeud frere dans Pu
    	suppress([U,FHG,P,A], Ps, SuprPs),

        % Trouver les succeseurs et evaluer [Fs, Hs, Gs] 
        expand([[_,_,G],U], Succs, Final),

        % Traiter les noeuds successeur
        loop_successors(Succs, SuprPs, SuprPf, Q, NewPs, NewPf),

        % Inserer [U, Val, Pere, A?] dans Q
        insert([U,FHG, P, A], Q, NewQ),

        % Appeler recursivement aetoile (Pf_new,Pu_new,Q_new)
        aetoile(NewPf, NewPs, NewQ, Final)
     ).
    
% Test Valid�
test_affiche_solution:-
    empty(Test0),
	insert([[[ a, b, c],
            [ g, h, d],
            [vide,f, e]], 
           		[3,3,0],
      		[[ a, b, c],
    		[ vide, h, d],
   		 	[g,f, e]], 
           		down], Test0, Test1),
    
    insert([[[ a, b, c],
    		[ vide, h, d],
   		 	[g,f, e]], 
           		[3,1,2],
      		[[ vide, b, c],
    		[ a, h, d],
    		[g,f, e]],
           		down], Test1, Test2),
    
    insert([[[ vide, b, c],
    		[ a, h, d],
            [g,f, e]], 
            	[3,0,3], nil, nil], Test2, TestQ),
    
    affiche_solution(TestQ, 
            [[ a, b, c],
            [ g, h, d],
            [vide,f, e]] ).
    
    /* Fils into Pere
	[[ a, b, c],
    [ g, h, d],
    [vide,f, e]]
	
    [[ a, b, c],
    [ vide, h, d],
    [g,f, e]]
    
    [[ vide, b, c],
    [ a, h, d],
    [g,f, e]]
    
    */
    
%test_loop_successors([[Succ, FHG_Succ, Pere, Action]|Rest], Pu, Pf, Q, NewPu, NewPf) :-

test_successor_in_Q:- 
 	% Un successeur dans Q
    empty(EmptyPf),
    empty(EmptyPu),
    empty(EmptyQ),

    insert([[[ b, vide, c], % Nouvel Etat
          	[ a, h, d],
          	[g,f, e]], 
      	[3,1,2],
          	[[ vide, b, c],
          	[ a, h, d],
        	[g,f, e]],
           	right], EmptyQ, Q),

      loop_a_successor([[[ b, vide, c], % Nouvel Etat
                      [ a, h, d],
                      [g,f, e]], 
                  [3,1,2],
                      [[ vide, b, c],
                      [ a, h, d],
                      [g,f, e]],
                  right], EmptyPu, EmptyPf, Q, EmptyPu, EmptyPf).
      % Pu et Pf doivent rester inchangés


test_successor_known:-
    % Successeur dans Pu, et mettre à jour si mieux
	empty(EmptyPf),
    empty(EmptyPu),
    empty(EmptyQ),
    
    % Insère Element pas optimal dans Pu et Pf
    insert([[[ a, b, c],
    	   	[ vide, h, d],
           	[g,f, e]], 
		[3,1,2],
        	[[ vide, b, c],
            [ a, h, d],
            [g,f, e]],
      	down], EmptyPu, Pu),

	insert([[3,1,2],
    		[[ a, b, c],
            [ vide, h, d],
            [g,f, e]]], EmptyPf, Pf),

    empty(Pf_Result),
    empty(Pu_Result),

    % Pu souhaité avec même état mais optimal
    insert([[[ a, b, c],
            [ vide, h, d],
            [g,f, e]], 
        [2,1,1],
            [[ vide, b, c],
            [ a, h, d],
            [g,f, e]],
        down], Pu_Result, Pu_R),
	% Pf souhaité avec même état mais optimal
    insert([[2,1,1], [[ a, b, c],
                    [ vide, h, d],
                    [g,f, e]]], Pf_Result, Pf_R),

    
    loop_a_successor([[[ a, b, c],
                    [ vide, h, d],
                    [g,f, e]], 
                [2,1,1],
                    [[ vide, b, c],
                    [ a, h, d],
                    [g,f, e]],
                down], Pu, Pf, EmptyQ, Pu_R, Pf_R).
    % Résultat sont Pu_R et Pf_R
    
test_successor_unknown:-
    % Successeur pas connu
    empty(EmptyPu),
    empty(EmptyPf),
    empty(EmptyQ),
    
    insert([[[ b, vide, c],
    		[ a, h, d],
            [g,f, e]], 
     	[2,1,1],
            [[ vide, b, c],
            [ a, h, d],
            [g,f, e]],
        right], EmptyPu, Pu),

	insert([[2,1,1], 
           [[ b, vide, c],
           [ a, h, d],
           [g,f, e]]], EmptyPf, Pf),

   loop_a_successor([[[ b, vide, c],
                      [ a, h, d],
                      [g,f, e]], 
               	[2,1,1],
                      [[ vide, b, c],
                      [ a, h, d],
                      [g,f, e]], 
                right], 
                EmptyPu, EmptyPf, EmptyQ, Pu, Pf).

test_expand:-
    final_state(Final),

    expand([[_,_, 0], [[b, c, e],
        		[a,vide,g],
            	[f, h, d]]],
    PutList, Final),

    write(PutList).

test_time :-
    time(main).