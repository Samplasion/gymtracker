# Design

This document describes the design of the Gym Bro app, including its
architecture, components, and interactions. It serves as a reference for
developers and contributors to understand the structure and functionality of the
application.

## Table of Contents

- [Design](#design)
  - [Table of Contents](#table-of-contents)
  - [Architecture](#architecture)
    - [Services](#services)
    - [Repositories](#repositories)
    - [Native-Flutter messaging](#native-flutter-messaging)
      - [Shadow Routines](#shadow-routines)
  - [Meta](#meta)

## Architecture

### Services

Services are the base layer of the app's architecture, responsible for talking
to the underlying data sources, such as databases and APIs. Each service is
responsible for a specific feature of the app, but they are only accessed by
[Repositories](#repositories), such as the `ProtocolService` being used by the
various repositories to handle deep links.

### Repositories

Repositories represent the middle layer between the data sources (e.g.,
databases, APIs) and the application logic. They provide a clean API for
accessing and manipulating data, abstracting away the underlying data source
details. While this role was originally filled by Controller classes, the app
has started a refactoring process to replace them with Repositories, which are
more aligned with the principles of Clean Architecture: this transition is
ongoing, and the app will continue to evolve as more features are added and the
architecture is refined.

### Native-Flutter messaging

#### Shadow Routines

Shadow routines are small messages stored on the native side, which are used to
represent a routine on the Flutter side. These are primarily used by the iOS
Siri shortcuts integration, which needs to know a list of routines to display
to the user for the "Start Routine" intent. A shadow routine is stored in the
format:

```json
{
  "id": "string",
  "name": "string"
}
```

## Meta

This document is meant to be updated as the app evolves. As of today, it is a
work in progress and, while it reflects the current state of the app,
it is not complete. It is expected that this document will be updated as the app
evolves and new features are added.