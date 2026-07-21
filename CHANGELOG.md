# Changelog

## [0.15.0](https://github.com/Samplasion/gymtracker/compare/v0.14.1...v0.15.0) (2026-07-21)


### Features

* add simple workout view ([2a0955f](https://github.com/Samplasion/gymtracker/commit/2a0955f05967a636e58d0aebe8e21b5b252f6f28))
* Apple Watch app overhaul ([8ad2cdd](https://github.com/Samplasion/gymtracker/commit/8ad2cddeb31f4c1de7b244f40127a905fcb2b54c))
* Enable Siri integration on the iOS side in order to support starting a routine from Siri. ([6c21c93](https://github.com/Samplasion/gymtracker/commit/6c21c9391dcf4fda41989c2786c9d0badadec1c7))
* sync workout state with native bridges ([e2f7470](https://github.com/Samplasion/gymtracker/commit/e2f7470ce689ef9c5f3ad27b58db9520bcf685b8))
* **tests:** Expand and enhance testing suite for GymTracker application ([fd9a51e](https://github.com/Samplasion/gymtracker/commit/fd9a51ede709ae69a33fc2c6023cc66bb1e2f598))


### Bug Fixes

* Android APK build ([0c5858d](https://github.com/Samplasion/gymtracker/commit/0c5858d4865dd95d9edf6d1f466c3c143a724ae0))
* App crashes when finishing workouts in simple mode ([52c5d0d](https://github.com/Samplasion/gymtracker/commit/52c5d0da20e5588b1cfd98ea3cc1ed8a55d3a9a6))
* auto-updating density chart ([ee113fb](https://github.com/Samplasion/gymtracker/commit/ee113fb583a5c1374eb6df1135cc427e46ee8be9))
* Fix DensityChart widget for visualizing workout data ([0cd633e](https://github.com/Samplasion/gymtracker/commit/0cd633e77a39dab1ece98dce5b119f65241effaa))
* Routines named with an empty string crash the app ([b3a6c5a](https://github.com/Samplasion/gymtracker/commit/b3a6c5a797d5df95d4004181ac5c3a63f2be1a18))
* set editor on watch goes into infinite loop ([8602985](https://github.com/Samplasion/gymtracker/commit/8602985c64944c7580a08ec8c41243ad610c144e))
* Update density widget at midnight and slide in the past, not in the future ([61dfbd9](https://github.com/Samplasion/gymtracker/commit/61dfbd954872edc199cec68d842f1af071dbf14a))
* WorkoutController not found ([a86eb9a](https://github.com/Samplasion/gymtracker/commit/a86eb9a5940d998758fa655558833eea9011c2b0))


### Miscellaneous Chores

* Backtrack release please version to fix changelog generation ([6bd487c](https://github.com/Samplasion/gymtracker/commit/6bd487cef0809bd634d0c0e3280bc26fa42b04c4))
* Fix version number ([51bdb52](https://github.com/Samplasion/gymtracker/commit/51bdb52fdf9639c5f585f44b5b7a9810af4fe20a))


### Continuous Integration

* Allow manual release please runs ([a4f894e](https://github.com/Samplasion/gymtracker/commit/a4f894ecc93efb26248fe89d3c9c94b8c894879f))

## [0.14.1](https://github.com/Samplasion/gymtracker/compare/v0.13.1...v0.14.1) (2025-12-26)


### Features

* Add timer and improve workout set handling on watchOS ([c8c3d06](https://github.com/Samplasion/gymtracker/commit/c8c3d064e6ccfea0d72b3cbb9d906ef3b4817825))
* Add watchOS complications and more iOS widgets ([d4aa917](https://github.com/Samplasion/gymtracker/commit/d4aa91729bed3afdee15db93e05b71958f9f2bc0))
* Android live progress notification ([d320cfd](https://github.com/Samplasion/gymtracker/commit/d320cfd7b37786ebde4c960aa0f0637ea8462605))
* Dynamic Island and iOS Widget ([cdfdbf2](https://github.com/Samplasion/gymtracker/commit/cdfdbf25139614ff1a0d78ed2c88251c3562277b))
* watchOS App ([cdab8e2](https://github.com/Samplasion/gymtracker/commit/cdab8e2298f7ef26c48f233d809afb051eb38a4a))


### Bug Fixes

* Add searched foods to the selected category ([519dbc8](https://github.com/Samplasion/gymtracker/commit/519dbc899b77441ccdc0eaef4b0a8ea51828c082))
* Avoid crashing if notification permissions are requested twice. ([384ecc4](https://github.com/Samplasion/gymtracker/commit/384ecc4109d7ae73174c5638a6e57b723e6f2dc7))
* Disable Muscles view until we have a different SVG ([5f445b7](https://github.com/Samplasion/gymtracker/commit/5f445b7abca9b25e196dd3af186f944bf73eb4fb))
* Don't show fake data when OpenFoodFacts server errors out ([7464a2d](https://github.com/Samplasion/gymtracker/commit/7464a2d7a53a776a1cceff61727301185aa23a07))
* Don't sync exercise data in a UI frame ([f563971](https://github.com/Samplasion/gymtracker/commit/f563971ebf3f068d548090e3008c23648cd14807))
* Next set returns the correct set in supersets ([1604585](https://github.com/Samplasion/gymtracker/commit/1604585229205d5c974aaaa8c15d2df65f7537a5))
