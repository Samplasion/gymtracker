# Screenshot App Store

Dalla root del progetto:

```sh
fvm install
fvm flutter pub get
python3 -m venv tools/screenshots/.venv
tools/screenshots/.venv/bin/pip install -r tools/screenshots/requirements.txt
cd ios
bundle install
bundle exec fastlane ios screenshots
```

Richiede Xcode con runtime iOS e watchOS installati, il tipo di dispositivo
**iPhone 16 Pro Max** e **Apple Watch Series 10 (46mm)**, e il progetto iOS
compilabile e almeno 2 GiB liberi su disco. Il primo avvio di un nuovo simulatore può richiedere alcuni minuti.
I simulatori `GymBro Screenshots iphone` e `GymBro Screenshots watch` sono dedicati
alla lane: vengono creati se assenti, abbinati e spenti al termine. Non vengono
cancellati o usati i simulatori personali. I runtime vengono selezionati tra quelli
installati, dal più recente; devono supportare l'abbinamento iPhone/Watch.

## Cartella unica degli output

Tutti gli script salvano sotto `build/screenshots/` (ignorata da Git), prima per
sistema operativo e poi per dispositivo:

```text
build/screenshots/
├── ios/
│   ├── iphone/
│   ├── ipad/
│   ├── duo-outer/
│   └── duo-inner/
├── watchos/
│   └── apple-watch/
├── android/
│   ├── phone/
│   ├── tablet7/
│   ├── tablet10/
│   └── _emulators/     # dati temporanei e log AVD
└── wearos/
    └── watch/
```

Le cartelle dispositivo mantengono `raw/`, `final/`, `proofs/` e `logs/`.
I profili Duo compaiono quando vengono effettivamente catturati. Lo script
`capture_wear.py` conserva le catture standalone in `wearos/watch/raw/<locale>/`;
i metadati testuali dello store Wear restano in `docs/wear-os/store/`.

I percorsi sono centralizzati in `tools/screenshots/paths.py`. Per migrare gli
output delle versioni precedenti senza ricatturare o ricomporre:

```sh
tools/screenshots/.venv/bin/python tools/screenshots/migrate_outputs.py
```

La migrazione conserva i file originali, può essere ripetuta e verifica tutti i
conflitti prima di spostare file. Un file diverso già presente a destinazione
interrompe l'operazione senza sovrascriverlo.

## Comandi

Da `ios/`:

```sh
bundle exec fastlane ios screenshots                         # 18 composizioni
bundle exec fastlane ios screenshots locale:it only:02       # una schermata
bundle exec fastlane ios screenshots stage:capture           # sole catture
bundle exec fastlane ios screenshots stage:compose           # sole cornici
bundle exec fastlane ios screenshots locale:en only:01,09
```

`locale` accetta `it`, `en`, `all`; `only` accetta gli ID a due cifre separati da
virgole oppure `all`; `stage` accetta `capture`, `compose`, `all`.
Una selezione parziale non cancella le immagini delle altre schermate. Le catture
e le composizioni precedenti della selezione vengono rimosse prima della nuova
cattura: un errore non può produrre un risultato apparentemente aggiornato usando
quelle vecchie. La composizione autonoma usa intenzionalmente le catture salvate.

Output (ignorati da Git) in `build/screenshots/ios/iphone/`:

- `raw/it/`, `raw/en/`: catture originali; `09-watch-watch.png` è la cattura watchOS.
- `final/it/`, `final/en-US/`: PNG RGB verticali **1206 × 2622**, ordinati per nome.
  Le catture originali iPhone restano native 1320 × 2868; il formato finale è
  definito da `presets.iphone.output` nel manifesto. La composizione viene adattata
  mantenendo le proporzioni dei dispositivi.
- `proofs/it.jpg`, `proofs/en.jpg`: provini delle immagini finali disponibili.
- `logs/`: un log Flutter per lingua ed esecuzione.

La lane non richiede chiavi App Store, non carica nulla e non incrementa build o
versione. Il font è Noto Sans Bold, già incluso in `assets/fonts/`, con licenza
SIL Open Font License in `assets/fonts/OFL.txt`. Cornici e bagliori vengono
disegnati localmente dal compositore: nessun asset grafico remoto.

## Lane Apple Watch

```sh
cd ios
bundle exec fastlane ios watch_screenshots
bundle exec fastlane ios watch_screenshots locale:it
bundle exec fastlane ios watch_screenshots stage:compose
```

La sequenza comprende **sette schermate per lingua**: allenamento, routine,
modifica serie, note, calorie, nutrienti e acqua. Le immagini sono RGB native
**416 × 496**, senza cornice o testo promozionale.

```sh
bundle exec fastlane ios watch_screenshots locale:it only:03,07
bundle exec fastlane ios watch_screenshots stage:capture
bundle exec fastlane ios watch_screenshots stage:compose
```

`locale`, `only` e `stage` funzionano come nella lane iPhone; gli ID Watch sono
indipendenti e vanno da `01` a `07`. Gli output sono separati in
`build/screenshots/watchos/apple-watch/`: `raw/it/` e `raw/en/` conservano le catture
native e la cattura iPhone intermedia necessaria alla sincronizzazione;
`final/it/` e `final/en-US/` contengono sette PNG ciascuna; `proofs/` e `logs/`
contengono provini e diagnostica. Una cattura parziale mantiene gli altri output.

La lane trasferisce allenamento, catalogo e diario tramite WatchConnectivity.
Per ogni vista verifica dati dell'esecuzione corrente, lingua e disponibilità
prima della cattura; un timeout interrompe la lane senza riutilizzare la cattura
precedente. La selezione diretta delle viste esiste esclusivamente in debug. Le catture
usano il titolo breve della serie e la variante compatta del componente nutrienti
per mostrarne tutti e tre i gruppi; le altre presentazioni dell’app restano invariate.
Il tempo del diario viene fissato tramite il clock del modello, solo nella vista
di cattura. `stage:compose` riesporta gli originali senza modificare la barra
di stato o l’orologio. I simulatori e gli output iPhone restano separati.
La sequenza è descritta in [WATCH_PLAN.md](WATCH_PLAN.md).

## Contenuti e manutenzione

`manifest.json` è la fonte dei titoli, delle interruzioni di riga, dei colori,
dell'ordine e delle dimensioni. Il runner passa il manifesto al test Flutter;
il compositore legge lo stesso file. Non eliminare le interruzioni esplicite:
un titolo che supera lo spazio disponibile genera un errore, non viene ritagliato.

Le fixture in `integration_test/screenshots/` usano un database in memoria e
contenuti bilingui. L'entrypoint di produzione non importa le fixture. Il test
monta le schermate reali con il tema reale e sostituisce i servizi remoti.
La data è 1 novembre 2026, ore 09:41, e la durata dell'allenamento mostra 24 minuti. Il cronometro personalizzato è
disattivato: la barra superiore mostra il titolo Allenamento/Workout.
La variabile di lancio `SIMCTL_CHILD_GYMBRO_SCREENSHOTS=1` impedisce le richieste HealthKit native solo nella build di debug.
La modalità Watch `--screenshots` è disponibile solo in debug e fornisce valori
demo fissi per tempo e metriche. Il trasferimento dell'allenamento è effettuato
tramite WatchConnectivity e il runner verifica ID e colore ricevuti prima della
cattura. Nessun allenamento HealthKit viene avviato dal flusso screenshot.
Il compositore non disegna barre di stato, orologi, batterie, icone di rete o
Dynamic Island e non ritocca le aree corrispondenti delle catture. Sul Watch resta
l’orologio nativo presente nell’originale, con l’ora reale della cattura; le 09:41
rimangono il riferimento dei dati demo. Gli originali restano inalterati.

Per aggiungere una schermata: inserire ID, nome, seed e titoli nel manifesto,
aggiungere la vera pagina e le relative fixture al test, aggiornare gli ID
ammessi dal driver se si supera 09, quindi verificare entrambe le lingue.
Per aggiungere una vista Watch: inserire ID e nome in `watch_screenshots` nel
manifesto e aggiungere il relativo caso in `ScreenshotSceneView` (solo debug).
Estendere i dati trasferiti e le condizioni di disponibilità se la nuova vista
richiede altri contenuti. Barre di stato e controlli di sistema vengono conservati
come catturati, senza ricostruirli nel compositore.

Per iPad, Android e Duo usare i profili dedicati descritti sotto; le catture
iPhone non possono sostituire quelle native di questi dispositivi.

## Verifica

```sh
fvm flutter analyze integration_test/app_store_screenshots_test.dart integration_test/screenshots test_driver/screenshots.dart
fvm flutter test test/screenshots/fixtures_test.dart
tools/screenshots/.venv/bin/python -m unittest discover -s tools/screenshots -p 'test_*.py'
bash tools/test_watch_food.sh
```

Dopo la lane completa controllare i provini e le 18 immagini a dimensione reale:
lingua, colore, dati, titoli, tastiera nascosta, grafici caricati, assenza di
indicatori di caricamento e coerenza tra telefono e orologio. La disponibilità dei
runtime e WatchConnectivity richiedono una prova sul Mac che esegue la lane.

## Android, tablet e iPhone Duo

La suite usa catture reali per ogni dispositivo, lo stesso profilo demo bilingue,
lo stesso tema scuro e gli stessi colori. Le immagini iPhone e Watch già esistenti
restano nelle rispettive cartelle. Nessun caricamento e nessun incremento di build.

| Profilo | Cattura nativa verticale | Output verticale | Schermate per lingua |
|---|---|---|---|
| Android telefono | 1080 × 2400 | 1080 × 1920, composizione | 01, 02, 04–09 |
| Android tablet 7″ | 1200 × 1920, 600 dp di larghezza | 1440 × 2560, UI senza titoli | 01–08 |
| Android tablet 10″ | 1600 × 2560, 800 dp di larghezza | 1440 × 2560, UI senza titoli | 01–08 |
| iPad Pro 13″ M4 | 2064 × 2752 | 2064 × 2752, composizione | 01–08 |
| iPhone Duo esterno | 1398 × 2034 | 1398 × 2034, composizione | 01–08 |
| iPhone Duo interno | 2007 × 2853 | 2007 × 2853, composizione | 01–08 |

Android telefono esclude Progressi (03), su scelta concordata, per rispettare il
massimo di otto screenshot Google Play. La nona composizione usa la UI Wear OS
reale in debug, con Panca piana/Bench press, 8 × 72,5 kg, 24 minuti, 132 bpm,
164 kcal e colore ciano. Tutti i tablet e i due profili Duo escludono 09.

I tablet Android usano l'interfaccia nativa senza titoli promozionali, inserita
senza deformazioni in un output 9:16. Non viene ridimensionata una cattura del
telefono per simulare il tablet. La piccola letterbox nera conserva l'intera UI.

Da `android/`:

```sh
bundle exec fastlane android screenshots                       # telefono
bundle exec fastlane android screenshots device:tablet7
bundle exec fastlane android screenshots device:tablet10
bundle exec fastlane android screenshots device:all
bundle exec fastlane android screenshots device:tablet7 locale:it only:01,05
bundle exec fastlane android screenshots device:all stage:compose
```

Richiede Android SDK, emulator, platform-tools, cmdline-tools e le immagini
`system-images;android-37.0;google_apis_playstore;arm64-v8a` e, per la schermata
telefono 09, `system-images;android-30;android-wear;arm64-v8a`.
Il runner compila il modulo Wear in debug e aggiorna i plugin Flutter di test
prima delle catture Android (una precedente build release può averli esclusi).
Servono almeno 9 GiB liberi per la sequenza telefono con Wear OS e 4 GiB
per gli altri profili; gli emulatori telefono e Wear vengono avviati in sequenza.
Gli AVD vengono creati solo in `build/screenshots/android/_emulators/`, con nomi dedicati
e porte 5580/5582/5584 (telefono/tablet) e 5578 (Wear OS). Se una porta è occupata, la lane si ferma invece di
fermare emulatori personali. I dati temporanei degli AVD sono eliminati alla
chiusura per non accumulare gigabyte; i log e tutti gli screenshot rimangono.

Da `ios/`:

```sh
bundle exec fastlane ios screenshots device:ipad
bundle exec fastlane ios screenshots device:ipad locale:it only:01,05
bundle exec fastlane ios screenshots device:duo-outer simulator:UUID
bundle exec fastlane ios screenshots device:duo-inner simulator:UUID
bundle exec fastlane ios screenshots device:all stage:compose
```

Per Duo servono Xcode 27.1, un runtime iOS 27.1 o successivo e il supporto per
il simulatore iPhone Duo. Preparare in Device Hub simulatori dedicati chiamati
`GymBro Screenshots duo-outer` e `GymBro Screenshots duo-inner`, nella posa/display
corrispondente. La lane li cerca per nome; `simulator:UUID` consente una selezione
esplicita dello stesso dispositivo dedicato. La lane rifiuta simulatori personali o di tipo
diverso e verifica le dimensioni effettive prima di comporre. Il Mac di sviluppo
attuale ha iOS 27.0: la cattura Duo non è verificabile finché non viene installato
il runtime richiesto. Non sono prodotti screenshot Duo riciclati da iPhone/iPad.

Output sotto `build/screenshots/<sistema>/<dispositivo>/`, con `raw/it/`, `raw/en/`,
`final/it/`, `final/en-US/`, `proofs/` e `logs/`. `locale`, `only` e `stage` hanno
lo stesso significato delle lane esistenti. La composizione autonoma funziona
senza SDK/emulatori, ma richiede le catture originali del profilo esatto.

Per aggiungere un dispositivo: aggiungere il preset in `device_profiles` nel
manifesto, specificando dimensioni reali, output, selezione e presentazione;
aggiungere l'alias alla lane pertinente e controllare catture e provini reali.

Fonti ufficiali:

- [Dimensioni Apple, compresi i due display Duo e iPad 13″](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).
- [Supporto iPhone Duo e Xcode 27.1](https://developer.apple.com/iphone-duo/prepare/).
- [Google Play: massimo otto screenshot, tablet e formato 9:16](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en).

### Navigazione nelle catture

La suite riusa `appRouterProvider` e la `ShellRoute` di produzione: routine (02),
alimentazione (04) e feed (07) includono la barra inferiore o la navigazione
laterale in base alla larghezza effettiva del dispositivo. Il drawer sui telefoni rimane chiuso,
come durante il normale utilizzo. Allenamento e dettagli del profilo vengono
aperti sopra la sezione di origine, con il comportamento a tutto schermo e il
ritorno indietro previsti dall’app. Le destinazioni sviluppatore (Debug e Logs)
sono escluse tramite override, come nelle build pubblicate. Lo stato dell’allenamento viene azzerato tra
le catture per evitare barre di sessioni residue.

La composizione Android 09 usa una cattura reale Wear OS da 480 × 480 pixel,
con la UI corrente e la fixture `app_store` (ciano, 72,5 kg, timer fermo).
`workout_fixture.rest_seconds` nel manifesto fissa il recupero condiviso a 90
secondi: la suite Flutter ne verifica il valore visualizzato e quella Wear OS
attende `01:30` nella UI prima di catturare.
