# Sequenza Apple Watch

## Scelte concordate

- Sequenza dedicata a watchOS, in italiano e inglese.
- Immagini native, senza titoli, sfondi o cornici promozionali.
- Apple Watch Series 10 da 46 mm: 416 × 496 pixel, PNG RGB.
- Tema scuro, dati demo riferiti alle 09:41, unità metriche e contenuti coerenti con iPhone.
- Barre di stato e orologio di sistema nativi, conservati senza ritocchi.
- Nessun caricamento, incremento di versione o accesso ai servizi reali.

Apple accetta 416 × 496 e richiede lo stesso formato per tutte le lingue:
https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/

## Sequenza: sette immagini per lingua

| ID | Vista reale | Stato da mostrare |
|---|---|---|
| 01 | Allenamento | Panca piana, 8 × 72,5 kg, 24 minuti, 132 bpm, 164 kcal e pulsanti di avanzamento. |
| 02 | Routine | Due cartelle e una routine nella radice, scaricate e disponibili offline. |
| 03 | Modifica serie | Peso e ripetizioni valorizzati; controlli nativi per modificarli. |
| 04 | Note esercizio | Una breve indicazione tecnica, localizzata, leggibile senza scorrere. |
| 05 | Calorie | 1141 kcal consumate, obiettivo 2400, 1259 rimanenti. |
| 06 | Nutrienti | Proteine, carboidrati e grassi con quantità e obiettivi coerenti con il diario iPhone. |
| 07 | Acqua | 1250 / 2500 ml e aggiunte rapide da 100, 250 e 500 ml abilitate. |

I colori semantici delle viste native rimangono riconoscibili, soprattutto per
nutrienti, acqua, battito e calorie. Tutti i nomi e le note demo sono tradotti.

## Implementazione

1. Aggiungere al manifesto una sezione Watch con ID, viste, dati richiesti e preset,
   indipendente dai nove ID iPhone.
2. Estendere le fixture condivise con la serie completa e modificabile (non solo
   la stringa riepilogativa), note tecniche, catalogo routine e dati
   nutrizionali per il Watch. Usare WatchConnectivity per i payload reali e
   verificare la ricezione di ciascun insieme di dati.
3. Aggiungere selezione della vista e segnale di disponibilità esclusivamente in
   debug, montando le viste SwiftUI esistenti. Controllare anche il tempo del
   modello alimentare, senza dipendere dalla data corrente del simulatore.
4. Per ogni lingua trasferire i dati una volta, poi catturare le sette viste dopo
   aver verificato contenuti, caricamento, animazioni e assenza di errori.
5. Estendere `ios watch_screenshots` con `only:01,02,...,07`; mantenere `locale` e
   `stage`, output separati e provini con le proporzioni native.
6. Verificare esattamente 14 PNG RGB 416 × 496, controllare tutti i provini e le
   immagini native, ripetere una cattura e provare esportazione autonoma e parziale.

## Uso

```sh
cd ios
bundle exec fastlane ios watch_screenshots
bundle exec fastlane ios watch_screenshots locale:it only:03,07
bundle exec fastlane ios watch_screenshots stage:compose
```

Output in `build/screenshots/watchos/apple-watch/`, separati dalle composizioni iPhone.
`raw/` conserva gli originali, `final/it/` e `final/en-US/` contengono i sette PNG
per lingua; `proofs/` contiene i provini. La cornice Watch dell'immagine iPhone 09
non viene usata nelle immagini native. Per preparazione e manutenzione consultare
[README.md](README.md).
