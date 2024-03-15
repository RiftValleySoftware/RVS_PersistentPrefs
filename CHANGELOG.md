*Version 1.3.8* **March 15, 2024**
- Updated the privacy manifest to indicate that user preferences are being accessed.
- Updated to the latest tools.

*Version 1.3.7* **January 6, 2024**
- I didn't completely get rid of SwiftLint. It's all gone, now.
- Added privacy declarations.

*Version 1.3.5* **September 20, 2023**
- Updated some Xcode settings. No API changes.
- Sigh... Looks like SwiftLint and Xcode 15 don't get along. I have to remove it...

*Version 1.3.4* **October 6, 2022**
- Updated a test harness dependency. No API changes.

*Version 1.3.3* **September 16, 2022**
- Updated tools and dependencies. No other API changes.

*Version 1.3.2* **July 10, 2022**
- Updated a dependency. No other API changes.

*Version 1.3.1* **May 31, 2022**
- Updated the testing dependency.

*Version 1.3.0* **May 31, 2022**
- Renamed, so the vestigial "dash" notation has been replaced (vestigial from when it was a dylib).

*Version 1.2.8* **May 13, 2022**
- Upped the version of the `RVS_Generic_Swift_Toolbox` test harness dependency. No changes to the module.

*Version 1.2.7* **January 28, 2022**
- Updated to latest tools. No functional or API changes.

*Version 1.2.6* **January 28, 2022**
- Added DocC Support. No functional or API changes.

*Version 1.2.5* **December 14, 2021**
- Updated to work with the latest toolchains.

*Version 1.2.4* **September 23, 2021**
- Updated to work with the latest toolchains.

*Version 1.2.3* **July 11, 2021**
- Removed the command-line runner, and replaced it with a proper framework target.
- Added code coverage to the tests.
- Tweaked the code slightly to remove an unnecessary precondition.

*Version 1.2.2* **June 16, 2021**
- Latest build system
- Updated to latest toolbox

*Version 1.2.1* **July 31, 2020**
- Switched structure to enable GitHub Swift Action

*Version 1.2.0* **July 5, 2020**
- Switched to static for SPM.

*Version 1.1.2* **June 25, 2020**
- Removed the toolbox dependency, as it is only used in the test harness.

*Version 1.1.1* **June 24, 2020**
- Switched SPM to use specific dependency versions.

*Version 1.1.0* **June 19, 2020**
- Switched over to use SPM.
- Made the main class "open."
- made a couple of properties open, as well.
- Made the `count` property public. It was not specified as such, and should have been.

*Version 1.0.6* **June 7, 2020**
- Changed a silly typo in a test variable name.
- Made a number of fairly fundamental changes to simplify the structure.
- Swapped out the Pods SwiftLint for an embedded executable.
- Switched the String extension to use the Carthage one.
- Added CODEOWNERS

*Version 1.0.5* **May 8, 2020**
- Very minor change to replace an antiquated self reference.
- The Mac test harness needed to have its window set as the initial controller.

*Version 1.0.4* **January 12, 2020**
- No operational changes. Added some extra documentation, and tweaked the README a bit.

*Version 1.0.3* **November 4, 2019**
- No operational changes. Only the project was updated, and the documentation was updated to include a section on using Carthage.

*Version 1.0.2* **October 1, 2019**
- Added support for deletion of the prefs, if the values Array is empty.
- Fixed an issue, where the values array was not being cleared before a load().

*Version 1.0.1* **September 1, 2019**
- Made the values Dictionary KVO-observable.
- Added the missing launchimage for the tvOS test harness.
- Added this file.

*Version 1.0.0* **August 24, 2019**
- Initial Release.
