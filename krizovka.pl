% Hlavny predikat krizovka
krizovka(Slovnik, Tajanka, TajankaSmer, VyskaKrizovky, SirkaKrizovky) :- 
    najdi_krizovku(Slovnik, Tajanka, TajankaSmer, VyskaKrizovky, SirkaKrizovky, PolozeneSlova, _),
    vypis_plochu(VyskaKrizovky, SirkaKrizovky),
    write('\n\n'),
    vypis_poziciu_tajanky(VyskaKrizovky, SirkaKrizovky, TajankaSmer),
    write('\n\n'),
    vypis_napovedy(PolozeneSlova), !.

najdi_krizovku(Slovnik, Tajanka, TajankaSmer, VyskaKrizovky, SirkaKrizovky, PolozeneSlova, Grid) :-
    % Vytvorime si plochu krizovky
    vytvor_plochu(VyskaKrizovky, SirkaKrizovky, VytvorenaPlocha),

    % Dostanem cislo Okienka, kde chceme aby zacinala nasa Tajanka
    vrat_okienko_tajanky(VyskaKrizovky, SirkaKrizovky, TajankaSmer, OkienkoTajanky), % OkienkoTajanky je okienko, kde zacina tajanka
    
    % Vlozime Tajanku do krizovky
    prirad_tajanku(Tajanka, TajankaSmer, OkienkoTajanky, VyskaKrizovky, SirkaKrizovky, VytvorenaPlocha, PlochaSTajankou),

    % Vygeneruje pozicie, kde budeme chciet umiestnit nase slova okrem Tajanky
    % Pozicie su list: [Okienko-Smer, ...] -> napr [1-dole, 2-dole, 1-doprava, 3-doprava]
    vytvor_pozicie(SirkaKrizovky, VyskaKrizovky, OkienkoTajanky, Pozicie),

    % Prirad slova zo slovnika do krizovky
    prirad_slova(Slovnik, [], Pozicie, VyskaKrizovky, SirkaKrizovky, PlochaSTajankou, Grid, PolozeneSlova).


% ----------------------------------------------------------------
% Predikat prirad_slova, sa pokusi vlozit slova zo slovniku na plochu krizovky
prirad_slova(_, PolozeneSlova, [], _, _, G, G, PolozeneSlova).

prirad_slova(Slova, PolozeneSlova, [Pozicia|ZvysnePozicie], VyskaKrizovky, SirkaKrizovky, VstupnyGrid, VystupnyGrid, PolozeneSlovaOut) :-
    member([Slovo, Napoveda], Slova),
    atom_chars(Slovo, ListPismen),
    length(ListPismen, DlzkaSlova),
    Pozicia = Okienko-Smer,
    prirad_slovo(Slovo, ListPismen, DlzkaSlova, Napoveda, Okienko, Smer, VyskaKrizovky, SirkaKrizovky, VstupnyGrid, VytvorenaPlocha, PolozeneSlovo),
    remove_x([Slovo, Napoveda], Slova, PremazaneSlova),
    prirad_slova(PremazaneSlova, [PolozeneSlovo|PolozeneSlova], ZvysnePozicie, VyskaKrizovky, SirkaKrizovky, VytvorenaPlocha, VystupnyGrid, PolozeneSlovaOut).

% ----------------------------------------------------------------
% Base case pouzije zacinajuce slovo ak sme na zaciatku
najdi_pretinajuce_slova(_, _, [], _, _, _).


najdi_pretinajuce_slova(ListPismen, DlzkaListuPismen, PouziteSlova, VelkostKrizovky, OkienkoNaPloche, Smer) :-
    memebr([_, _, PouzityListPismen, _, PouzitySmer, _, PouziteOkienkoNaPloche, _], PouziteSlova),
    intersection(ListPismen, PouzityListPismen, Prienik),
    list_to_set(Prienik, PrienikMnozina),
    member(Pismeno, PrienikMnozina),
    pozicie(Pismeno, PouzityListPismen, PouzitePozicie),
    pozicie(Pismeno, ListPismen, Pozicie),
    pozicia_na_ploche(VelkostKrizovky, PouzitySmer, PouziteOkienkoNaPloche, PouzitePozicie, OkienkoPrieniku),
    opacne_smery(PouzitySmer, Smer),
    pozicia_zaciatku_na_ploche(Smer, VelkostKrizovky, Pozicie, OkienkoPrieniku, Zaciatok),
    je_na_ploche(Smer, Zaciatok, DlzkaListuPismen, VelkostKrizovky).


prirad_slovo(Slovo, ListPismen, DlzkaSlova, Napoveda, Zaciatok, Smer, VelkostKrizovky, PlochaIn, PolozeneSlovo, PlochaOut) :-
    % TODO kontrola, ze pred okienkom nic nie je
    prirad_pismena(ListPismen, Zaciatok, Smer, VelkostKrizovky, Okienka, PlochaIn, PlochaOut),
    PolozeneSlovo = [Slovo, Napoveda, ListPismen, Okienka, Smer, DlzkaSlova, Zaciatok, _CisloNapovedy].


opacne_smery(doprava, dole).
opacne_smery(dole, doprava).


% Vypocita okienko na ploche pismena prieniku
pozicia_na_ploche(VelkostKrizovky, doprava, WPos, WStart, Pozicia) :-
    Pozicia is  WStart + (WPos - 1).
pozicia_na_ploche(VelkostKrizovky, dole, WPos, WStart, Pozicia) :-
    Pozicia is  WStart + (VelkostKrizovky * (WPos - 1)).


% Vypocita okienko na ploche zaciatku slova
pozicia_zaciatku_na_ploche(VelkostKrizovky, doprava, PPos, WNum, Zaciatok) :-
    Zaciatok is WNum - (PPos - 1).
pozicia_zaciatku_na_ploche(VelkostKrizovky, dole, PPos, WNum, Zaciatok) :-
    Zaciatok is WNum - (VelkostKrizovky * (PPos - 1)).


% Najde vsetky pozicie X v Liste pomocou backtrackingu
pozicie(X, List, Pozicie) :- pozicie_backtrack(List, X, 1, Pozicie).
pozicie_backtrack([], _, _, _) :- false.
pozicie_backtrack([X|_], X, Pos, Pos).
pozicie_backtrack([_|Ys], X, N, Pos) :-
    N2 is N + 1,
    pozicie_backtrack(Ys, X, N2, Pos).


% Kontrola, ci sa slovo zmensti do riadka
je_na_ploche(doprava, Zaciatok, DlzkaSlova, VelkostKrizovky) :- 
    M is Zaciatok mod VelkostKrizovky,
    M \== 0,
    Medzera is VelkostKrizovky - (M - 1),
    DlzkaSlova =< Medzera.

% Kontrola, ci sa slovo zmensti do stlpca
je_na_ploche(dole, Zaciatok, DlzkaSlova, VelkostKrizovky) :- 
     Koniec is Zaciatok + (VelkostKrizovky * (DlzkaSlova - 1)),
     Koniec =< VelkostKrizovky * VelkostKrizovky.


% vymaz(X,L,R) :- R je L s vymazanym prvym X
vymaz(Y,[X|Xs],[X|Tail]) :-
	Y \== X,
	vymaz(Y,Xs,Tail).
vymaz(X,[X|Xs],Xs) :- !.
vymaz(_,[],[]).