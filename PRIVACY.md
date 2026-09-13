# Privacy Declaration

RVS_PersistentPrefs stores the preferences supplied by its caller in `UserDefaults`. The library does not collect analytics, track users, send information over the network, or log preference contents.

`UserDefaults` is unencrypted preference storage. Applications should keep passwords, authentication tokens, and other secrets in the Keychain. When an App Group suite is selected, other members of that group can access the shared preferences. Applications remain responsible for the information they choose to store and how they use it.

The [privacy manifest](Sources/RVS_PersistentPrefs/PrivacyInfo.xcprivacy) is included in the Swift package's resource bundle and the Xcode framework. It declares `UserDefaults` access for app-local preferences (`CA92.1`) and preferences shared within an App Group (`1C8F.1`), following [Apple's required-reason API documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). For direct source integration, include the manifest in the app's resources or incorporate the applicable declarations into its existing manifest.

The repository and published documentation are hosted by GitHub, whose services are covered by [GitHub's Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement).
