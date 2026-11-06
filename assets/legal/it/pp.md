# Informativa sulla Privacy

**Ultimo Aggiornamento:** 6 novembre 2026

La presente Informativa sulla Privacy spiega come **TECHTONIC FAULT** ("noi", "nostro" o "noi") raccoglie, utilizza e protegge le tue informazioni quando utilizzi l’applicazione Gym Bro (l’"App"), il suo sito web e le integrazioni ufficialmente supportate, compresi i collegamenti ad assistenti IA come ChatGPT.

## 1. Architettura di Trattamento dei Dati e Infrastruttura
Gym Bro è progettata con un'architettura incentrata sulla riservatezza dei dati:
* **Predefinita in Locale (Local-First):** Per impostazione predefinita, tutti i registri di allenamento, i piani alimentari, le metriche e gli esercizi personalizzati creati nell'App sono memorizzati unicamente sul tuo dispositivo.
* **Funzionalità Cloud Opzionali:** Le funzionalità online basate sull’account, comprese la registrazione dell'account, la sincronizzazione cloud tra più dispositivi, il feed amici e i collegamenti agli assistenti IA supportati, sono completamente **opzionali (opt-in)**. Se scegli di attivare queste funzionalità, i tuoi dati vengono elaborati e conservati tramite **Supabase** in qualità di nostro fornitore di database e infrastruttura backend. Supabase tratta i dati dell’applicazione per nostro conto per fornire questi servizi backend; la presente informativa spiega come Gym Bro utilizza tali dati. Per ulteriori informazioni sulle pratiche di Supabase, consulta la sua [Informativa sulla Privacy](https://supabase.com/privacy), l’[Accordo sul trattamento dei dati](https://supabase.com/legal/customer-resources/data-processing-addendum) e le [informazioni sulla localizzazione e conservazione dei dati](https://supabase.com/legal/privacy-resources/data-residency-and-transfers-faq).

## 2. Informazioni che Raccogliamo
A seconda di come interagisci con l'App, potremmo raccogliere o trattare le seguenti categorie di dati:

### A. Dati di Salute e Fitness Memorizzati in Locale
* **Dati su Allenamento e Nutrizione:** Tipologie di esercizio, pesi, ripetizioni, registri delle serie, nomi di esercizi personalizzati, diari alimentari e valori nutrizionali salvati sul dispositivo.

### B. Dati di Account, Sincronizzazione e Social (Funzionalità Cloud Opzionali)
Quando registri un account e attivi la sincronizzazione cloud o il feed amici:
* **Credenziali di Account:** Indirizzo e-mail, nome utente e identificativi di autenticazione per proteggere il tuo account e sincronizzare i dati tra i tuoi dispositivi.
* **Feed Amici e Dati Social:** Riepiloghi degli allenamenti, nomi degli esercizi personalizzati e metriche di completamento che scegli di condividere con le tue connessioni o amici approvati all'interno dell'App.
* **Dati su Allenamento e Nutrizione:** Copie delle tipologie di esercizio, pesi, ripetizioni, registri delle serie, nomi di esercizi personalizzati, diari alimentari e valori nutrizionali vengono memorizzate nel cloud per la sincronizzazione tra dispositivi e per la condivisione con gli amici, se scegli di attivare queste funzionalità.

### C. Diagnostica, Prestazioni e Segnalazioni di Problemi
Utilizziamo **Sentry** per segnalazioni di arresti anomali ed errori, monitoraggio delle prestazioni, registri diagnostici e registrazioni campionate delle sessioni per comprendere i malfunzionamenti e migliorare l’App. Questi dati possono includere informazioni sul dispositivo e sul sistema, tracce degli errori, eventi di navigazione o interazione e rappresentazioni registrate dell’interfaccia. Le segnalazioni non sono necessariamente anonime o aggregate. L’App disabilita la raccolta predefinita di informazioni identificative personali di Sentry e configura il mascheramento dei grafici sensibili; queste misure non garantiscono che ogni elemento diagnostico sia privo di dati personali.

Se invii una segnalazione di problema, la descrizione e l’eventuale nome o indirizzo email che scegli di fornire vengono trattati per analizzare il problema e rispondere. Non includere password o informazioni sanitarie non necessarie nelle segnalazioni. Consulta l’[Informativa sulla Privacy di Sentry](https://sentry.io/privacy/) per ulteriori informazioni sul fornitore. Puoi disattivare l’invio dei dati diagnostici a Sentry, incluse le registrazioni campionate delle sessioni, da **Impostazioni → Avanzate → Invia dati diagnostici a Sentry**. La scelta ha effetto immediato, viene salvata sul dispositivo e viene rispettata agli avvii successivi. La disattivazione non elimina i dati già inviati; contattaci per informazioni sulle tue scelte e sui tuoi diritti in materia di privacy.

### D. Acquisti In-App e Fatturazione
L'elaborazione dei pagamenti per gli abbonamenti e le licenze perpetue a vita è gestita direttamente dai fornitori delle piattaforme (es. Apple App Store o Google Play Store). Non memorizziamo né elaboriamo i dati delle tue carte di pagamento sui nostri sistemi. Utilizziamo **RevenueCat** per gestire e verificare i diritti di accesso derivanti dagli acquisti, compreso l’accesso Free o Pro dell’account Gym Bro collegato. Ciò comporta il trattamento dell’identificativo dell’account e delle informazioni sugli acquisti o sui diritti di accesso. Consulta l’[Informativa sulla Privacy di RevenueCat](https://www.revenuecat.com/privacy/).

### E. Collegamenti ad Assistenti IA (Opzionali)
Quando autorizzi un assistente IA supportato a collegarsi al tuo account Gym Bro e richiedi un’azione, Gym Bro invia al fornitore dell’assistente le informazioni recuperate per quell’azione. A seconda della richiesta, queste possono includere definizioni di esercizi, schede, allenamenti salvati, riepiloghi dell’attività, diario alimentare e dati nutrizionali, registrazioni dell’acqua bevuta, peso e misurazioni corporee, nonché limiti del piano dell’account. Il collegamento richiede un account autenticato e utilizza il backend Gym Bro ospitato su Supabase.

Quando chiedi all’assistente di salvare informazioni supportate, i dati risultanti vengono aggiunti al tuo account Gym Bro. Questi dati vengono gestiti come i corrispondenti dati creati nell’App, anche per sincronizzazione, conservazione e cancellazione dell’account. Il collegamento a un assistente non abilita azioni non supportate, come eliminare registrazioni o controllare un allenamento in corso.

Il fornitore dell’assistente IA tratta la conversazione e i dati ricevuti secondo i propri termini, la propria informativa sulla privacy e le impostazioni applicabili all’account. Consultali prima del collegamento, soprattutto quando richiedi l’accesso a informazioni sul fitness o sulla salute. Gym Bro non determina la conservazione o l’utilizzo indipendente dei dati della conversazione da parte di tale fornitore.

Puoi revocare il collegamento tramite i controlli disponibili nell’account o nel servizio collegato. La revoca interrompe gli accessi futuri quando l’autorizzazione cessa di avere effetto; un token di accesso già emesso può rimanere valido fino alla scadenza. Scollegare l’assistente non elimina i dati già salvati in Gym Bro o le informazioni già ricevute dal suo fornitore. Per gestire queste ultime, utilizza i controlli sui dati del fornitore o contattalo direttamente.

### F. Registri Operativi e di Sicurezza
Gym Bro e i suoi fornitori di infrastruttura trattano registri operativi e di sicurezza per fornire il servizio, analizzare i malfunzionamenti e proteggere gli account. A seconda del servizio e della configurazione, questi registri possono includere orari delle richieste, metadati di rete e delle richieste, stati delle risposte ed eventi di sicurezza o di errore. La registrazione degli errori applicativi del collegamento contiene un’etichetta del servizio, un’etichetta dell’evento e un codice di errore, senza includere in quella voce il prompt o il contenuto della richiesta o della risposta dello strumento. I registri dell’infrastruttura sono separati e sono soggetti alla configurazione del servizio e ai periodi di conservazione applicabili del fornitore.

I registri operativi necessari a fornire e proteggere i servizi online sono separati dalla diagnostica dell’App. Le informazioni sulla privacy e sull’infrastruttura di Supabase indicate nei collegamenti forniscono ulteriori dettagli sul suo trattamento e non sostituiscono la presente informativa di Gym Bro.

### G. Funzionalità Salute e Orologi
Con le autorizzazioni pertinenti del dispositivo o della piattaforma, Gym Bro interagisce con i servizi salute supportati su telefono e orologio, tra cui Apple Health/HealthKit e Android Health Connect. A seconda della piattaforma e della funzionalità attivata, legge informazioni sugli allenamenti, frequenza cardiaca ed energia attiva, mostra metriche dell’allenamento in tempo reale e scrive le registrazioni degli allenamenti supportate. Puoi gestire l’accesso ai dati salute tramite i controlli delle autorizzazioni della piattaforma. Revocare un’autorizzazione non elimina di per sé i dati già salvati o le copie nell’archivio salute della piattaforma.

### H. Trainer e Contributi al Catalogo Alimentare Pubblico
Quando utilizzi le funzionalità per trainer, trattiamo i rapporti tra trainer e clienti, le proposte di piani di allenamento e le revisioni, nonché le informazioni sugli allenamenti che scegli di condividere con un trainer collegato. Il servizio utilizza queste informazioni per consegnare i piani e consentire al trainer di consultare gli allenamenti autorizzati. Usa i controlli disponibili di condivisione e scollegamento per gestire gli accessi futuri; interrompere la condivisione non permette di recuperare le copie già ricevute da altri.

Se invii esplicitamente una definizione di alimento o una correzione al catalogo condiviso, il nome del prodotto, la marca, il codice a barre, i valori nutrizionali e le informazioni sulle porzioni possono essere pubblicati per altri utenti. I contributi al catalogo sono separati dal tuo diario alimentare privato e dalla sincronizzazione cloud. Le definizioni dei prodotti e le correzioni pubblicate possono rimanere disponibili dopo la cancellazione dell’account. Le segnalazioni di moderazione e le informazioni di audit sono trattate per gestire il catalogo. Non inserire informazioni personali nei campi pubblici dei prodotti.

I fornitori di infrastruttura e diagnostica possono trattare informazioni fuori dal tuo Paese, anche al di fuori del SEE. Le informative e gli accordi sul trattamento indicati nei collegamenti descrivono le localizzazioni e le garanzie pertinenti; contattaci per informazioni sui trasferimenti applicabili ai tuoi dati.

---

## 3. Basi Giuridiche del Trattamento (Conformità al GDPR UE)
Se risiedi nello Spazio Economico Europeo (SEE), le nostre basi giuridiche per il trattamento dei tuoi dati ai sensi del Regolamento Generale sulla Protezione dei Dati (GDPR) sono:
* **Consenso e Attivazione Volontaria:** La creazione dell’account non costituisce di per sé consenso a ogni utilizzo dei dati. Le condivisioni facoltative, i collegamenti IA e l’accesso ai dati salute del dispositivo dipendono dalle scelte e dalle autorizzazioni che esprimi per tali funzionalità. Quando il consenso è la base giuridica applicabile, compreso il consenso esplicito ove richiesto per i dati sulla salute, riguarda la specifica finalità del trattamento. I collegamenti IA facoltativi si attivano separatamente quando autorizzi il collegamento e richiedi azioni supportate; la sola creazione dell’account non li abilita. Puoi revocare il consenso in qualsiasi momento, anche revocando un collegamento facoltativo. La revoca non pregiudica la liceità del trattamento precedente.
* **Esecuzione di un Contratto:** Trattamento necessario a fornire l’account e le funzionalità online che richiedi, comprese la sincronizzazione e le integrazioni supportate, e a completare gli acquisti o ripristinare le licenze a pagamento. Restano applicabili gli ulteriori requisiti per i dati sulla salute, ove pertinenti.
* **Legittimo Interesse:** Trattamento di dati tecnici, operativi e di sicurezza per proteggere il servizio, analizzare i malfunzionamenti e fornire le funzionalità. Ciò non elimina gli eventuali requisiti di consenso applicabili a una specifica attività di trattamento di dati diagnostici o sulla salute.

---

## 4. I Tuoi Diritti in Materia di Privacy
In base alla legge applicabile, puoi chiedere l’accesso, la rettifica, la cancellazione, la limitazione del trattamento o una copia portabile dei tuoi dati personali, opporti ai trattamenti basati sul legittimo interesse e revocare il consenso quando il trattamento si basa su di esso. Contattaci ai recapiti indicati sotto. Puoi inoltre presentare un reclamo all’autorità di controllo competente; in Italia si tratta del [Garante per la protezione dei dati personali](https://www.garanteprivacy.it/). Questi diritti sono soggetti alle condizioni e alle eccezioni previste dalla legge applicabile.

### Informativa sul California Consumer Privacy Act (CCPA/CPRA)
Per i residenti in California:
* **Nessuna Vendita o Condivisione di Informazioni Personali:** **Non vendiamo** né **condividiamo** (per finalità di pubblicità comportamentale tra contesti diversi) le tue informazioni personali o i tuoi dati sulla salute a terze parti.
* **I Tuoi Diritti:** Hai il diritto di richiedere l'accesso ai dati personali in nostro possesso, di chiederne la cancellazione e di opporci a qualsiasi raccolta di dati non essenziale.

---

## 5. Conservazione e Cancellazione dell'Account e dei Dati
* **Dati locali:** La disinstallazione normalmente rimuove i dati locali dell’App da quel dispositivo. I file esportati, i backup del dispositivo o del sistema operativo, le copie sull’orologio, i dati nelle piattaforme salute e i dati cloud sono separati e non vengono necessariamente rimossi. Gestisci tali copie tramite i rispettivi controlli.
* **Cancellazione dell'account cloud e dei dati:** Se hai creato un account cloud, puoi richiedere la cancellazione dell’account e dei dati cloud privati associati dalle impostazioni dell’App o dalla pagina web dell’account. I contributi al catalogo pubblicati e le copie conservate separatamente descritte sotto non vengono rimossi automaticamente da questa azione. La pagina dell’account si trova all’indirizzo:
  <https://gym-bro.techtonicfault.com/account>
* **Dati salvati tramite integrazioni:** Ai dati salvati tramite un collegamento IA si applicano gli stessi controlli di conservazione e cancellazione dell’account. Eliminare l’account Gym Bro non elimina le conversazioni o le copie conservate indipendentemente dal fornitore dell’assistente IA.
* **Registri operativi e di sicurezza:** La conservazione dipende dalla categoria del registro, dalla configurazione del servizio e dai periodi applicabili del fornitore di infrastruttura, tenendo conto delle esigenze operative, di sicurezza e di risoluzione dei problemi. La cancellazione dell’account non comporta necessariamente la rimozione immediata dei registri operativi esistenti o delle copie di backup, che restano soggetti al ciclo di conservazione e cancellazione applicabile. Consulta le informazioni di Supabase indicate nei collegamenti per le sue pratiche infrastrutturali, oppure contattaci per informazioni sui tuoi dati.
* **Diagnostica e segnalazioni di problemi:** La conservazione segue la configurazione del servizio diagnostico e i periodi applicabili del fornitore, secondo le esigenze di risoluzione dei problemi, prestazioni e assistenza. Questi dati sono separati dai dati sincronizzati dell’account; contattaci per esercitare i tuoi diritti su una segnalazione o altre informazioni personali.


---

## 6. Contatti e Titolare del Trattamento
Per richieste sulla privacy o per esercitare i tuoi diritti sui dati:
* **Titolare del Trattamento:** TECHTONIC FAULT (Gestito da Francesco Arieti, Italia)
* **Contatto:** `support@techtonicfault.com`
