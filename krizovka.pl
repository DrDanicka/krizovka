krizovka(VelkostKrizovky) :-
    najdi_krizovku(VelkostKrizovky).

najdi_krizovku(VelkostKrizovky, Plocha) :- 
    vytvor_plochu_krizovky(VelkostKrizovky, Plocha).

prazdne_okienko(Okienko, Okienko-prazdne).

vytvor_plochu_krizovky(VelkostKrizovky, Plocha) :- 
    PocetOkienok is VelkostKrizovky * VelkostKrizovky,
    numlist(1, PocetOkienok, Okienka),
    maplist(prazdne_okienko, Okienka, DvojiceOkienok),
    list_to_assoc(DvojiceOkienok, Plocha).