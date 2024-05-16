# Logging

This table shows the different log levels and their meanings:

|         | Build   | Console | High priority | When To Use                                                                                                                                                                     |
| ------- | ------- | ------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Fatal   | Debug   | ✓       |               | An error occurred that crashed the app.                                                                                                                                         |
|         | Release |         | ✓             |                                                                                                                                                                                 |
| Error   | Debug   | ✓       |               | Something bad has happened that should never happen. App is not crashing but a part of the functionality is not working. The situation should be reported.                      |
|         | Release |         | ✓             | E.g., a wrong JSON format, parsing errors when a source format is unsupported, some system service is not available but we expect it to be.                                     |
| Warning | Debug   | ✓       |               | Something bad has happened that can happen from time to time, it’s a normal behavior. Messages of that level are useful to understand the reason for a crash or an unclear bug. |
|         | Release |         |               | E.g., a network request fails due to the internet being off or login token expired.                                                                                             |
| Info    | Debug   | ✓       |               | Something expected happened. Messages of that level are useful to understand the reason for a crash or an unclear bug.                                                          |
|         | Release |         |               | E.g., a view controller is  presented or dismissed, user interactions, some service finished an initialization, a network request succeeded, a DB is saved successfully.        |
| Debug   | Debug   | ✓       |               | Messages of that level are useful to log sensitive information such as a network response content if it’s really needed.                                                        |
|         | Release |         |               | Such log messages should not litter the console.                                                                                                                                |
| Trace   | Debug   |         |               | Messages that are littering the console, should be manually turned on.                                                                                                          |
|         | Release |         |               | Also called verbose.                                                                                                                                                            |

[(Adapted from source)](https://medium.com/@kozhevnikoff/on-the-logging-in-mobile-applications-8f9b5538660d)
