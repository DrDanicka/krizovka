krizovka(VelkostKrizovky) :-
    najdi_krizovku(VelkostKrizovky).

najdi_krizovku(VelkostKrizovky, Plocha) :- 
    vytvor_plochu_krizovky(VelkostKrizovky, Plocha).

prazdne_okienko(Okienko, Okienko-prazdne).

% Vytvori plochu krizovky
vytvor_plochu_krizovky(VelkostKrizovky, Plocha) :- 
    PocetOkienok is VelkostKrizovky * VelkostKrizovky,
    numlist(1, PocetOkienok, Okienka),
    maplist(prazdne_okienko, Okienka, DvojiceOkienok),
    list_to_assoc(DvojiceOkienok, Plocha).


prirad_slova([], PouziteSlova, _, _, _, Plocha, Plocha, PouziteSlova).

prirad_slova(Slova, PouziteSlovaIn, VelkostKrizovky, Cislo, Smer, PlochaIn, PlochaOut, PouziteSlovaOut) :- 
    member([Slovo, Napoveda], Slova),
    atom_chars(Slovo, ListPismen),
    length(ListPismen, DlzkaListuPismen),
    najdi_pretinajuce_slova(ListPismen, DlzkaListuPismen, PouziteSlovaIn, VelkostKrizovky, Cislo, Smer),
    % TODO assign_words

% Base case pouzije zacinajuce slovo ak sme na zaciatku
najdi_pretinajuce_slova(_, _, [], _, _, _).

najdi_pretinajuce_slova(ListPismen, DlzkaListuPismen, PouziteSlova, VelkostKrizovky, Cislo, Smer) :-
    memebr([_, _, _, PouzityListPismen, _, PouzitySmer, _, PouziteCislo, _], PouziteSlova),
    intersection(ListPismen, PouzityListPismen, Prienik),
    list_to_set(Prienik, PrienikMnozina),
    member(Pismeno, PrienikMnozina),
    pozicie(Pismeno, PouzityListPismen, PouzitePozicie),
    pozicie(Pismeno, ListPismen, Pozicie),





% Najde vsetky pozicie X v Liste pomocou backtrackingu
pozicie(X, List, Pozicie) :- pozicie_backtrack(List, X, 1, Pozicie).

pozicie_backtrack([], _, _, _) :- false.
pozicie_backtrack([X|_], X, Pos, Pos).
pozicie_backtrack([_|Ys], X, N, Pos) :-
    N2 is N + 1,
    pozicie_backtrack(Ys, X, N2, Pos).