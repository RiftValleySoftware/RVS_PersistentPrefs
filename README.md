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

This class allows you to have an "implicit" global state that is accessed by simply instantiating a subclass, and you can associate "top-level keys" to instances, to maintain multiple sets of persistent preferences.

REQUIREMENTS
-
RVS_PersistentPrefs is an [Apple Foundation](https://developer.apple.com/documentation/foundation)-based resource. It will work equally well on all Apple development platforms ([iOS](https://www.apple.com/ios), [iPadOS](https://www.apple.com/ipados), [macOS](https://www.apple.com/macos), [tvOS](https://www.apple.com/tvos), [watchOS](https://www.apple.com/watchos)). It will not work on non-Apple platforms, and is not designed to support anything other than native [Swift](https://apple.com/swift) development.

INSTALLATION
-
You can fetch the latest version of RVS_PersistentPrefs from [its GitHub repo](https://github.com/RiftValleySoftware/RVS_PersistentPrefs).

The class consists of [one single Swift source file](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_Persistent_Prefs/RVS_PersistentPrefs.swift). All the other stuff in the project is for project support and testing.

Simply copy [this file](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_Persistent_Prefs/RVS_PersistentPrefs.swift) into your project, and add it to your current [Swift](https://apple.com/swift) native target.

IMPORTANT IMPLEMENTATION NOTES
-
**Thread Safety**

There is none. Deal with it and move on. I'll be looking to fix that (if I can) in the future, but it isn't a critical enough requirement at the moment to justify preventing release of the utility.

Because of the nature of the utility (a "quick and dirty" persistent save for small amounts of -usually- user-interface-linked data), thread safety is not a critical need. I am making a point of mentioning it, though, so you don't spend too much time searching under the cushions, if you come across inconsistent dealloc crashes. There is a commented-out test in the [RVS_Persistent_Prefs_Thread_Tests.swift](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_Persistent_Prefs_Tests/RVS_Persistent_Prefs_Thread_Tests.swift#L158) file. If you uncomment it, and run it repeatedly, you will eventually run into the issue. You can also jack up the number of tests to increase the likelihood of running into the issue.

It doesn't need to be on the main thread, but it shouldn't be called from different threads.

**Must Be Subclassed**

The implementation needs to be a concrete subclass of RVS_PersistentPrefs. At bare minimum, you need to override the `keys: [String]` calculated property, to return an `Array` of `String`, containing the internal keys. You might also override the `key` stored property, but it's probably easier to just set the base class one in an `init`.

**Data Stored Is Typeless**

Remember that the internal storage of the data is a `Dictionary<String, Any>`. That means that the storage almost acts like a loosely-typed language. You can change the data type of a stored `Dictionary` value, simply by changing the type you give to it.

If you are a PHP programmer, that's great. Not so great, if you are a Swift programmer.

One of the jobs of a subclass is to hide this typelessness behind accessors that cast the stored data into consistent types.

**All Stored Data Must Be XML-Plist-Compatible**

Since the ultimate storage "bucket" for our persistent data is in [a plist](https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html#//apple_ref/doc/uid/TP40009254-SW1), all data types, anywhere in the hierarchy of stored data nees to be in a form that can be serialized into an XML form. Most ObjC (NS and CF) classes can be stored in a plist, and you can usually store opaque types by rendering them into a [`Data`](https://developer.apple.com/documentation/foundation/data) value, and returning that via an [`NSCoding`](https://developer.apple.com/documentation/foundation/nscoding) implementation.

The RVS_PersistentPrefs class wil "vet" your data before attempting to save it. If it detects any plist-incompatible data, it will not save the data, and will set the `lastError` property to `valuesNotPlistCompatible`, which will have associated data. That data will be an `Array` of `String`, containing the top-level keys of the offending elements (remember that you can store a hierarchy, but the error will only report the top level of the hierarchy).

**You Must Use the Keys Provided by the `keys: [String]` Calculated Property**

You cannot submit data using a key that is not listed in the `keys: [String]` calculated property. If you attempt to do so the `lastError` property will be set to `incorrectKeys`, which will have associated data. That data will be an `Array` of `String`, containing the incorrect top-level keys.

**Does Not Throw**

The RVS_PersistentPrefs class does not throw. However, internally, it does. It also provides [an error enum](https://riftvalleysoftware.github.io/RVS_PersistentPrefs/Classes/RVS_PersistentPrefs/PrefsError.html), containing the errors that it will put into the `lastError` property, if there was an error.

You should check `lastError` for problems. It will be nil, if there are none.

**KVO**

Although not required, it's a good idea to make the subclass [Key-Value Observant](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift). You do this by writing accessor calculated properties, and declaring them `@objc dynamic`. RVS_PersistentPrefs derives from [NSObject](https://developer.apple.com/documentation/objectivec/nsobject), so there should be no issues.

In some of the included test harness apps, we will use KVO.

USAGE
-

TEST HARNESS PROJECTS
-
There are a number of included test harness applications. These cover iOS/iPadOS, macOS, watchOS and tvOS.

**All Apps Are Localizable**

The test harness apps are all complete, production-quality apps, designed to demonstrate release-quality implementation of the preferences class. They are localizable, and written as "ship-quality" apps.

**Common Preferences File**

All the test harnesses will share [the same Preferences Subclass](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/blob/master/RVS_PersistentPrefs_Common_Files/RVS_PersistentPrefs_TestSet.swift). This is a fairly simple variant that has the following data types:

* An Integer *(key: "Integer Value")*.

* A String *(key: "String Value")*.

* An Arry of String *(key: "Array Value")*.

* A Dictionary of String-keyed Any *(key: "Dictionary Value")*.

* A [Date](https://developer.apple.com/documentation/foundation/date) Object *(key: "Date Object")*.

It presents [Key-Value Observable](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_key-value_observing_in_swift) accessors for all of these values, which are directly used in the macOS test harness.

**The iOS Test Harness**

[The iOS Test Harness App](https://github.com/RiftValleySoftware/RVS_PersistentPrefs/tree/master/RVS_PersistentPrefs_iOS_TestHarness) is a very simple one-screen app that presents direct interface to edit and view the values in the common prefs instance. Additionally, it gives a simple demo of using a [Settings Bundle](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/Preferences/Preferences.html) to show a "Preferences Pane" in the Settings App.

The iOS test harness also integrates a watchOS test harness that shares the preferences instance with the device app.
