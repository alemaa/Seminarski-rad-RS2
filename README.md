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

## 🚀 Pokretanje aplikacije (Docker)

Backend aplikacija (Web API, SQL Server i RabbitMQ) pokreće se pomoću **Docker Compose-a**.

### Koraci:

1. Pozicionirati se u root folder projekta

2. Pokrenuti sljedeću komandu:
    docker compose up --build

3. Nakon uspješnog pokretanja:
    - API je dostupan na adresi: http://localhost:5003/swagger
    - Baza podataka se automatski kreira prilikom prvog pokretanja koristeći Entity Framework Core migracije i seed podatke

4. Zaustavljanje aplikacije:
    docker compose down

## 💻 Klijentske aplikacije
Desktop aplikacija se pokreće pomoću .exe fajla

Mobilna aplikacija se pokreće pomoću .apk fajla

 ⚠️ Klijentske aplikacije zahtijevaju da backend bude prethodno pokrenut putem Dockera.

## Recommender sistem
Recommender sistem u aplikaciji CafeEase generiše preporuke proizvoda na osnovu historije narudžbi korisnika. Sistem analizira koje se stavke često naručuju zajedno i na osnovu toga kreira preporuke koje se pohranjuju u bazu podataka i prikazuju korisnicima u aplikaciji. Preporučeni proizvodi se prikazuju korisnicima u Flutter aplikaciji. Recommender sistem se trenira na osnovu postojećih narudžbi i ne koristi eksterni ML framework.
