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
    % Okienka krizovky cislujeme od 0 do (VyskaKrizovky * SirkaKrizovky - 1)
    vytvor_plochu(VyskaKrizovky, SirkaKrizovky, VytvorenaPlocha),

    % Dostanem cislo Okienka, kde chceme aby zacinala nasa tajanka
    vrat_okienko_tajanky(VyskaKrizovky, SirkaKrizovky, TajankaSmer, OkienkoTajanky), % OkienkoTajanky je okienko, kde zacina tajanka
    
    % Vlozime tajanku do krizovky
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
    
    % Ak slovo nedosahuje az na okraj plochy krizovky, tak pridaj medzi pozicie nove 2 pozicie od konca slova
    ( vrat_okienko_za_koncom(DlzkaSlova, Okienko, Smer, VyskaKrizovky, SirkaKrizovky, OkienkoZaKoncom) ->
        NovaPozicia = OkienkoZaKoncom-Smer,
        ZvysnePoziciePridane = [NovaPozicia|ZvysnePozicie]
    ;
        ZvysnePoziciePridane = ZvysnePozicie 
    ),

    vymaz([Slovo, Napoveda], Slova, PremazaneSlova),
    prirad_slova(PremazaneSlova, [PolozeneSlovo|PolozeneSlova], ZvysnePoziciePridane, VyskaKrizovky, SirkaKrizovky, VytvorenaPlocha, VystupnyGrid, PolozeneSlovaOut).

% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat zapise pismena na plochu krizovky
prirad_pismena([], _, _, [], G, G).

prirad_pismena([Pismeno|ZvysokPismen], Smer, Dlzka, [Okienko|ZvysokOkienok], VstupnyGrid, VystupnyGrid):-
    get_assoc(Okienko, VstupnyGrid, X),
    (
    % AK tam je rovnake pismeno, tak parada
    X == Pismeno,
    VytvorenaPlocha = VstupnyGrid
    ;
    % Ak tam je prazdne, tak to tam pridam
    X == prazdne,
    put_assoc(Okienko, VstupnyGrid, Pismeno, VytvorenaPlocha)
    ), !, 
    prirad_pismena(ZvysokPismen, Smer, Dlzka, ZvysokOkienok, VytvorenaPlocha, VystupnyGrid).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat, ktory podla Zaciatocneho okienka a Smeru priradi Slovo na plochu krizovky
prirad_slovo(Slovo, ListPismen, DlzkaSlova, Napoveda, OkienkoZaciatku, Smer, VyskaKrizovky, SirkaKrizovky, VstupnyGrid, VystupnyGrid, PolozeneSlovo) :-
    vrat_cisla_okienok_pre_slovo(DlzkaSlova, OkienkoZaciatku, Smer, Okienka, VyskaKrizovky, SirkaKrizovky),
    prirad_pismena(ListPismen, Smer, DlzkaSlova, Okienka, VstupnyGrid, VystupnyGrid),
    Okienka = [ZaciatocneOkienko|_],
    PolozeneSlovo = [Smer, ZaciatocneOkienko, Napoveda].
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat vygeneruje pozicie na ploche
% Base case for generating the first row, with skipping logic
generate_first_row(0, _, _, _, []) :- !.
generate_first_row(N, GridWidth, GridHeight, SkipPos, [Pos-dole|Rest]) :-
    N > 0,
    Pos is GridWidth - N,
    Pos \= SkipPos,  % Skip the position if it matches SkipPos
    N1 is N - 1,
    generate_first_row(N1, GridWidth, GridHeight, SkipPos, Rest).
generate_first_row(N, GridWidth, GridHeight, SkipPos, Rest) :-
    N > 0,
    Pos is GridWidth - N,
    Pos = SkipPos,  % If the position matches SkipPos, skip it
    N1 is N - 1,
    generate_first_row(N1, GridWidth, GridHeight, SkipPos, Rest).

% Base case for generating the first column, with skipping logic
generate_first_column(_, _, 0, _, []) :- !.
generate_first_column(GridWidth, GridHeight, N, SkipPos, [Pos-doprava|Rest]) :-
    N > 0,
    Pos is (N - 1) * GridWidth,
    Pos \= SkipPos,  % Skip the position if it matches SkipPos
    N1 is N - 1,
    generate_first_column(GridWidth, GridHeight, N1, SkipPos, Rest).
generate_first_column(GridWidth, GridHeight, N, SkipPos, Rest) :-
    N > 0,
    Pos is (N - 1) * GridWidth,
    Pos = SkipPos,  % If the position matches SkipPos, skip it
    N1 is N - 1,
    generate_first_column(GridWidth, GridHeight, N1, SkipPos, Rest).

vytvor_pozicie(GridWidth, GridHeight, SkipPos, Result) :-
    generate_first_row(GridWidth, GridWidth, GridHeight, SkipPos, FirstRow),
    generate_first_column(GridWidth, GridHeight, GridHeight, SkipPos, FirstColumn),
    append(FirstRow, FirstColumn, Result), !.

% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikaty, ktore vratia okienko, kde ma zacinat tajanka

% vrat_okienko_tajanky(+_VyskaKrizovky, +SirkaKrizovky, +Smer, -Okienko) :-
% Vrati okienko zaciatku tajanky na ploche cislovanej od 0 z laveho horneho rohu
vrat_okienko_tajanky(_VyskaKrizovky, SirkaKrizovky, dole, Okienko) :-
    Okienko is div(SirkaKrizovky, 2),
    !.

vrat_okienko_tajanky(VyskaKrizovky, SirkaKrizovky, doprava, Okienko) :-
    Riadok is div(VyskaKrizovky, 2), 
    Okienko is Riadok * SirkaKrizovky,
    !.
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% prirad_tajanku(+Tajanka, +TajankaSmer, +Okienko, +VyskaKrizovky, +SirkaKrizovky, +VstupnaPlocha, -VystupnaPlocha) :-
% Predikat vlozi tajanku na plochu podla Okienka, kde zacina a vrati plochu ako VystupnaPlocha
prirad_tajanku(Tajanka, TajankaSmer, Okienko, VyskaKrizovky, SirkaKrizovky, VstupnaPlocha, VystupnaPlocha) :-
    atom_chars(Tajanka, PismenaTajanky), % Zmenim si Tajanku na list pismen
    length(PismenaTajanky, DlzkaTajanky), % Zistim velkost tajanky
    % Test, ci je tajanka na celu sirku/dlzku krizovky
    (TajankaSmer == doprava ->
        DlzkaTajanky = SirkaKrizovky
    ; 
        DlzkaTajanky = VyskaKrizovky  
    ),
    prirad_slovo(Tajanka, PismenaTajanky, DlzkaTajanky, tajanka, Okienko, TajankaSmer, VyskaKrizovky, SirkaKrizovky, VstupnaPlocha, VystupnaPlocha, PriradeneSlovo).
% ----------------------------------------------------------------

% vrat_stlpec_podla_okienka(+Okienko, +SirkaKrizovky, -Stlpec) :-
% Predikat vrati cislo stlpca, kde sa nachadza Okienko
vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, Stlpec) :- 
    Stlpec is Okienko mod SirkaKrizovky.


% vrat_riadok_podla_okienka(+Okienko, +SirkaKrizovky, -Riadok) :-
% Predikat vrati cislo riadku, kde sa nachadza Okienko
vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, Riadok) :-
    Riadok is Okienko // SirkaKrizovky.



% ----------------------------------------------------------------
% vrat_cisla_okienok_pre_slovo(+DlzkaSlova, +Okienko, +Smer, -Okienka, +VyskaKrizovky, +SirkaKrizovky) :- 
% Predikat vrati cisla okienok, kde sa bude slovo nachadzat podla zaciatocneho okienka
% Predikat najprv skontroluje, ci sa dane slovo zmensti na plochu a ak nie, tak vrati false
vrat_cisla_okienok_pre_slovo(DlzkaSlova,  Okienko, doprava, Okienka, VyskaKrizovky, SirkaKrizovky) :-
    vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, StlpecZaciatku),
    KoniecSlova is StlpecZaciatku + DlzkaSlova,
    KoniecSlova =< SirkaKrizovky,
    vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(DlzkaSlova, Okienko, doprava, Okienka, VyskaKrizovky, SirkaKrizovky),
    !.

vrat_cisla_okienok_pre_slovo(DlzkaSlova,  Okienko, dole, Okienka, VyskaKrizovky, SirkaKrizovky) :-
    vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, RiadokZaciatku),
    KoniecSlova is RiadokZaciatku + DlzkaSlova,
    KoniecSlova =< VyskaKrizovky,
    vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(DlzkaSlova, Okienko, dole, Okienka, VyskaKrizovky, SirkaKrizovky),
    !.

% vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(+DlzkaSlova, +Okienko, +Smer, -Okienka, +VyskaKrizovky, +SirkaKrizovk) :- 
% Pomocny predikat pre predikat vrat_cisla_okienok_pre_slovo(), ktory uz vracia 
% iba listy, ak je skontrolovana dlzka slova
vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(1, AktualneOkienko, _, [AktualneOkienko], _, _).

vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(DlzkaSlova, Okienko, doprava, [Okienko|Zvysok], VyskaKrizovky, SirkaKrizovky) :-
    NovaDlzka is DlzkaSlova - 1,
    NoveOkianko is Okienko + 1,
    vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(NovaDlzka, NoveOkianko, doprava, Zvysok, VyskaKrizovky, SirkaKrizovky).

vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(DlzkaSlova, Okienko, dole, [Okienko|Zvysok], VyskaKrizovky, SirkaKrizovky) :-
    NovaDlzka is DlzkaSlova - 1,
    NoveOkianko is Okienko + SirkaKrizovky,
    vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(NovaDlzka, NoveOkianko, dole, Zvysok, VyskaKrizovky, SirkaKrizovky).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% vrat_okienko_za_koncom(+DlzkaSlovam +Okienko, +Smer, +VyskaKrizovky, +SirkaKrizovky, -OkienkoZaKoncom) :-
% Predikat vrati okienko za koncom slova zacinajucom v okienku Okienko s dlzkou DlzkaSlova
% Ak je toto okienko mimo plochy, tak vrati false
vrat_okienko_za_koncom(DlzkaSlova, Okienko, dole, VyskaKrizovky, SirkaKrizovky, OkienkoZaKoncom) :- 
    vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, Riadok),
    KoniecSlova is Riadok + DlzkaSlova,
    ( KoniecSlova < VyskaKrizovky ->
        TrebaPridat is DlzkaSlova * SirkaKrizovky,
        OkienkoZaKoncom is TrebaPridat + Okienko    
    ;
        false
    ).

vrat_okienko_za_koncom(DlzkaSlova, Okienko, doprava, _VyskaKrizovky, SirkaKrizovky, OkienkoZaKoncom) :- 
    vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, Stlpec),
    KoniecSlova is Stlpec + DlzkaSlova,
    ( KoniecSlova < SirkaKrizovky ->
        OkienkoZaKoncom is DlzkaSlova + Okienko    
    ;
        false
    ).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% prazdne_okienko(+Okienko, -Okienko-prazdne) :- 
% Predikat vytovri dvojicu z okienka tak, ze ku nemu prida, ze je prazdne
prazdne_okienko(Okienko, Okienko-prazdne).

% vytvor_plochu(+VyskaKrizovky, +SirkaKrizovky, -Plocha) :-
% Predikat dostane Vysku a Sirku krizovky ako argument a vytvori plochu
% krizovky ako asociativny list
vytvor_plochu(VyskaKrizovky, SirkaKrizovky, Plocha) :-
    PocetOkienok is VyskaKrizovky * SirkaKrizovky,
    PocetOkienokMinusJedna is PocetOkienok - 1,
    numlist(0, PocetOkienokMinusJedna, Okienka),
    maplist(prazdne_okienko, Okienka, TupleOkienka),
    list_to_assoc(TupleOkienka, Plocha).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% vymaz(X,L,R) :- R je L s vymazanym prvym X
vymaz(Y,[X|Xs],[X|Tail]) :-
	Y \== X,
	vymaz(Y,Xs,Tail).
vymaz(X,[X|Xs],Xs) :- !.
vymaz(_,[],[]).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat na vypisovanie Krizovky
vypis_plochu(VyskaKrizovky, SirkaKrizovky) :-
    vypis_hlavicku(SirkaKrizovky),
    vypis_riadky(1, VyskaKrizovky, SirkaKrizovky).

% Helper predicate to print the header row
vypis_hlavicku(SirkaKrizovky) :-
    write('  '), % Start with spaces to align column numbers
    vypis_cisla(1, SirkaKrizovky),
    nl.

% Helper predicate to print column numbers
vypis_cisla(Start, End) :-
    Start =< End,
    write(Start), write(' '),
    Next is Start + 1,
    vypis_cisla(Next, End).
vypis_cisla(Start, End) :-
    Start > End. % Base case

% Helper predicate to print all rows
vypis_riadky(CurrentRow, VyskaKrizovky, SirkaKrizovky) :-
    CurrentRow =< VyskaKrizovky,
    write(CurrentRow), write(' '), % Print row number
    vypis_hviezdicky(SirkaKrizovky),
    nl,
    NextRow is CurrentRow + 1,
    vypis_riadky(NextRow, VyskaKrizovky, SirkaKrizovky).
vypis_riadky(CurrentRow, VyskaKrizovky, _) :-
    CurrentRow > VyskaKrizovky. % Base case

% Helper predicate to print stars for a row
vypis_hviezdicky(0) :- !. % Base case
vypis_hviezdicky(N) :-
    N > 0,
    write('* '),
    N1 is N - 1,
    vypis_hviezdicky(N1).

% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat na vypisanie pozicie tajanky
vypis_poziciu_tajanky(VyskaKrizovky, SirkaKrizovky, Smer) :- 
    vrat_okienko_tajanky(VyskaKrizovky, SirkaKrizovky, Smer, OkienkoTajanky),
    ( Smer = doprava ->
        NewPrveOkienkoZeroBased is OkienkoTajanky // SirkaKrizovky,  % Divide PrveOkienko by SirkaKrizovky if Smer is 'dole'
        NewPrveOkienko is NewPrveOkienkoZeroBased + 1,
        write('Tajanka sa nachadza v riadku cislo '),
        write(NewPrveOkienko)
    ; 
        write('Tajanka sa nachadza v stlpci cislo '),
        write(OkienkoTajanky)
    ).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat na vypis napovied
napoveda_je_doprava([doprava, _, _]).

vypis_napovedy(ListNapovied) :- 
    partition(napoveda_je_doprava, ListNapovied, DopravaNapovedy, ReversedDoleNapovedy),
    write('Napovedy doprava: \n'),
    vypis_jednu_napovedu(DopravaNapovedy),
    nl,
    write('Napovedy dole: \n'),
    reverse(ReversedDoleNapovedy, DoleNapovedy),
    vypis_jednu_napovedu(DoleNapovedy),
    nl.


vypis_jednu_napovedu([]).
vypis_jednu_napovedu([[_, Cislo, Napoveda]|ZvysokNapovied]) :-
    write(Cislo),
    write('. '),
    write(Napoveda),
    nl,
    vypis_jednu_napovedu(ZvysokNapovied).
% ----------------------------------------------------------------