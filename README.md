# CafeEase

**CafeEase** je inovativna aplikacija koja modernizuje naručivanje hrane i pića u kafićima, omogućavajući korisnicima pregled menija, kreiranje narudžbi, pregled historije narudžbi, upravljanje profilom i korištenje lojalti programa. Za kafiće, aplikacija omogućava upravljanje menijem, praćenje narudžbi, zaliha, izvještaje i promocije.

## Pristupni podaci
### Desktop verzija
- Korisničko ime: `desktop`
- Lozinka: `test`
### Mobilna verzija
- Korisničko ime: `mobile`
- Lozinka: `test`

## Tehnologije
- Backend: ASP.NET Core WebAPI (C#)
- Frontend: Flutter (Desktop i Mobile)
- Baza: SQL Server
- Mikroservisi: Glavni API i Pomoćni servis (RabbitMQ, Docker)

 ## Migracije baze podataka
Zbog strukture rješenja sa više projekata (multi-project solution) Entity Framework migracije se moraju izvršavati iz CafeEase.Services projekta, dok CafeEase.WebAPI mora biti postavljen kao startup projekat.

## Pokretanje aplikacije
1. Pokrenuti SQL server
2. Postaviti CafeEase.WebAPI kao startup projekat
3. Izvršiti migracije iz CafeEase.Services projekta
4. Pokrenuti backend aplikaciju
5. Pokrenuti Flutter aplikaciju

## Recommender sistem
Recommender sistem u aplikaciji CafeEase generiše preporuke proizvoda na osnovu historije narudžbi korisnika. Sistem analizira koje se stavke često naručuju zajedno i na osnovu toga kreira preporuke koje se pohranjuju u bazu podataka i prikazuju korisnicima u aplikaciji. Preporučeni proizvodi se prikazuju korisnicima u Flutter aplikaciji. Recommender sistem se trenira na osnovu postojećih narudžbi i ne koristi eksterni ML framework.
