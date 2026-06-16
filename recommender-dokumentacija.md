# Sistem preporuke — CafeEase App

## Pregled

CafeEase aplikacija koristi recommender sistem za preporuku proizvoda korisnicima na osnovu prethodnih narudžbi i proizvoda koji se često naručuju zajedno.

## Podaci koji ulaze u recommender

Sistem koristi podatke iz tabela `Orders` i `OrderItems`.

| Signal | Opis |
|--------|------|
| Narudžba proizvoda | Korisnik je naručio određeni proizvod |
| Zajedničko naručivanje | Dva proizvoda se često pojavljuju u istoj narudžbi |

## Algoritam

Recommender analizira proizvode koji se često naručuju zajedno. Za odabrani proizvod pronalazi druge proizvode koji su se pojavljivali u istim narudžbama.
Za svaki proizvod sistem čuva i vraća najviše tri preporučena proizvoda sa najvećim `Score` vrijednostima.

## Score

`Score` predstavlja koliko često se preporučeni proizvod pojavio zajedno sa odabranim proizvodom u prethodnim narudžbama.

Veći score znači da se proizvod češće naručivao zajedno i zato ima veći prioritet u preporukama.

## Objašnjenje preporuka

Uz svaki preporučeni proizvod vraća se i tekstualno objašnjenje, npr:

`Preporučeno jer se često naručuje zajedno sa Espresso.`

## Endpointi

Recommender je dostupan kroz `RecommendationsController`.

Relevantni endpointi su:

- `GET /Recommendations/{id}/recommended`
- `POST /Recommendations/train`
- `DELETE /Recommendations/clear`

Administrativni endpointi za treniranje i brisanje preporuka zaštićeni su admin autorizacijom.

## Prikaz u aplikaciji

Preporuke se prikazuju u mobilnoj aplikaciji u sekciji `Recommended for you`, zajedno sa nazivom proizvoda, cijenom i objašnjenjem preporuke.

## Ograničenja

- Kvalitet preporuka zavisi od broja postojećih narudžbi.
- Ako nema dovoljno podataka, sistem vraća fallback preporuke.
- Sistem trenutno koristi narudžbe i stavke narudžbi, a ne koristi dodatne karakteristike proizvoda kao što su kategorija ili opis.
