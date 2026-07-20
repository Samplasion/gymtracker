# Design

This document describes the design of the Gym Bro app, including its
architecture, components, and interactions. It serves as a reference for
developers and contributors to understand the structure and functionality of the
application.

## Table of Contents

- [Design](#design)
  - [Table of Contents](#table-of-contents)
  - [Architecture](#architecture)
    - [Native-Flutter messaging](#native-flutter-messaging)
      - [Shadow Routines](#shadow-routines)
  - [Meta](#meta)

## Architecture

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