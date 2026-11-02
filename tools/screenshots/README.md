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

Output (ignorati da Git) in `build/app_store_screenshots/`:

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
`build/app_store_watch_screenshots/`: `raw/it/` e `raw/en/` conservano le catture
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

Preset iPad e Android richiederanno layout e cattura specifici: non scalare
semplicemente le immagini iPhone; la promozione Watch va sostituita su Android.

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
