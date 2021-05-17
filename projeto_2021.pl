% Nome : Rodrigo Tavares Antunes ( 92553 )

% Importa codigo_comum.pl
:- [codigo_comum].

/*
    Codigo principal
*/
/*
combinacoes_soma/4 : em que N e um inteiro, Els e uma lista de inteiros,
e Soma e um inteiro, significa que Combs e a lista ordenada cujos elementos
sao as combinacoes N a N, dos elementos de Els cuja soma e Soma.
*/
combinacoes_soma(N, Els, Soma, Combs) :-
    findall(Comb, (combinacao(N, Els, Comb), soma_igual(Soma, Comb)), Combs).

/*
permutacoes_soma/4 : em que N e um inteiro, Els e uma lista de inteiros,
e Soma e um inteiro, significa que Perms e a lista ordenada cujos elementos
sao as permutacoes das combinacoes N a N, dos elementos de Els cuja soma e
Soma.
*/
permutacoes_soma(N, Els, Soma, Perms) :-
    combinacoes_soma(N, Els, Soma, Combs),
    permutacoes_soma(Combs, [], Perms).

permutacoes_soma([], Acumulator, Perms) :-
    msort(Acumulator, Perms).

permutacoes_soma([Comb | Tail], Acumulator, Perm) :-
    bagof(Ps, permutation(Comb, Ps), Perms),
    append(Acumulator, Perms, Acumulator_),
    permutacoes_soma(Tail, Acumulator_, Perm).

/*
espaco_fila/2 : em que Fila e uma fila (linha ou coluna) de um puzzle e
H_V e um dos atomos h ou v, conforme se trate de uma fila horizontal ou
vertical, respectivamente, significa que Esp e um espaco de Fila.
*/
espaco_fila(Fila, Esp, H_V) :-
    espaco_fila(Fila, 0, [], Esp, H_V).

% Caso Terminal: Nao existem espacos
espaco_fila([], _, [], [], _).

% Caso Terminal: Lista vazia
espaco_fila([], Soma, Vars, Espaco, _) :-
    length(Vars, L),
    L >= 1,
    Espaco = espaco(Soma, Vars).

% Caso Terminal : Encontra uma lista
espaco_fila([H | _], Soma, Vars, Espaco, _) :-
    is_list(H),
    contains_integer(H),
    length(Vars, L),
    L >= 1,
    Espaco = espaco(Soma, Vars).

% Caso v :
espaco_fila([H | T], _, _, Espaco, v) :-
    is_list(H),
    obtem_Sv(H, Soma),
    espaco_fila(T, Soma,[], Espaco, v).

% Caso h : 
espaco_fila([H | T], _, _, Espaco, h) :-
    is_list(H),
    obtem_Sh(H, Soma),
    espaco_fila(T, Soma,[], Espaco, h).

espaco_fila([H | T], Soma, Vars, Espaco, H_V) :-
    \+ is_list(H),
    append(Vars, [H], Vars_),
    espaco_fila(T, Soma, Vars_, Espaco, H_V).

/*
espacos_fila/2 : em que Fila e uma fila (linha ou coluna) de um puzzle e
H_V e um dos atomos h ou v, significa que Espacos e a lista de todos os
espacos de Fila, da esquerda para a direita.
*/
espacos_fila(H_V, Fila, Espacos) :-
    bagof(Esp, espaco_fila(Fila, Esp, H_V), Espacos_),
    flatten(Espacos_, Espacos).

/*
espacos_puzzle/2 : em que Puzzle e um puzzle, significa que Espacos e a
lista de espacos de Puzzle.
*/
espacos_puzzle(Puzzle, Espacos) :-
    espacos_puzzle(Puzzle, h, [], Puzzle_L),
    mat_transposta(Puzzle, Puzzle_),
    espacos_puzzle(Puzzle_, v, [], Puzzle_C),
    append(Puzzle_L, Puzzle_C, Espacos).

espacos_puzzle([], _, Esps, Esps).
espacos_puzzle([H | T], H_V, Acu, Esp) :-
    espacos_fila(H_V, H, Esps),
    append(Acu, Esps, Acu_),
    espacos_puzzle(T, H_V, Acu_, Esp).

/*
espacos_com_posicoes_comuns/3 : em que Espacos e uma lista de espacos e 
Esp e um espaco, significa que Esps_com e a lista de espacos com variaveis
em comum com Esp, exceptuando Esp, ordenadas pela mesma ordem representada
em Espacos.
*/
espacos_com_posicoes_comuns(Espacos, Esp, Esps_com) :-
    include(pos_comum(Esp), Espacos, Com),
    exclude(==(Esp), Com, Esps_com).

/*
permutacoes_soma_espacos/2 : em que Espacos e uma lista de espacos, 
significa que Perms_soma e a lista de listas de 2 elementos, em que o 1o
elemento e um espaco de Espacos e o 2o elemento e a lista ordenada de
permutacoes cuja soma e igual a soma do espaco.
*/
permutacoes_soma_espacos(Espacos, Perms_soma) :-
    permutacoes_soma_espacos(Espacos, [], Perms_soma).

permutacoes_soma_espacos([], Perms_soma, Perms_soma).
permutacoes_soma_espacos([H | T], Acu, Perms_soma) :-
    perm_espaco(H, Perms_esp),
    append(Acu, [Perms_esp], Acu_),
    permutacoes_soma_espacos(T, Acu_, Perms_soma).

/*
permutacao_possivel_espaco/4 : em que Perm e uma permutacao, Esp e um espaco,
Espacos e uma lista de espacos, e Perms_soma e uma lista de listas, significa
que Perm e uma permutacao possivel para o espaco Esp.
*/
permutacao_possivel_espaco(Perm, Esp, Espacos, Perms_soma) :-
    espacos_com_posicoes_comuns(Espacos, Esp, Esps_com),
    testa_perms(Esp, Esps_com, Perms_soma, Perm).

/*
permutacoes_possiveis_espaco/4 : em que Espacos e uma lista de espacos, 
Perms_soma e uma lista de listas, e Esp e um espaco, significa que Perms_poss
e uma lista de 2 elementos em que o primeiro e a lista de variaveis de Esp e
o segundo e a lista ordenada de permutacoes possiveis para o espaco Esp.
*/
permutacoes_possiveis_espaco(Espacos, Perms_soma, Esp, Perms_poss) :-
    findall(Perm, permutacao_possivel_espaco(Perm, Esp, Espacos, Perms_soma), Perms),
    permutacoes_possiveis_espaco_(Esp, Perms, Perms_poss).

permutacoes_possiveis_espaco_(espaco(_, Pos), Perms, [Pos, Perms]).

/*
permutacoes_possiveis_espacos/2 : em que Espacos e uma lista de espacos, 
significa que Perms_poss_esps e a lista de permutacoes possiveis.
*/
permutacoes_possiveis_espacos(Espacos, Perms_poss_esps) :-
    permutacoes_soma_espacos(Espacos, Perms_soma),
    maplist(permutacoes_possiveis_espaco(Espacos, Perms_soma), Espacos, Perms_poss_esps).

/*
numeros_comuns/2 : em que Lst_Perms e uma lista de permutacoes, significa que 
Numeros_comuns e uma lista de pares (pos, numero), significando que todas as 
listas de Lst_Perms contem o numero numero e posicao pos. 
*/
numeros_comuns(Lst_Perms, Numeros_comuns) :-
    mat_transposta(Lst_Perms, Num_por_indice),
    length(Num_por_indice, Ultimo_indice),
    numlist(1, Ultimo_indice, Indices),
    maplist(elementos_comuns, Indices, Num_por_indice, Numeros_comuns_),
    exclude(==([]), Numeros_comuns_, Numeros_comuns).

/*
atribui_comuns/1 : em que Perms_Possiveis e uma lista de permutacoes possiveis, 
actualiza esta lista atribuindo cada espaco numeros comuns a todas as permutacoes 
possiveis para esse espaco.
*/
atribui_comuns([]).
atribui_comuns([[Esp, Perms] | R]) :-
    numeros_comuns(Perms, Nums_coms),
    atribui_elementos(Nums_coms, Esp),
    atribui_comuns(R).

/*
retira_impossiveis/2 : em que Perms_Possiveis e uma lista de permutacoes possiveis,
significa que Novas_Perms_Possiveis e o resultado de tirar permutacoes impossiveis
de Perms_Possiveis.
*/
retira_impossiveis(Perms_Possiveis, Novas_Perms_Possiveis) :-
    retira_impossiveis_(Perms_Possiveis, [], Novas_Perms_Possiveis).

retira_impossiveis_([], Novas_Perms_Possiveis, Novas_Perms_Possiveis).
retira_impossiveis_([[Esp, Perms] | R], Acu, Novas_Perms_Possiveis) :-
    include(esp_unificavel(Esp), Perms, Novas_Perms),
    append(Acu, [[Esp, Novas_Perms]], Acu_),
    retira_impossiveis_(R, Acu_,Novas_Perms_Possiveis).

/*
simplifica/2 : em que Perms_Possiveis e uma lista de permutacoes possiveis, significa
que Novas_Perms_Possiveis e o resultado de simplificar Perms_Possiveis aplicando ha
mesma os predicados atribui_comuns/1 e retira_impossiveis/2 pela respetiva ordem 
sucessivamente ate nao apresentar alteracoes.
*/
simplifica(Perms_Possiveis, Novas_Perms_Possiveis) :-
    atribui_comuns(Perms_Possiveis),
    retira_impossiveis(Perms_Possiveis, Atualizadas_Perms_Possiveis),
    Perms_Possiveis \== Atualizadas_Perms_Possiveis, 
    !,
    simplifica(Atualizadas_Perms_Possiveis, Novas_Perms_Possiveis).
simplifica(Novas_Perms_Possiveis, Novas_Perms_Possiveis) :- atribui_comuns(Novas_Perms_Possiveis).

/*
inicializa/2 : em que Puzzle e um puzzle, significa que Perms_Possiveis e a lista de 
permutacoes possiveis simplificada para Puzzle.
*/
inicializa(Puzzle, Perms_Possiveis) :-
    espacos_puzzle(Puzzle, Espacos),
    permutacoes_possiveis_espacos(Espacos, Perms_Possiveis_),
    simplifica(Perms_Possiveis_, Perms_Possiveis).


/*
escolhe_menos_alternativas/2 : em que Perms_Possiveis e uma lista de permutacoes 
possiveis, significa que Escolha e o elemento de Perms_Possiveis escolhido segundo
criterios definidos. No caso de de todos os espacos em Perms_Possiveis estarem 
unificados devolve false.
*/
escolhe_menos_alternativas(Perms_Possiveis, Escolha) :-
    exclude(solucao_unica, Perms_Possiveis, Perms_Possiveis_),
    maplist(nth1(2), Perms_Possiveis_, Perms),
    maplist(length, Perms, Perms_lens),
    min_list(Perms_lens, Min_len),
    include(escolhe_min(Min_len), Perms_Possiveis_, Escolha_),
    nth1(1, Escolha_, Escolha).

/*
experimenta_perm/3 : em que Perms_Possiveis e uma lista de permutacoes possiveis, e 
Escolha e um dos seus elementos. Novas_Perms_Possiveis e o resultado de unificar o 
elemento Escolha em Perms_Possiveis.
*/
experimenta_perm(Escolha, Perms_Possiveis, Novas_Perms_Possiveis) :-
    maplist(atribui_escolha(Escolha), Perms_Possiveis, Novas_Perms_Possiveis).

/*
resolve_aux/2 : em que Perms_Possiveis e uma lista de permutacoes possiveis, significa 
que Novas_Perms_Possiveis e o resultado de aplicar os predicados 
escolhe_menos_alternativas/2, experimenta_perm/3 e simplifica/2 pela respetiva ordem 
sucessivamente ate nao apresentar alteracoes.
*/
resolve_aux(Perms_Possiveis, Novas_Perms_Possiveis) :-
    escolhe_menos_alternativas(Perms_Possiveis, Escolha),
    !,
    experimenta_perm(Escolha, Perms_Possiveis, Perms_Possiveis_),
    simplifica(Perms_Possiveis_, Perms_Pos_Simplificadas),
    resolve_aux(Perms_Pos_Simplificadas, Novas_Perms_Possiveis).

resolve_aux(Novas_Perms_Possiveis, Novas_Perms_Possiveis).

/*
resolve/1 : em que Puz e um puzzle, resolve esse puzzle, isto e, apos a invocao deste 
predicado a grelha de Puz tem todas as variaveis substituidas por numeros que respeitam 
as restricoes Puz.
*/
resolve(Puz) :-
    inicializa(Puz, Perms_Possiveis),
    resolve_aux(Perms_Possiveis, _).



/*  
    Codigo auxiliar
*/
%   combinacoes_soma/4 :
/*
soma_elem/2 : em que Comb e uma lista de inteiros e Soma e a Soma de todos 
os elementos de Comb.
*/
soma_elem(Comb, Soma) :-
    soma_elem(Comb, 0, Soma).

soma_elem([], Soma, Soma).
soma_elem([Elem | R], Acu, Soma) :-
    Acu_ is Acu + Elem,
    soma_elem(R, Acu_, Soma).

/*
soma_igual/2 : em que Soma e um inteiro e Comb e uma lista de inteiros.
Devolve true se a soma de todos os elementos de Comb for igual a Soma.
*/
soma_igual(Soma, Comb) :-
    soma_elem(Comb, Soma_),
    Soma_ == Soma.



%   espaco_fila/2 :
/*
obtem_Sv/2 : em que Somas e uma lista de inteiros e Sv e um inteiro que 
representa a soma de um espaco vertical.
*/
obtem_Sv(Somas, Sv) :-
    nth0(0, Somas, Sv).
    
/*
obtem_Sh/2 : em que Somas e uma lista de inteiros e Sh e um inteiro que 
representa a soma de um espaco horizontal.
*/
obtem_Sh(Somas, Sh) :-
    nth0(1, Somas, Sh).

/*
contains_integer/2 : Retorna true se o primeiro elemento de uma dada 
lista for do tipo inteiro.
*/
contains_integer([Elem |_]) :-
    integer(Elem).



%   espacos_com_posicoes_comuns/3 :
/*
pos_comum/2 : Recebe dois espacos. Devolve true se os dois partilharem uma 
variavel em comum.
*/
pos_comum(espaco(_, [Var | _]), Esp) :- 
    membro_esp(Var, Esp), 
    !.
pos_comum(espaco(_, [_ | R]), Esp) :- 
    pos_comum(espaco(_, R), Esp).

/*
membro_esp/2 : Verifica se Elem e membro do espaco dado.
*/
membro_esp(Elem, espaco(_, [Var | _])) :- Elem == Var.

membro_esp(Elem, espaco(_, [_ | R])) :- membro_esp(Elem, espaco(_, R)).



%   permutacoes_soma_espacos/2 :
/*
perm_espaco/2 : Predicado auxiliar a permutacoes_soma_espacos/2, recebe um
dado espaco e devolve Esp_perm que e uma lista em que o 1o elemento e o 
espaco dado e o 2o elemento e a lista ordenada de permutacoes para o espaco 
dado.
*/
perm_espaco((espaco(Soma, Pos)), Esp_perm) :-
    length(Pos, Len),
    permutacoes_soma(Len, [1, 2, 3, 4, 5, 6 ,7 ,8 ,9], Soma, Perms),
    append([espaco(Soma, Pos)], [Perms], Esp_perm).



%   permutacao_possivel_espaco/4 :
/*
testa_espacos/4 : Perdicado auxiliar a permutacao_possivel_espaco/4, em que 
Esp e um espaco, Esps_com e uma lista de espacos com posicoes comuns a Esp, 
Perms_soma e uma lista de listas, significa que Perm e uma permutacao possivel 
para o espaco espaco.
*/
testa_perms(Esp, Esps_com, Perms_soma, Perm) :-
    encontra_perm_esp(Esp, Perms_soma, Perm_esp),
    encontra_perm_esps(Esps_com, Perms_soma, Perm_com),
    verifica_perms(Esp, Perm_esp, Perm_com, Perm).

/*
verifica_perms/2 : em que Esp e um espaco, Perms_comuns e uma lista de 
permutacoes de espacos comuns a Esp e Perm e uma permotacao valida para o 
espaco Esp.
*/
verifica_perms(Esp,[Perm | _], Perms_comuns, Perm) :-
    esp_unificavel(Esp, Perm),
    verifica_perm(Perm, Perms_comuns).
verifica_perms(Esp, [_ | R], Perms_comuns, Perm) :- 
    verifica_perms(Esp, R, Perms_comuns, Perm).

/*
esp_unificavel/2 : verifica se a permutacao Perm e unificavel com o espaco 
escolhido.
*/
esp_unificavel(espaco(_, Vars), Perm) :-
    unifiable(Vars, Perm, _).
esp_unificavel(Vars, Perm) :-
    unifiable(Vars, Perm, _).


/*
verifica_perm/2 : predicado auxiliar a verifica_perms/2 que se uma 
permutacao dada de um respetivo espaco e compativel com todos os espacos 
comuns desse mesmo espaco.
*/
verifica_perm([], []).
verifica_perm([Elem | R], [X | Y]) :-
    flatten(X, X_),
    memberchk(Elem, X_),
    verifica_perm(R, Y).

/*
encontra_perm_esps/2 : em que Espacos e uma lista de espacos e Perms_soma e 
uma lista de listas, significa que Perms e a lista de todas as permotacoes 
pertencentes ao espaco Esp.
*/
encontra_perm_esps(Esps, Perms_soma, Perms) :-
    encontra_perm_esps(Esps, Perms_soma, [], Perms).

encontra_perm_esps([], _, Perms, Perms).
encontra_perm_esps([Esp | R], Perms_soma, Acu, Perms) :-
    encontra_perm_esp(Esp, Perms_soma, Perm),
    append(Acu, [Perm], Acu_),
    encontra_perm_esps(R, Perms_soma, Acu_, Perms).

encontra_perm_esp(_, [], _) :- fail.
encontra_perm_esp(Esp, [[Esp | [Perm]] | _], Perm) :- !.
encontra_perm_esp(Esp, [[_ | _] | R], Perm) :-
    encontra_perm_esp(Esp, R, Perm).



%   numeros_comuns/2 :
/*
elementos_comuns/3 : em que Elems e uma lista de inteiros, Indice e o inteiro, 
significa que no caso de todos os elementos de Elems serem iguais e returnado
o par (Indice, Elem) que e do tipo (pos, numero).
*/
elementos_comuns(Indice, Elems, (Indice, Elem)) :-
    sort(Elems, [_]),
    !,
    last(Elems, Elem).

elementos_comuns(_, _, []).



%   atribui_comuns/1 :
/*
atribui_elementos/2 : Recebe uma lista de pares (pos, numero) e Esp que e um espaco.
Este predicado vai atribuir ao espaco Esp os numeros comuns nas suas respetivas posicoes.
*/
atribui_elementos([], _).
atribui_elementos([(Indice, Num) | R], Esp) :-
    nth1(Indice, Esp, Var),
    Var = Num,
    atribui_elementos(R, Esp).



%   escolhe_menos_alternativas/2 :
/*
solucao_unica/1 : Verifica se Perms tem apenas uma permutacao possivel, em que Perms 
e uma lista de permutacoes possiveis.
*/
solucao_unica([_, Perms]) :-
    length(Perms, 1).

/*
escolhe_min/2 : Verifica se uma permutacao tem um tamanho correspondente a N, em que
Perms e uma lista de permutacoes possiveis e N e um inteiro.
*/
escolhe_min(Min, [_, Perms]) :-
    length(Perms, Min).



%   experimenta_perm/3 :
/*
atribui_escolha/3 : Predicado auxiliar a experimenta_perm/3, recebe Escolha que e 
um espaco e Perm_Possivel que e um espaco e as seus repsetivos permutacoes. No caso 
do espaco de Escolha e de Perm_Possivel for igual entao uma das peemutacoes de 
escolha e escolhida e unificada com o respetivo espaco, o resultado desta operacao e 
devolvido como uma lista em que o 1o elemento e o espaco e o 2o elemento e uma lista 
coma a permutacao unificada com o espaco.
 */
atribui_escolha([Esp, Perms], Perm_Possivel, [Esp, [Perm]]) :-
    Perm_Possivel == [Esp, Perms],
    !,
    member(Perm, Perms),
    Esp = Perm.
atribui_escolha(_, Perm_Possivel, Perm_Possivel).