# IVXV ametlike protseduuridokumentide ristkontroll

Vaatasin ühe tervikuna läbi seitse RVT avaldatud dokumenti: üldraamistiku,
e-hääletamise käsiraamatu, seadistuste koostamise juhendi, valijarakenduse
pakendamise juhendi, kogumisteenuse haldusjuhendi, haldusteenuse kasutusjuhendi ja
VIS3–EHS liideste spetsifikatsiooni.

See analüüs **ei väida**, et hääli võltsiti või et valimistulemus oli vale. Küsimus on
kitsam: kas ametlik dokumentatsioon võimaldab sõltumatul kontrollijal tõendada kogu
ahela tarkvarast kuni valimistulemuseni?

## Mis on dokumentides hästi

Dokumentides on mitmeid päriselt olulisi kontrollimehhanisme:

- konfiguratsioonid ja paljud andmefailid allkirjastatakse digitaalselt;
- hääled registreeritakse eraldi registreerimisteenuses;
- avamisvõti on jagatud mitme võtmehalduri vahel;
- töötlemise, miksimise ja lugemise kontrolliks kasutatakse logisid ning
  krüptograafilisi tõendeid;
- miksimist saab kontrollida nii IVXV auditirakenduse kui Verificatumi vahendiga;
- valija saab kontrollrakendusega oma hääle kohalejõudmist kontrollida;
- kogumisteenusele on ette nähtud seire, varundus ja krahhitaaste.

Probleem ei ole selles, et kontrolli üldse pole. Probleem on selles, et need kontrollid
ei moodusta üht täielikku ja sõltumatult tõendatavat ahelat.

## 1. Puudub ahel avalikust lähtekoodist valimistel kasutatud binaarfailini

Käsiraamat ütleb kogumisteenuse kohta lihtsalt, et paigaldatakse „viimane
tarkvaraversioon“. Java rakendused tarnitakse ZIP-failidena, kogumisteenus `.deb`
pakettidena ning valijarakendused ja pakendamise tööriistad „IVXV tarnepakis“.

Kusagil ei ole terviklikult nõutud:

- täpset lähtekoodi commit’i;
- reprodutseeritavat build’i;
- kõigi sõltuvuste ja build-keskkonna fikseerimist;
- kõigi tarnepakis olevate failide allkirjastatud manifesti;
- sõltumatu build’i binaarfailide võrdlemist ametlike failidega;
- tootmismasinates tegelikult paigaldatud failide hash’ide avaldamist.

Seega tõendatakse peamiselt seda, et fail vastab RVT või tarnija antud hash’ile.
Tõendamata jääb, kust see fail pärineb.

Vajalik ahel on:

**avalik lähtekood → sõltumatu reprodutseeritav build → identne binaarfail →
ametlik tarne → valimistel tegelikult kasutatud binaarfail.**

## 2. Puudub üks muutumatu valimiste tarkvara- ja seadistusmanifest

Dokumentides on palju eraldi konfiguratsioone, sertifikaate, pakette ja nimekirju,
kuid pole üht allkirjastatud lõppmanifesti, kuhu kuuluksid korraga:

- kõik tarkvarapakid, failinimed, versioonid ja hash’id;
- lähtekoodi commit’id ja build-andmed;
- operatsioonisüsteemi image ja paketiversioonid;
- Java, OpenSSL-i ja teiste tööriistade versioonid;
- lõplikud konfiguratsioonid ja nimekirjad;
- sertifikaadid ja usaldusjuured;
- snapshot’ide identifikaatorid ja hash’id;
- volitatud kinnitajad;
- kõik hilisemad muudatused koos põhjenduse ja kinnitustega.

Mõne processor’i või auditor’i konfiguratsiooni võib koostada alles vahetult enne
vastavat toimingut. Kõigi rakenduste konfiguratsioonide allkirjastaja pole käsiraamatu
järgi isegi rangelt määratud. Digiallkiri näitab, kes faili allkirjastas, kuid mitte seda,
et tal oli just selle faili kinnitamise õigus või et sisu oli sõltumatult kontrollitud.

## 3. Kohustuslik audit ei kata kogu kriitilist protsessi

Audiitori järelevalve on kohustuslik miksimisel ja avamisvõtmega seotud toimingutel.
Muud protseduurid kontrollitakse „vastavalt vajadusele“ ning vaatlejate kohalolek on
soovituslik.

Eriti kõnekas on häälte lugemise ettevalmistav osa, mis on otseselt märgitud
**mitte-auditeeritavaks**. Just selles etapis pannakse võtmerakendus, muud programmid
ja konfiguratsioon välisele andmekandjale. Hiljem jälgitakse programmi käivitamist,
aga mitte täielikult seda, kuidas valiti ja ette valmistati käivitatav programm.

Üldraamistik ütleb lisaks, et auditirakenduse usaldusväärsuse tagamine on audiitori
enda ülesanne. See ei asenda auditirakenduse sõltumatut build’i ja binaarfaili
kontrolli.

## 4. Ametlikud juhendid ei määra ühtset tehnilist keskkonda

2025. aasta dokumentides leidub korraga:

- kogumisteenuse platvormina Ubuntu 20.04;
- Java rakenduste testkeskkonnana Ubuntu 22.04;
- Java 21;
- võtmerakenduse arvutis Java 17 või uuem;
- paigaldusnäidetes IVXV 1.7.8 paketid;
- krahhitaastes `1.9.12~dev` pakett;
- juhis „täpsusta üle, millist Ubuntu versiooni parasjagu kasutatakse“.

Veel nimetatakse Ubuntu 20.04 ekslikult Bionic Beaveriks, kuigi 20.04 on Focal
Fossa. Kogumisteenuse juhend viitab vanale üldraamistikule 0.95, samal ajal kui
kehtivaks avaldatud dokument on 1.1.

Sellise dokumentatsiooni järgi võivad kaks pädevat süsteemiülemat ehitada erineva
keskkonna ja mõlemad väita, et järgisid juhendit.

## 5. Valijarakenduse pakendamise ahel on nõrk

Valijarakenduse seadistamine algab juba kompileeritud binaarfailidest, mis tarnitakse
IVXV tarnepakis. Samas tarnepakis tulevad ka `Seadistaja.exe`,
`packagesigner.sh`, `Valimine.tar` ja `entitlements.plist`.

Juhend ei seo neid faile avaliku lähtekoodi commit’i ega sõltumatu build’iga.
`Seadistaja.exe` süstib ressursid otse binaarfailidesse. Seetõttu peaks olema
kontrollitav nii algse binaarfaili, sisestatud ressursside, pakendamistööriista kui ka
lõpptulemuse hash.

Lisaks ütleb pakendamisjuhend, et allkirjastamine pärast seadistamist on valikuline,
kuid e-hääletamise käsiraamat nõuab Windowsi ja macOS-i rakenduse allkirjastamist.
Linuxi rakendus jääb allkirjastamata.

Testhääletus näitab, et tavapärane protsess töötab. See ei tõenda, et binaarfail
sisaldab ainult avaldatud lähtekoodist tulenevat programmi.

## 6. Väliste andmekandjate ja käsitsi edastatud failide kontrolliahel pole täielik

Rakendusi, konfiguratsioone, valimiskasti, logisid, tõendeid ja tulemusi liigutatakse
korduvalt väliste andmekandjatega. VIS3 ja EHS vahel toimub mitu kriitilist
inim-masin-protseduuri: üks operaator laeb JSON-faili alla, allkirjastab selle väljaspool
süsteemi, annab teisele operaatorile ning teine laeb faili üles.

Dokumentides pole ühe tervikuna nõutud:

- andmekandja unikaalset tunnust ja seerianumbrit;
- iga üleandmise aega, kohta, üleandjat ja vastuvõtjat;
- kogu andmekandja failide loendit ja kõigi failide hash’e;
- kirjutuskaitset, pitseri numbrit ja pitseri kontrolli;
- kahe isiku kinnitust;
- vastuvõtusüsteemi allkirjastatud kviitungit;
- algfaili, allkirjakonteineri ja üleslaetud faili muutumatut seost.

Ühe väljundfaili allkirjastatud hash ei tõenda kogu andmekandja ega kasutatud
programmide päritolu.

## 7. Snapshot’ide, varukoopiate ja taastamise kontroll on puudulik

TEST-hääletuse järel tehakse kaks snapshot’i ning valimisteks taastatakse süsteem
ühest neist. Juhend ei nõua selgelt snapshot’i hash’i, allkirjastatud sisumanifesti,
sõltumatut kinnitamist ega tõendit, et taastati just heakskiidetud snapshot.

Kogumisteenuse haldusjuhend ütleb otse, et haldusteenuse konfiguratsiooni
varukoopiast taastamise protseduuri pole ette nähtud. Sama öeldakse logide
varukoopia kohta. Samas soovitatakse kasutada virtuaalmasina snapshot dump’i.

Varukoopia olemasolu ei ole veel taastatavuse tõend. Vaja on regulaarset
taastamistesti ning pärast taastamist kogu süsteemi võrdlemist kinnitatud
valimismanifestiga.

## 8. Kontrollid on olemas, aga läbikukkunud kontrolli menetlus on ebaselge

Dokumendid nõuavad, et miksitud ja miksimata lugemistulemused oleksid identsed.
Vigased lugemistõendid kirjutatakse faili. Miksimist ja lugemist kontrollitakse
tõenditega.

Aga puudub üks selge otsustabel:

- mis juhtub, kui tulemused erinevad;
- mis juhtub, kui tõend ei kehti;
- kes peatab protsessi;
- millised andmed kohe külmutatakse;
- kes uurib;
- kas esialgse tulemuse avaldamine peatatakse;
- kuidas kõrvalekalle avalikustatakse;
- kes võib anda loa jätkamiseks.

Tugevast kontrollist on vähe kasu, kui selle ebaõnnestumise korral pole üheselt
määratud tagajärge.

## 9. Kriitilised õigused on koondatud laiadesse rollidesse

`admin` saab rakendada tehnilist ja valimiste seadistust, hallata kasutajaid, laadida
alla valimiskasti ning vaadata logisid. `election-conf-manager` saab rakendada
valimiste seadistusi ja laadida alla valimiskasti. Kasutajal võib olla mitu rolli ning
õigused liituvad.

Juhendites ei ole kõigi kriitiliste toimingute jaoks kohustuslikku kahe inimese reeglit
või kahekordset kinnitamist. See puudutab vähemalt tarkvarauuendusi, seadistuste
rakendamist, kasutajaõiguste muutmist, lõpliku valimiskasti eksporti, snapshot’i
taastamist ja töötlemismeedia ettevalmistamist.

## 10. Logide tõendusväärtus pole lõpuni tagatud

Haldusteenus kuvab sündmuse aja, teenuse, taseme, liigi ja kirjelduse. Logisid
kogutakse ja varundatakse. Kuid dokumentidest ei tule selgelt välja kohustuslikku:

- krüptograafiliselt aheldatud või perioodiliselt allkirjastatud logi;
- sõltumatu osapoole juurde reaalajas kopeerimist;
- muutmatut säilitust;
- kõigi logiallikate usaldusväärse aja tõendit;
- audiitorile antavat täielikku allkirjastatud logimanifesti.

Tavaline keskne logiserver aitab vigu uurida, kuid ei ole iseenesest muutmiskindel
tõend.

## 11. Eemaldatud teenuse sertifikaadi usaldust ei saa tühistada

Kogumisteenuse haldusjuhend ütleb otse, et eemaldatud teenuse isendi usalduse
tühistamiseks vastavat meetodit ei kasutata, sest selle rakendamine oleks liiga
keeruline. Seetõttu tuleb vana teenuse isend füüsiliselt või administratiivselt täielikult
kõrvaldada. Vastasel juhul võib see edasi töötada ja kogumisteenust häirida.

See on dokumentatsioonis endas tunnistatud arhitektuuriline risk. Valimissüsteemis
peaks teenuse identiteedi olema võimalik krüptograafiliselt tühistada.

## 12. Dokumentatsioon lubab muuta käivitatavat programmi

E-hääletamise käsiraamat lubab vajadusel muuta `mix.py` failis logimistaseme
`INFO` asemel `DEBUG`. Sellega muutub käivitatava programmi hash.

Samas ei nõuta kohustuslikult:

- muudatuse vormistamist patch’ina;
- vana ja uue faili hash’i;
- muudatuse sõltumatut kinnitamist;
- muudetud faili allkirjastamist;
- selle lisamist valimiste tarkvaramanifesti.

Valimistel kasutatud programmi ei tohi muuta lihtsalt käsitsi nii, et tõendusahel
katkeb.

## Kokkuvõte

IVXV dokumentides on olemas mitmed tugevad krüptograafilised ja korralduslikud
kontrollid. Kuid puudub üks terviklik tõendusahel, mis seoks omavahel:

**avaliku lähtekoodi, sõltumatu build’i, ametliku tarne, paigaldatud binaarfailid,
lõplikud konfiguratsioonid, protseduurid ja avaldatud tulemuse.**

Kõige olulisemad parandused oleksid:

1. avaldada iga valimise täielik allkirjastatud tarkvara- ja seadistusmanifest;
2. muuta kogu IVXV release reprodutseeritavalt build’itavaks;
3. võrrelda sõltumatu build’i hash’e ametliku tarne ja tootmismasinate failidega;
4. laiendada kohustuslik audit tarkvara vastuvõtule, paigaldusele, andmekandjatele,
   snapshot’idele ja taastamisele;
5. kehtestada kriitilistes toimingutes kahe inimese reegel;
6. teha logid muutmiskindlaks;
7. määrata üheselt, mis juhtub iga läbikukkunud kontrolli korral;
8. avaldada kõik juhendid ühe kooskõlalise ja versioonitud dokumendikomplektina.

See ei tõenda valimispettust. See tõendab, et praegune dokumentatsioon ei võimalda
sõltumatul osapoolel kogu süsteemi ja valimistel kasutatud tarkvara otsast lõpuni
tõendada.
