# CafeEase ☕📱

**CafeEase** je inovativna aplikacija koja modernizuje naručivanje hrane i pića u kafićima, omogućavajući korisnicima pregled menija, kreiranje narudžbi, pregled historije narudžbi, upravljanje profilom i korištenje programa lojalnosti. Za kafiće, aplikacija omogućava upravljanje menijem, praćenje narudžbi, zaliha, izvještaje i promocije.

## 🔐 Pristupni podaci

### Desktop verzija
- Korisničko ime: `desktop`
- Lozinka: `test`

### Mobilna verzija
- Korisničko ime: `mobile`
- Lozinka: `test`

## 🛠️ Tehnologije

- Backend: ASP.NET Core WebAPI (C#)
- Frontend: Flutter (Desktop i Mobile)
- Baza podataka: SQL Server
- Mikroservisi: Glavni API i Pomoćni servis (RabbitMQ, Docker)

## 💳 Stripe plaćanje (test režim)
Aplikacija koristi Stripe za kartično plaćanje u testnom režimu.

### 🛠  Konfiguracija 
Konfiguracijski fajl `.env` nije uključen u repozitorij jer sadrži osjetljive podatke. U repozitoriju se nalazi `.env.example`, koji služi kao šablon za potrebne konfiguracijske vrijednosti.

#### Koraci za lokalno pokretanje:

1. Pozicionirati se u folder `CafeEase`
2. Kopirati `.env.example` u novi fajl `.env`
3. U `.env` upisati stvarne vrijednosti za bazu i Stripe test ključeve
4. Pokrenuti aplikaciju pomoću Docker Compose-a

Primjer strukture `.env` fajla:
```env
DB_NAME=your_database_name
MSSQL_SA_PASSWORD=YourStrongPassword123!
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
```

Za finalnu predaju stvarni `.env` fajl nalazi se u šifrovanoj arhivi `.env-tajne.zip` u folderu `CafeEase`. Šifra arhive dostavlja se putem DLWMS sistema. `.env` i `.env-tajne.zip` ne uključuju se u ZIP arhivu sa build fajlovima na GitHub Release-u.

Plaćanje se vrši putem Stripe PaymentSheet interfejsa.

### 🧪 Test podaci za plaćanje
 Za testiranje plaćanja koristiti sljedeću test karticu:
  - Broj kartice: 4242 4242 4242 4242
  - Datum isteka: bilo koji budući datum (npr. 12/29)
  - CVC: bilo koja 3 broja (npr. 123)
  - Postal code / ZIP: bilo kojih 5 brojeva (npr. 71000)

  Plaćanje se inicijalno kreira sa statusom `Pending`, a nakon uspješne Stripe potvrde prelazi u `Completed`, dok narudžba dobija status `Paid`.

> [!NOTE]  
> Ne vrši se stvarna naplata, transakcije su simulirane unutar Stripe testnog okruženja.

## 🚀 Pokretanje aplikacije (Docker)

Backend aplikacija (Web API, SQL Server i RabbitMQ) pokreće se pomoću **Docker Compose-a**.

### Koraci:
 
1. Pozicionirati se u folder `CafeEase`:
 ```powershell
 cd CafeEase
 ```

2. Pokrenuti aplikaciju:
```powershell
docker compose up --build
```

3. Nakon uspješnog pokretanja:
    - API je dostupan na adresi: http://localhost:5003/swagger
    - Baza podataka se automatski kreira prilikom prvog pokretanja koristeći Entity Framework Core migracije i seed podatke

4. Zaustavljanje aplikacije:
```powershell
docker compose down
```

## 💻 Klijentske aplikacije
Desktop aplikacija se pokreće pomoću .exe fajla

Mobilna aplikacija se pokreće pomoću .apk fajla

 ⚠️ Klijentske aplikacije zahtijevaju da backend bude prethodno pokrenut putem Dockera.

Klijentski buildovi dostupni su u GitHub Release-u. Desktop aplikacija koristi `http://localhost:5003/`, dok mobilna aplikacija na Android emulatoru koristi `http://10.0.2.2:5003/`.


## Recommender sistem
Recommender sistem u aplikaciji CafeEase generiše preporuke proizvoda na osnovu historije narudžbi korisnika. Sistem analizira koje se stavke često naručuju zajedno i na osnovu toga kreira preporuke koje se pohranjuju u bazu podataka i prikazuju korisnicima u aplikaciji. Preporučeni proizvodi se prikazuju korisnicima u Flutter aplikaciji. Recommender sistem se trenira na osnovu postojećih narudžbi i ne koristi eksterni ML framework. Uz svaku preporuku prikazuje se i objašnjenje zašto je proizvod preporučen, npr. zato što se često naručuje zajedno sa odabranim proizvodom ili je među najčešće naručivanim proizvodima.
Detaljna dokumentacija dostupna je u fajlu [recommender-dokumentacija.md](recommender-dokumentacija.md).
