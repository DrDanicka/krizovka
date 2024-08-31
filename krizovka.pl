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
    vymaz([Slovo, Napoveda], Slova, PremazaneSlova),
    prirad_slova(PremazaneSlova, [PolozeneSlovo|PolozeneSlova], ZvysnePozicie, VyskaKrizovky, SirkaKrizovky, VytvorenaPlocha, VystupnyGrid, PolozeneSlovaOut).

% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat zapise pismena na plochu krizovky
prirad_pismena([], _, _, [], G, G).

prirad_pismena([Pismeno|ZvysokPismen], Smer, Dlzka, [Okienko|ZvysokOkienok], VstupnyGrid, VystupnyGrid):-
    get_assoc(Okienko, VstupnyGrid, X),
    (
    % AK tam je rovnake pismeno tak parada
    X == Pismeno,
    VytvorenaPlocha = VstupnyGrid
    ;
    % Ak tam je prazdne, tak to tam pridam
    X == empty,
    put_assoc(Okienko, VstupnyGrid, Pismeno, VytvorenaPlocha)
    ), !, 
    prirad_pismena(ZvysokPismen, Smer, Dlzka, ZvysokOkienok, VytvorenaPlocha, VystupnyGrid).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat, ktory podla Zaciatocneho okienka a Smeru priradi Slovo na plochu krizovky
prirad_slovo(Slovo, ListPismen, DlzkaSlova, Napoveda, OkienkoZaciatku, Smer, VyskaKrizovky, SirkaKrizovky, VstupnyGrid, VystupnyGrid, PolozeneSlovo) :-
    get_cisla_okienok_pre_slovo(DlzkaSlova, OkienkoZaciatku, Smer, Okienka, VyskaKrizovky, SirkaKrizovky),
    prirad_pismena(ListPismen, Smer, DlzkaSlova, Okienka, VstupnyGrid, VystupnyGrid),
    Okienka = [PrveOkienko|_],
    ( Smer = doprava ->
        NewPrveOkienkoZeroBased is PrveOkienko // SirkaKrizovky,  % Divide PrveOkienko by SirkaKrizovky if Smer is 'dole'
        NewPrveOkienko is NewPrveOkienkoZeroBased + 1
    ; 
        NewPrveOkienko = PrveOkienko  % Otherwise, keep PrveOkienko as is
    ),
    PolozeneSlovo = [Smer, NewPrveOkienko, Napoveda].  % Use the new or unchanged value of PrveOkienko
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat vygeneruje pozicie na ploche
% Base case for generating the first row, with skipping logic
generate_first_row(0, _, _, _, []) :- !.
generate_first_row(N, GridWidth, GridHeight, SkipPos, [Pos-dole|Rest]) :-
    N > 0,
    Pos is GridWidth - N + 1,
    Pos \= SkipPos,  % Skip the position if it matches SkipPos
    N1 is N - 1,
    generate_first_row(N1, GridWidth, GridHeight, SkipPos, Rest).
generate_first_row(N, GridWidth, GridHeight, SkipPos, Rest) :-
    N > 0,
    Pos is GridWidth - N + 1,
    Pos = SkipPos,  % If the position matches SkipPos, skip it
    N1 is N - 1,
    generate_first_row(N1, GridWidth, GridHeight, SkipPos, Rest).

% Base case for generating the first column, with skipping logic
generate_first_column(_, _, 0, _, []) :- !.
generate_first_column(GridWidth, GridHeight, N, SkipPos, [Pos-doprava|Rest]) :-
    N > 0,
    Pos is (N - 1) * GridWidth + 1,
    Pos \= SkipPos,  % Skip the position if it matches SkipPos
    N1 is N - 1,
    generate_first_column(GridWidth, GridHeight, N1, SkipPos, Rest).
generate_first_column(GridWidth, GridHeight, N, SkipPos, Rest) :-
    N > 0,
    Pos is (N - 1) * GridWidth + 1,
    Pos = SkipPos,  % If the position matches SkipPos, skip it
    N1 is N - 1,
    generate_first_column(GridWidth, GridHeight, N1, SkipPos, Rest).

vytvor_pozicie(GridWidth, GridHeight, SkipPos, Result) :-
    generate_first_row(GridWidth, GridWidth, GridHeight, SkipPos, FirstRow),
    generate_first_column(GridWidth, GridHeight, GridHeight, SkipPos, FirstColumn),
    append(FirstRow, FirstColumn, Result), !.

% ----------------------------------------------------------------

% vymaz(X,L,R) :- R je L s vymazanym prvym X
vymaz(Y,[X|Xs],[X|Tail]) :-
	Y \== X,
	vymaz(Y,Xs,Tail).
vymaz(X,[X|Xs],Xs) :- !.
vymaz(_,[],[]).