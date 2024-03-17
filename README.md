# GymTracker

[![Integration tests](https://github.com/Samplasion/gymtracker/actions/workflows/integration_test.yml/badge.svg)](https://github.com/Samplasion/gymtracker/actions/workflows/integration_test.yml) [![Unit tests](https://github.com/Samplasion/gymtracker/actions/workflows/test.yml/badge.svg)](https://github.com/Samplasion/gymtracker/actions/workflows/test.yml) [![CI Builds](https://github.com/Samplasion/gymtracker/actions/workflows/build.yml/badge.svg)](https://github.com/Samplasion/gymtracker/actions/workflows/build.yml)

A simple gym progress tracker app built with Flutter.

## Getting Started

You can build the app with the following command:

```bash
tools/build_android.sh
```

You can also download a pre-built APK from the
[releases](https://github.com/Samplasion/GymTracker/releases) page.

## URL Sharing

This application supports sharing and importing
routines with the `gymtracker://routine?json=<Base64 GZIP-compressed JSON string>`
protocol.