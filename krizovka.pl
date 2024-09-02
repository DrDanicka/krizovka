% V subore slovnik.pl sa nachadzaju pomocne slovniky pre niektore vstupy
:- consult('slovnik.pl').

% kizovka(+Slovnik, +Tajenka, +TajenkaSmer, +VyskaKrizovky, +SirkaKrizovky) :-
% krizovka je hlavny predikat, ktory hlada krizovku a vypisuje ju. Ako argumenty
% berie Slovnik, co je list listov, kde kazdy vnutorny list obsahuje Slovo a Napovedu, 
% dalej berie Tajenku a jej Smer, ktory moze byt 'dole' alebo 'doprava'. Nakoniec berie
% parametre tvaru krizovky, ktore su reprezentovane Vyskou a Sirkou.
krizovka(Slovnik, Tajenka, TajenkaSmer, VyskaKrizovky, SirkaKrizovky) :- 
    najdi_krizovku(Slovnik, Tajenka, TajenkaSmer, VyskaKrizovky, SirkaKrizovky, PouziteSlova),
    vypis_plochu(VyskaKrizovky, SirkaKrizovky),
    nl, nl,
    vypis_poziciu_tajenky(VyskaKrizovky, SirkaKrizovky, TajenkaSmer),
    nl, nl,
    vypis_napovedy(PouziteSlova, SirkaKrizovky),
    !.



% najdi_krizovku(+Slovnik, +Tajenka, +TajenkaSmer, +VyskaKrizovky, +SirkaKrizovky, -PouziteSlova) :-
% Predikat, ktory najde krizovku na zaklade predanych parametrov. V prvom rade vytvori plochu krizovky
% a nasledne do nej ulozi tajenku. Potom sa uz snazi Okienkokladat slova zo slovniku tak, aby vytvoril krizovku.
najdi_krizovku(Slovnik, Tajenka, TajenkaSmer, VyskaKrizovky, SirkaKrizovky, PouziteSlova) :-
    % Vytvorime si plochu krizovky
    % Okienka krizovky cislujeme od 0 do (VyskaKrizovky * SirkaKrizovky - 1)
    vytvor_plochu(VyskaKrizovky, SirkaKrizovky, Plocha),

    % Dostaneme cislo Okienka, kde chceme aby zacinala nasa tajenka
    vrat_okienko_tajenky(VyskaKrizovky, SirkaKrizovky, TajenkaSmer, OkienkoTajenky), % OkienkoTajenky je okienko, kde zacina tajenka
    
    % Vlozime tajenku do krizovky
    prirad_tajenku(Tajenka, TajenkaSmer, OkienkoTajenky, VyskaKrizovky, SirkaKrizovky, Plocha, PlochaSTajenkou),

    % Vygeneruje pozicie, kde budeme chciet umiestnit nase slova okrem Tajenky
    % Pozicie su list: [Okienko-Smer, ...] -> napr [0-dole, 1-dole, 0-doprava, 2-doprava]
    vytvor_pozicie(VyskaKrizovky, SirkaKrizovky, OkienkoTajenky, Pozicie),

    % Prirad slova zo slovnika do krizovky
    prirad_slova(Slovnik, [], Pozicie, VyskaKrizovky, SirkaKrizovky, PlochaSTajenkou, PouziteSlova).



% ----------------------------------------------------------------
% PRIRADZOVACIE PREDIKATY


% prirad_tajenku(+Tajenka, +TajenkaSmer, +Okienko, +VyskaKrizovky, +SirkaKrizovky, +VstupnaPlocha, -VystupnaPlocha) :-
% Predikat vlozi tajenku na plochu podla Okienka, kde zacina a vrati plochu ako VystupnaPlocha
prirad_tajenku(Tajenka, TajenkaSmer, Okienko, VyskaKrizovky, SirkaKrizovky, VstupnaPlocha, VystupnaPlocha) :-
    % Zmenime si tajenku na list pismen a zistim velkost tajenky
    atom_chars(Tajenka, PismenaTajenky),
    length(PismenaTajenky, DlzkaTajenky),

    % Test, ci je tajenka na celu sirku/dlzku krizovky
    (TajenkaSmer == doprava ->
        DlzkaTajenky = SirkaKrizovky
    ; 
        DlzkaTajenky = VyskaKrizovky  
    ),
    % Priradime tajenku na plochu
    prirad_slovo(PismenaTajenky, DlzkaTajenky, tajenka, Okienko, TajenkaSmer, VyskaKrizovky, SirkaKrizovky, VstupnaPlocha, VystupnaPlocha, _).



% prirad_slova(+Slova, +PouziteSlova, +Pozicie, +VyskaKrizovky, +SirkaKrizovky, +VstupnyPlocha, -PouziteSlovaOut) :-
% Predikat prirad_slova, sa pokusi vlozit slova zo slovniku na plochu krizovky
prirad_slova(_, PouziteSlova, [], _, _, _, PouziteSlova). % Ak uz neexistuje ziadna pozicia, tak je krizovka vyplnena

prirad_slova(Slovnik, PouziteSlova, [Pozicia|ZvysnePozicie], VyskaKrizovky, SirkaKrizovky, Plocha, PouziteSlovaOut) :-
    % Vyberieme Slovo zo Slovniku
    member([Slovo, Napoveda], Slovnik),
    
    % Rozlozime Slovo na pismena a zistime dlzku slova
    atom_chars(Slovo, ListPismen),
    length(ListPismen, DlzkaSlova),

    % Rozdelime Poziciu na Okienko a Smer
    Pozicia = Okienko-Smer,

    % Pokusime sa priradit Slovo na danu poziciu -> Okienko a Smer
    prirad_slovo(ListPismen, DlzkaSlova, Napoveda, Okienko, Smer, VyskaKrizovky, SirkaKrizovky, Plocha, PlochaSoSlovom, PouziteSlovo),
    
    % Ak slovo nedosahuje az na okraj plochy krizovky, tak pridaj medzi pozicie novu poziciu do konca plochy
    ( vrat_okienko_za_koncom(DlzkaSlova, Okienko, Smer, VyskaKrizovky, SirkaKrizovky, OkienkoZaKoncom) ->
        % Pridame novu poziciu do konca riadku/stlpca
        NovaPozicia = OkienkoZaKoncom-Smer,
        ZvysnePoziciePridane = [NovaPozicia|ZvysnePozicie]
    ;
        % Slovo dosahuje az na koniec -> nepridavame novu poziciu
        ZvysnePoziciePridane = ZvysnePozicie 
    ),

    % Pouzite slovo vymazeme zo slovniku
    vymaz([Slovo, Napoveda], Slovnik, PremazanySlovnik),
    % Rekurzivne priradzujeme dalsie slova
    prirad_slova(PremazanySlovnik, [PouziteSlovo|PouziteSlova], ZvysnePoziciePridane, VyskaKrizovky, SirkaKrizovky, PlochaSoSlovom, PouziteSlovaOut).



% prirad_slovo(+Slovo, +ListPismen, +DlzkaSlova, +Napoveda, +OkieknoZaciatku, +Smer, +VyskaKrizovky, +SirkaKrizovky, +VstupnaPlocha, -VystupnaPlocha, -PouziteSlovo) :-
% Predikat, ktory podla zaciatocneho okienka a smeru priradi Slovo na plochu krizovky
prirad_slovo(ListPismen, DlzkaSlova, Napoveda, OkienkoZaciatku, Smer, VyskaKrizovky, SirkaKrizovky, VstupnaPlocha, VystupnaPlocha, PouziteSlovo) :-
    % Ak sa slovo zmesti do riadku/stlpca, tak vrati cisla okienok, v ktorych sa bude nachadzat
    vrat_cisla_okienok_pre_slovo(DlzkaSlova, OkienkoZaciatku, Smer, Okienka, VyskaKrizovky, SirkaKrizovky),

    % Priradi Slovo pismeno po pismena na plochu
    prirad_pismena(ListPismen, Smer, DlzkaSlova, Okienka, VstupnaPlocha, VystupnaPlocha),

    Okienka = [ZaciatocneOkienko|_],
    % Ulozim si atributy k pouzitemu slovu na neskorsie vypisanie napovied
    PouziteSlovo = [Smer, ZaciatocneOkienko, Napoveda, DlzkaSlova].



% prirad_pismena(+ListPismen, +Smer, +DlzkaSlova, +Okienka, +VtupnaPlocha, -VystupnaPlocha) :-
% Predikat zapise pismena slova na plochu krizovky do okienok v Okienka.
% V pripade, ze su vsetky pismena zapisane, tak prekopirujeme plochu na vystup
prirad_pismena([], _, _, [], G, G).

prirad_pismena([Pismeno|ZvysokPismen], Smer, Dlzka, [Okienko|ZvysokOkienok], VstupnaPlocha, VystupnaPlocha):-
    % Zistime si hodnotu v okienku na ploche, ktora bude v X
    get_assoc(Okienko, VstupnaPlocha, X),
    (
    % Ak sa v okienku nachadza rovnake pismeno, tak sa nam slova mozu prekryvat a mozeme dalej pokracovat
    X == Pismeno,
    PlochaSoSlovom = VstupnaPlocha
    ;
    % Ak je okienko prazdne, tak do neho priradime pismeno naseho slova
    X == prazdne,
    put_assoc(Okienko, VstupnaPlocha, Pismeno, PlochaSoSlovom)
    ), !, 
    % Rekurzivne pokracujeme v priradzovani pismen na plochu
    prirad_pismena(ZvysokPismen, Smer, Dlzka, ZvysokOkienok, PlochaSoSlovom, VystupnaPlocha).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% PREDIKATY NA GENEROVANIE POZICII NA PLOCHE


% vytvor_pozicie(+VyskaKrizovky, +SirkaKrizovky, +OkienkoTajenky, -Pozicie) :- 
% Predikat vytvori list pozicii, kde mozeme umiestnit slovo. List obsahuje 
% dvojice ZaciatocneOkieko-Smer. Zaciname umiestnovat od prveho riadka a prveho stlpca
vytvor_pozicie(VyskaKrizovky, SirkaKrizovky, OkienkoTajenky, Pozicie) :-
    vygeneruj_prvy_riadok(SirkaKrizovky, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, PrvyRiadok),
    vygeneruj_prvy_stlpec(VyskaKrizovky, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, PrvyStlpec),
    append(PrvyRiadok, PrvyStlpec, Pozicie), 
    !.



% vygeneruj_prvy_riadok(+N, +SirkaKrizovky, +VyskaKrizovky, +OkienkoTajenky, -PrvyRiadok) :-
% Predikat vygeneruje prvy riadok pozici na ploche.
vygeneruj_prvy_riadok(0, _, _, _, []) :- !.

vygeneruj_prvy_riadok(N, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, [Okienko-dole|Zvysok]) :-
    N > 0,
    Okienko is SirkaKrizovky - N,
    
    % Skontrolujeme, ci okienko nie je zaciatocne okienko tajenky
    Okienko \= OkienkoTajenky, 
    N1 is N - 1,
    vygeneruj_prvy_riadok(N1, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, Zvysok).

vygeneruj_prvy_riadok(N, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, Zvysok) :-
    N > 0,
    Okienko is SirkaKrizovky - N,

    % Ak je okienko zaciatocne okienko tajenky, tak ho vynechame
    Okienko = OkienkoTajenky,
    N1 is N - 1,
    vygeneruj_prvy_riadok(N1, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, Zvysok).



% vygeneruj_prvy_stlpec(+N, +SirkaKrizovky, +VyskaKrizovky, +OkienkoTajenky, -PrvyRiadok) :-
% Predikat vygeneruje prvy riadok pozici na ploche.
vygeneruj_prvy_stlpec(0, _, _, _, []) :- !.

vygeneruj_prvy_stlpec(N, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, [Okienko-doprava|Zvysok]) :-
    N > 0,
    Okienko is (N - 1) * SirkaKrizovky,

    % Skontrolujeme, ci okienko nie je zaciatocne okienko tajenky
    Okienko \= OkienkoTajenky,
    N1 is N - 1,
    vygeneruj_prvy_stlpec(N1, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, Zvysok).

vygeneruj_prvy_stlpec(N, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, Zvysok) :-
    N > 0,
    Okienko is (N - 1) * SirkaKrizovky,

    % Ak je okienko zaciatocne okienko tajenky, tak ho vynechame
    Okienko = OkienkoTajenky,
    N1 is N - 1,
    vygeneruj_prvy_stlpec(N1, SirkaKrizovky, VyskaKrizovky, OkienkoTajenky, Zvysok).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% UTILS PREDIKATY VRACAJUCE INFORMACIE

% vrat_okienko_tajenky(+VyskaKrizovky, +SirkaKrizovky, +Smer, -Okienko) :-
% Vrati okienko zaciatku tajenky na ploche cislovanej od 0 z laveho horneho rohu
vrat_okienko_tajenky(_VyskaKrizovky, SirkaKrizovky, dole, Okienko) :-
    Okienko is div(SirkaKrizovky, 2),
    !.

vrat_okienko_tajenky(VyskaKrizovky, SirkaKrizovky, doprava, Okienko) :-
    PrvyRiadok is div(VyskaKrizovky, 2), 
    Okienko is PrvyRiadok * SirkaKrizovky,
    !.



% vrat_stlpec_podla_okienka(+Okienko, +SirkaKrizovky, -Stlpec) :-
% Predikat vrati cislo stlpca, kde sa nachadza Okienko
vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, Stlpec) :- 
    Stlpec is Okienko mod SirkaKrizovky.


% vrat_riadok_podla_okienka(+Okienko, +SirkaKrizovky, -PrvyRiadok) :-
% Predikat vrati cislo riadku, kde sa nachadza Okienko
vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, Riadok) :-
    Riadok is Okienko // SirkaKrizovky.



% vrat_cisla_okienok_pre_slovo(+DlzkaSlova, +Okienko, +Smer, -Okienka, +VyskaKrizovky, +SirkaKrizovky) :- 
% Predikat vrati cisla okienok, kde sa bude slovo nachadzat podla zaciatocneho okienka
% Predikat najprv skontroluje, ci sa dane slovo zmensti na plochu a ak nie, tak vrati false
vrat_cisla_okienok_pre_slovo(DlzkaSlova,  Okienko, doprava, Okienka, VyskaKrizovky, SirkaKrizovky) :-
    vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, StlpecZaciatku),
    KoniecSlova is StlpecZaciatku + DlzkaSlova,
    
    % Skontrolujeme, ci sa slovo zmesti do riadku 
    KoniecSlova =< SirkaKrizovky,
    vrat_cisla_okienok_pre_slovo_skontrolovana_dlzka(DlzkaSlova, Okienko, doprava, Okienka, VyskaKrizovky, SirkaKrizovky),
    !.

vrat_cisla_okienok_pre_slovo(DlzkaSlova,  Okienko, dole, Okienka, VyskaKrizovky, SirkaKrizovky) :-
    vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, PrvyRiadokZaciatku),
    KoniecSlova is PrvyRiadokZaciatku + DlzkaSlova,

    % Skontrolujeme, ci sa slovo zmenti do stlpca
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



% vrat_okienko_za_koncom(+DlzkaSlovam +Okienko, +Smer, +VyskaKrizovky, +SirkaKrizovky, -OkienkoZaKoncom) :-
% Predikat vrati okienko za koncom slova zacinajucom v okienku Okienko s dlzkou DlzkaSlova,
% Ak je toto okienko mimo plochy, tak vrati false.
vrat_okienko_za_koncom(DlzkaSlova, Okienko, dole, VyskaKrizovky, SirkaKrizovky, OkienkoZaKoncom) :- 
    vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, PrvyRiadok),
    KoniecSlova is PrvyRiadok + DlzkaSlova,

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



% vymaz(X,L,R) :- R je L s vymazanym prvym X
vymaz(Y,[X|Xs],[X|Tail]) :-
	Y \== X,
	vymaz(Y,Xs,Tail).
vymaz(X,[X|Xs],Xs) :- !.
vymaz(_,[],[]).
% ----------------------------------------------------------------



% ----------------------------------------------------------------
% GENEROVANIE PLOCHY KRIZOVKY


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
% PREDIKATY VYPISOVANIA

% vypis_plochu(+VyskaKrizovky, +SirkaKirzovky) :-
% Predikat, ktory podla vysky a sirky vypise krizovku tvorenu z '*'.
% Riadky krizovky su ocislovane a stlpce su oznacene velkymi pismenami A, B, C...
vypis_plochu(VyskaKrizovky, SirkaKrizovky) :-
    nl,
    vypis_hlavicku(SirkaKrizovky),
    vypis_riadky(1, VyskaKrizovky, SirkaKrizovky).



% vypis_hlavicku(+SirkaKrizovky) :-
% Pomocny predikat na vypisanie hlavicky krizovky.
vypis_hlavicku(SirkaKrizovky) :-
    % Zacneme medzerami pre zarovananie stlpcov
    write('  '),
    vypis_pismena(1, SirkaKrizovky),
    nl.



% vypis_pismena(+Zaciatok, +Koniec) :-
% Pomocny predikat na vypisanie pismen A, B, C, ...
vypis_pismena(Zaciatok, Koniec) :-
    Zaciatok =< Koniec,

    % Ziskame ASCII kod pismena (A ma ASCII kod 65)
    PismenoKod is Zaciatok + 64,
    % Ziskame znak z ASCII kodu
    char_code(Pismeno, PismenoKod),

    write(Pismeno), write(' '),
    Next is Zaciatok + 1,
    vypis_pismena(Next, Koniec).

% Koncova podmienka
vypis_pismena(Zaciatok, Koniec) :-
    Zaciatok > Koniec. 



% vypis_riadky(+AktualnyRiadok, +VyskaKrizovky, +SirkaKrizovky) :-
% Pomocny predikat na vypisanie vsetkych riadkov
vypis_riadky(AktualnyRiadok, VyskaKrizovky, SirkaKrizovky) :-
    AktualnyRiadok =< VyskaKrizovky,
    % Vypiseme cislo riadku a '*'
    write(AktualnyRiadok), write(' '),
    vypis_hviezdicky(SirkaKrizovky),
    nl,
    DalsiRiadok is AktualnyRiadok + 1,
    % Rekurzivne vypiseme dalsie riadky
    vypis_riadky(DalsiRiadok, VyskaKrizovky, SirkaKrizovky).

% Koncova podmienka
vypis_riadky(AktualnyRiadok, VyskaKrizovky, _) :-
    AktualnyRiadok > VyskaKrizovky.


% vypis_hviezdicky(+N) :-
% Pomocny predikat na vypisanie hviezdiciek ako prazdnej krizovky.
% Koncová podmienka
vypis_hviezdicky(0) :- !. 

vypis_hviezdicky(N) :-
    N > 0,
    write('* '),
    N1 is N - 1,
    vypis_hviezdicky(N1).



% vypis_poziciu_tajenky(+VyskaKrizovky, +SirkaKrizovky, +Smer) :-
% Predikat na vypisanie pozicie tajenky. Vypise bud cislo riadku v ktorom sa nachadza,
% alebo pismeno stlpca, v ktorom sa nachadza
vypis_poziciu_tajenky(VyskaKrizovky, SirkaKrizovky, Smer) :- 
    vrat_okienko_tajenky(VyskaKrizovky, SirkaKrizovky, Smer, OkienkoTajenky),
    ( Smer = doprava ->
        NewPrveOkienkoZeroBased is OkienkoTajenky // SirkaKrizovky,
        % Riadky vo vypise cislujeme od 1
        NewPrveOkienko is NewPrveOkienkoZeroBased + 1,
        write('Tajenka sa nachádza v riadku číslo '),
        write(NewPrveOkienko)
    ; 
        % Pri smere 'dole' potrebujeme ziskat pismeno pre stlpec
        vrat_stlpec_podla_okienka(OkienkoTajenky, SirkaKrizovky, Stlpec),

        % Mapovanie na ASCII kód pre písmená (A = 65)
        PismenoKod is Stlpec + 65, 
        % Získame písmeno z ASCII kódu
        char_code(PismenoTajenky, PismenoKod),

        write('Tajenka sa náchadza v stĺpci '),
        write(PismenoTajenky)
    ).



% napoveda_je_doprava(+Napoveda) :-
% Predikat, ktory vrati true, ake je napoveda doprava a nie dole.
napoveda_je_doprava([doprava, _, _, _]).



% vypis_napovedy(+ListNapovied, +SirkaKrizovky) :-
% Predikat, ktory vypise napovedy. Najprv vypise napovedy v smere 'doprava' a
% potom napovedy v smere 'dole'. 
vypis_napovedy(ListNapovied, SirkaKrizovky) :- 
    % Rozdelime napovedy na doprava a dole
    partition(napoveda_je_doprava, ListNapovied, DopravaNapovedy, ReversedDoleNapovedy),
    write('Nápovedy v smere doprava:'),
    nl,
    write('--------------------'),
    nl,
    vypis_jednu_napovedu(DopravaNapovedy, SirkaKrizovky),
    nl,
    write('Nápovedy v smere dole:'),
    nl,
    write('--------------------'),
    nl,
    reverse(ReversedDoleNapovedy, DoleNapovedy),
    vypis_jednu_napovedu(DoleNapovedy, SirkaKrizovky),
    nl.

% vypis_jednu_napovedu(+ListNapovied, +SirkaKrizovky) :-
% Predikat vypise jednu napovedu. Napoveda sa sklada z cisla riadku a pismena stlpca,
% kde zacina. Nasledne je napisana dlzka slova, ktore treba doplnit a nakoniec je 
% napisana napoveda.
vypis_jednu_napovedu([], _).

vypis_jednu_napovedu([[_, Okienko, Napoveda, DlzkaSlova]|ZvysokNapovied], SirkaKrizovky) :-
    vrat_riadok_podla_okienka(Okienko, SirkaKrizovky, PrvyRiadokMinusJedna),
    vrat_stlpec_podla_okienka(Okienko, SirkaKrizovky, Stlpec),
    PrvyRiadok is PrvyRiadokMinusJedna + 1,
    % Mapovanie na ASCII kod pre pismena (A = 65)
    PismenoKod is Stlpec + 65, 
    char_code(StlpecPismeno, PismenoKod),
    write('Nápoveda '),
    write(PrvyRiadok),
    write(StlpecPismeno),
    write(', dĺžka slova je '),
    write(DlzkaSlova),
    write(': '),
    write(Napoveda),
    nl,
    % Rekurzivne vypisema dalsie napovedy
    vypis_jednu_napovedu(ZvysokNapovied, SirkaKrizovky).
% ----------------------------------------------------------------