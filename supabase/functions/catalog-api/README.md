# Catalog API

Endpoint per Gym Bro Catalog. `POST /functions/v1/catalog-api` con bearer token
Supabase ordinario. Verifica JWT e metadati correnti tramite Auth a ogni richiesta:
`is_admin === true` oppure `is_catalog_operator === true` in **app_metadata**.
Sessioni OAuth delegate sono escluse. L'identità inviata dal client è ignorata.
La RPC privilegiata ricontrolla i ruoli e blocca prodotto e autore durante le
scritture. Il solo ruolo operatore non concede accesso ad `admin-api`.

Richiede `20261027130000_catalog_operators.sql`. La funzione usa i secret server
standard `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY`; il client usa solo la chiave
pubblica. Nessuna assegnazione di ruoli avviene dal client.

| operation | Campi aggiuntivi | Risposta |
|---|---|---|
| session | — | id, email, isAdmin |
| list | offset (default 0), search o barcode facoltativi | rows (50), inclusi canEdit e status |
| detail | id | prodotto e canEdit |
| requests | offset (default 0) | sole richieste dell'utente, con esito e nota admin |
| create | food, operationId UUID | id e version |
| update | id, version, food, note, operationId | id e nuova version |
| remove | id, version, note, operationId | id e nuova version |
| propose | id, version, kind update/remove, food per update, note, operationId | id richiesta e status pending |

`food` segue `gymbro_food.definition`: nutrienti per 100 g/ml, sei nutrienti
obbligatori, nutrienti facoltativi null se sconosciuti. Non accetta provenienza OFF.
Le note devono essere stringhe non vuote, massimo 1.500 caratteri. Riutilizzare lo
stesso `operationId` e lo stesso payload per ritentare una scrittura dall'esito
incerto. Un UUID riutilizzato con dati diversi viene rifiutato.

Autore sconosciuto o account cancellato: revisione admin. Autore noto: admin,
autore stesso e operatori che intervengono su articoli di utenti attualmente non
operatori possono modificare/rimuovere direttamente. Le modifiche non trasferiscono
la paternità. Promozioni e revoche sono lette dai metadati attuali. Le rimozioni
impostano `removed`; nessuna cancellazione fisica dal catalogo.

Le richieste restano pending fino alla decisione admin. `admin-api` espone
`list/detail` con `section: catalogRequests` e `operation: catalogReview` con
`id`, `approve` booleano, `note`, `operationId` facoltativo. Solo l'approvazione
applica la proposta; richiede ancora la versione originale e un prodotto non
rimosso. Una richiesta obsoleta può essere rifiutata, ma non applicata.

Errori sanitizzati: 400 dati, 401 sessione, 403 permessi, 404 assente,
409 versione superata/duplicato/conflitto, 413 richiesta troppo grande, 500 servizio.
In caso di conflitto ricaricare e riesaminare il prodotto.

## Preparazione e verifica

Assegnare `app_metadata.is_catalog_operator = true` tramite Supabase Auth Admin,
preservando gli altri metadati. Gli admin esistenti accedono senza questo flag.
Applicare la migrazione e distribuire `catalog-api` e `admin-api` separatamente.
La configurazione `verify_jwt = false` è intenzionale: gli handler verificano il JWT.

```sh
deno check supabase/functions/catalog-api/index.ts supabase/functions/admin-api/index.ts
deno test supabase/functions/catalog-api/handler_test.ts supabase/functions/admin-api/handler_test.ts
BACKEND_TEST_FILTER=food_catalog bash tools/test_sync_v2_backend.sh
```

La suite SQL include la matrice dei permessi, promozioni/revoche, attribuzione degli
inserimenti da Gym Bro, account eliminati, proposte obsolete, idempotenza, audit e
assenza di accesso diretto alla RPC tramite JWT utente. Usa un database Docker
locale temporaneo e non contatta Supabase remoto.
