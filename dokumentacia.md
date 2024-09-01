# Dokumentácia programu Krížovka

## Používateľská dokumentácia

Používateľ môže s programom interagovať pomocou predikátu `krizovka/5`. Rozoberieme si postupne každý zo vstupných argumentov. 

### Slovnik
Argument Slovnik je list slov a nápovied, z ktorých chceme aby sa skladala naša krížovka. Slovník môže vyzerať napríklad takto:

```prolog
[[auto, 'Dopravný prostriedok so 4 kolesami', dom, 'Objekt v ktorom bývame']...]
```
Je to teda list dvojíc, kde každá dvojica pozostáva zo slova, ktoré vložíme do tajničky a nápovedy na dané slovo.

### Tajenka
Tajenka je jedno slovo, ktoré bude výsledkom našej krížovky. Tajenka sa umiestnuje vždy do stredu krížovky a musí mať presne takú dĺžku, aký dlhý je rozmer, v ktorom ju umiestnujeme.

### TajenkaSmer
TajenkaSmer určuje smer, v ktorom bude tajenka do krížovky umiestnená. Môžu to byť hodnoty `doprava` alebo `dole`. 

`doprava` znamená, že tajenka bude umiestnená v strednom riadku zľava doprava.

`dole` znamená, že tajenka bude umiestnená  v strednom stĺpci zhora nadol.

Opäť treba pripomenúť, že je veľmi dôležité, aby sa zhodovala šírka krížovky s dĺžkou tajenky, v prípade, že smer je nastavený na `doprava` a opačne, ak je nastavený smer `dole`, tak sa musí zhodovať výška krížovky a dĺžka tajenky.

### VyskaKrizovky
VyskaKrizovky je číslo, ktoré reprezentuje výšku vytvorenej krížovky.

### SirkaKrizovky
SirkaKrizovky je číslo, ktoré reprezentuje šírku vytvorenej krížovky.

### Príklad vstupu

Ako príklad vstupu si môžeme predstaviť napríklad tento vstup:

```prolog
slovnik(X), krizovka(X, baba, doprava, 4, 4).
```

Ak krížovka existuje, tak predikát vráti nasledujúci výstup (vždy vráti iba prvú nájdenú krížovku):

```
  A B C D 
1 * * * * 
2 * * * * 
3 * * * * 
4 * * * * 


Tajenka sa nachádza v riadku číslo 3

Nápovedy v smere doprava:
--------------------
Nápoveda 1A, dĺžka slova je 4: Hľadané slovo je "bidi"
Nápoveda 2C, dĺžka slova je 2: Hľadané slovo je "eh"
Nápoveda 2A, dĺžka slova je 2: Hľadané slovo je "id"
Nápoveda 4A, dĺžka slova je 4: Hľadané slovo je "beef"

Nápovedy v smere dole:
--------------------
Nápoveda 1A, dĺžka slova je 4: Hľadané slovo je "bibb"
Nápoveda 1B, dĺžka slova je 4: Hľadané slovo je "idae"
Nápoveda 1C, dĺžka slova je 4: Hľadané slovo je "debe"
Nápoveda 1D, dĺžka slova je 1: Hľadané slovo je "i"
Nápoveda 2D, dĺžka slova je 3: Hľadané slovo je "haf"
```

Výstup obsahuje:

#### Krížovku:

```
  A B C D 
1 * * * * 
2 * * * * 
3 * * * * 
4 * * * * 
```
Krížovka je reprezentovaná znakmi `*`. Ku každému riadku je priradené číslo od 1 a ku každému stĺpcu je priradené písmeno od A...

#### Miesto kde sa nachádza tajenka:

```
Tajenka sa nachádza v riadku číslo 3
```
Výstup ďalej obsahuje výpis, ktorý hovorí, kde sa nachádza tajenka. Môže to byť buď číslo riadku, alebo písmeno stĺpca na základe toho, či si používateľ zvolil ako smer tajenky `doprava` alebo `dole`.

#### Nápovedy:
```
Nápovedy v smere doprava:
--------------------
Nápoveda 1A, dĺžka slova je 4: Hľadané slovo je "bidi"
Nápoveda 2C, dĺžka slova je 2: Hľadané slovo je "eh"
Nápoveda 2A, dĺžka slova je 2: Hľadané slovo je "id"
Nápoveda 4A, dĺžka slova je 4: Hľadané slovo je "beef"

Nápovedy v smere dole:
--------------------
Nápoveda 1A, dĺžka slova je 4: Hľadané slovo je "bibb"
Nápoveda 1B, dĺžka slova je 4: Hľadané slovo je "idae"
Nápoveda 1C, dĺžka slova je 4: Hľadané slovo je "debe"
Nápoveda 1D, dĺžka slova je 1: Hľadané slovo je "i"
Nápoveda 2D, dĺžka slova je 3: Hľadané slovo je "haf"
```
Na záver výstup obsahuje výpis všetkých nápovied ku slovám v tajničke. Nápovedy sú rozdelené na nápovedy slov v smere `doprava` a na nápovedy slov v smere `dole`. 

Jedna nápoveda obsahuje informáciu, kde slovo začína vo forme: číslo riadku a písmeno stĺpca. To znamená, že napríklad 2D by znamenalo, že slovo začína v okienku v riadku 2 a v stĺpci D. 

Ďalej nápoveda obsahuje informáciu o dĺžke slova, ktoré treba do krížovky doplniť. 

Nakoniec jeden riadok nápovedy obsahuje nápovedu ku slovu, ktorá bola zadaná používateľom v slovníku. 

Ukážme si aj, ako by vyzerala takto vyplnená tajnička:
![](img/krizovka.jpeg)

*Poznámka:* V tomto príklade, ale aj vo všetkých ostantých vzorových vstupoch, nápovedy slúžia iba na prevedenie funkcionality, preto nápovedy priamo hovoria, čo je naše hľadané slovo. V reálnom prípade sme tam zadali skutočnú nápovedu.

Príklady použiteľný vstupov môžete nájsť [tu](vstupy.txt).

## Programátrská dokumentácia

