![Icon](./icon.png)

RVS_PersistentPrefs
=
A general-purpose class for storing persistent preferences in the application bundle.

[Here is the Technical Documentation for this class.](https://riftvalleysoftware.github.io/RVS_PersistentPrefs/)

OVERVIEW
-
RVS_PersistentPrefs is an "abstract" base class, designed to be subclassed *(yes, I know. There's no such thing as an "abstract" class in Swift, but the class is designed to crash, if you instantiate it standalone)*.

Instances based on the class will have a simple, flexible [`Dictionary<String, Any>`](https://developer.apple.com/documentation/swift/dictionary) property. This will contain a set of values, stored on behalf of the derived subclass.

The base class also saves and retrieves the `Dictionary`, transparently, from [`UserDefaults`](https://developer.apple.com/documentation/foundation/userdefaults).

Each instance will also have a stored property, called `key`, which is a [`String`](https://developer.apple.com/documentation/swift/string), used to "key" the stored data.

This means that multiple instances of subclasses, based on RVS_PersistentPrefs, can track multiple sets of persistent data.

RVS_PersistentPrefs is designed for robustness and reliability. It is **NOT** a class that is meant to store missin-critical data, or large volumes of data. It is merely a convenient way to maintain persistent data, such as app preferences.

INSTALLATION
-
You can fetch the latest version of RVS_PersistentPrefs from [its GitHub repo](https://github.com/RiftValleySoftware/RVS_PersistentPrefs).

The class consists of [one single Swift source file](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_Persistent_Prefs/RVS_Base_PersistentPrefs.swift). All the other stuff in the project is for project support and testing.

Simply copy this file into your project, and add it to your current target.