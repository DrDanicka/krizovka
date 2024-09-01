% Hlavny predikat krizovka
krizovka(Slovnik, Tajanka, TajankaSmer, VyskaKrizovky, SirkaKrizovky) :- 
    najdi_krizovku(Slovnik, Tajanka, TajankaSmer, VyskaKrizovky, SirkaKrizovky, PolozeneSlova, _),
    vypis_plochu(VyskaKrizovky, SirkaKrizovky),
    write('\n\n'),
    vypis_poziciu_tajanky(VyskaKrizovky, SirkaKrizovky, TajankaSmer),
    write('\n\n'),
    vypis_napovedy(PolozeneSlova, SirkaKrizovky), !.

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
    PolozeneSlovo = [Smer, ZaciatocneOkienko, Napoveda, DlzkaSlova].
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
% Predikát na vypisovanie krížovky
vypis_plochu(VyskaKrizovky, SirkaKrizovky) :-
    nl,
    vypis_hlavicku(SirkaKrizovky),
    vypis_riadky(1, VyskaKrizovky, SirkaKrizovky).

% Pomocný predikát na vypísanie hlavičky riadku
vypis_hlavicku(SirkaKrizovky) :-
    write('  '), % Začneme medzerami pre zarovnanie stĺpcových čísel
    vypis_pismena(1, SirkaKrizovky),
    nl.

% Pomocný predikát na vypísanie písmen (A, B, C, ...)
vypis_pismena(Start, End) :-
    Start =< End,
    PismenoCode is Start + 64, % Získame ASCII kód písmena (A má ASCII kód 65)
    char_code(Pismeno, PismenoCode), % Získame znak z ASCII kódu
    write(Pismeno), write(' '),
    Next is Start + 1,
    vypis_pismena(Next, End).
vypis_pismena(Start, End) :-
    Start > End. % Koncová podmienka

% Pomocný predikát na vypísanie všetkých riadkov
vypis_riadky(CurrentRow, VyskaKrizovky, SirkaKrizovky) :-
    CurrentRow =< VyskaKrizovky,
    write(CurrentRow), write(' '), % Vypíše číslo riadku
    vypis_hviezdicky(SirkaKrizovky),
    nl,
    NextRow is CurrentRow + 1,
    vypis_riadky(NextRow, VyskaKrizovky, SirkaKrizovky).
vypis_riadky(CurrentRow, VyskaKrizovky, _) :-
    CurrentRow > VyskaKrizovky. % Koncová podmienka

% Pomocný predikát na vypísanie hviezdičiek pre riadok
vypis_hviezdicky(0) :- !. % Koncová podmienka
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
        NewPrveOkienkoZeroBased is OkienkoTajanky // SirkaKrizovky,  % Divide OkienkoTajanky by SirkaKrizovky if Smer is 'doprava'
        NewPrveOkienko is NewPrveOkienkoZeroBased + 1,
        write('Tajanka sa nachadza v riadku cislo '),
        write(NewPrveOkienko)
    ; 
        % Pri smere 'dole' potrebujeme získať písmeno pre stĺpec
        PismenoIndex is OkienkoTajanky mod SirkaKrizovky, % Získame index stĺpca (0-based)
        PismenoCode is PismenoIndex + 65, % Mápovanie na ASCII kód pre písmená (A = 65)
        char_code(PismenoTajanky, PismenoCode), % Získame písmeno z ASCII kódu
        write('Tajanka sa nachadza v stlpci '),
        write(PismenoTajanky)
    ).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% Predikat na vypis napovied
napoveda_je_doprava([doprava, _, _, _]).

vypis_napovedy(ListNapovied, SirkaKrizovky) :- 
    partition(napoveda_je_doprava, ListNapovied, DopravaNapovedy, ReversedDoleNapovedy),
    write('Napovedy doprava:'),
    nl,
    write('--------------------'),
    nl,
    vypis_jednu_napovedu(DopravaNapovedy, SirkaKrizovky),
    nl,
    write('Napovedy dole:'),
    nl,
    write('--------------------'),
    nl,
    reverse(ReversedDoleNapovedy, DoleNapovedy),
    vypis_jednu_napovedu(DoleNapovedy, SirkaKrizovky),
    nl.


vypis_jednu_napovedu([], _).
vypis_jednu_napovedu([[_, Okienko, Napoveda, DlzkaSlova]|ZvysokNapovied], SirkaKrizovky) :-
    vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, RiadokMinusJedna),
    vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, Stlpec),
    Riadok is RiadokMinusJedna + 1,
    PismenoCode is Stlpec + 65, % Mápovanie na ASCII kód pre písmená (A = 65)
    char_code(StlpecPismeno, PismenoCode),
    write('Napoveda '),
    write(Riadok),
    write(StlpecPismeno),
    write(' dlzky '),
    write(DlzkaSlova),
    write(': '),
    write(Napoveda),
    nl,
    vypis_jednu_napovedu(ZvysokNapovied, SirkaKrizovky).
% ----------------------------------------------------------------