![Icon](./icon.png)

RVS_PersistentPrefs
=
A general-purpose [Swift](https://apple.com/swift) class for making storing persistent preferences incredibly easy and transparent.

[Here is the technical documentation for this class.](https://riftvalleysoftware.github.io/RVS_PersistentPrefs/)

[Here is the  GitHub repo for this class.](https://github.com/RiftValleySoftware/RVS_PersistentPrefs).

OVERVIEW
-
RVS_PersistentPrefs is an "abstract" base class, designed to be subclassed *(Yes, I know. There's no such thing as an "abstract" class in Swift, but the class is designed to crash, if you instantiate it standalone)*.

Instances based on the class will have a simple, flexible [`Dictionary<String, Any>`](https://developer.apple.com/documentation/swift/dictionary) property. This will contain a set of values, stored on behalf of the derived subclass.

The base class also saves and retrieves the `Dictionary`, transparently, from [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults).

Each instance will also have a stored property, called `key`, which is a [`String`](https://developer.apple.com/documentation/swift/string), used to "key" the stored data.

This means that multiple instances of subclasses, based on RVS_PersistentPrefs, can track multiple sets of persistent data.

RVS_PersistentPrefs is designed for ease of use and reliability. It is **NOT** a class that is meant to store mission-critical, or large volumes, of data. It is merely a convenient way to maintain small amounts of persistent data, such as app preferences.

WHAT PROBLEM DOES THIS SOLVE?
-
Storing persistent data (data that survives an app being started and stopped, or even, in some cases, transfers between apps) has always been a somewhat fraught process in app development.

Luckily, Apple has provided an excellent mechanism for this, called [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults), which is part of the [Foundation](https://developer.apple.com/documentation/foundation) framework; meaning that it is supported by ALL Apple operating systems.

Saving and retrieving from [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults) is quite simple. You save and retrieve values in the same manner as you would a `String`-keyed `Dictionary`.

There is one major limitation, though: ALL stored data needs to be [XML plist-compatible](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html#//apple_ref/doc/uid/10000048i). This is usually not much of an issue, as there are plenty of types that work fine. The actual storage happens inside an [XML Plist](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html) file, so there needs to be support for stored types.

This class will "vet" the preferences before attempting to store them (otherwise, the system simply crashes), and will let you know if there's a problem. It also completely abstracts the actual interface with [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults), so all you need to worry about is interacting with a `Dictionary<String, Any>`.

Subclasses will also establish "allowed" keys, and can do things like translate the stored values into [Key-Value Observer](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift) properties, so you can set up a completely "codeless" connection between user interface and stored preferences.

This class you to have an "implicit" global state that is accessed by simply instantiating a subclass, and you can associate "top-level keys" to instances, to maintain multiple sets of persistent preferences.

REQUIREMENTS
-
RVS_PersistentPrefs is an [Apple Foundation](https://developer.apple.com/documentation/foundation)-based resource. It will work equally well on all Apple development platforms ([iOS](https://www.apple.com/ios), [iPadOS](https://www.apple.com/ipados), [macOS](https://www.apple.com/macos), [tvOS](https://www.apple.com/tvos), [watchOS](https://www.apple.com/watchos)). It will not work on non-Apple platforms, and is not designed to support anything other than native [Swift](https://apple.com/swift) development.

INSTALLATION
-
You can fetch the latest version of RVS_PersistentPrefs from [its GitHub repo](https://github.com/RiftValleySoftware/RVS_PersistentPrefs).

The class consists of [one single Swift source file](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_Persistent_Prefs/RVS_PersistentPrefs.swift). All the other stuff in the project is for project support and testing.

Simply copy [this file](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_Persistent_Prefs/RVS_PersistentPrefs.swift) into your project, and add it to your current [Swift](https://apple.com/swift) native target.

USAGE
-

**Thread Safety**

There is none. Deal with it and move on. I'll be looking to fix that (if I can) in the future, but it isn't a critical enough requirement at the moment to justify preventing release of the utility.

Because of the nature of the utility (a "quick and dirty" persistent save for small amounts of -usually- user-interface-linked data), thread safety is not a critical need.