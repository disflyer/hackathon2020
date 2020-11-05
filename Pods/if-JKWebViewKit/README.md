<p align="center">
   <img width="200" src="https://raw.githubusercontent.com/SvenTiigi/SwiftKit/gh-pages/readMeAssets/SwiftKitLogo.png" alt="JKWebViewKit Logo">
</p>
<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="http://cocoapods.org/pods/JKWebViewKit">
      <img src="https://img.shields.io/cocoapods/v/JKWebViewKit.svg?style=flat" alt="Version">
   </a>
   <a href="http://cocoapods.org/pods/JKWebViewKit">
      <img src="https://img.shields.io/cocoapods/p/JKWebViewKit.svg?style=flat" alt="Platform">
   </a>
   <a href="https://github.com/Carthage/Carthage">
      <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>
</p>

# JKWebViewKit

The out-of-the-box WebViewController you want.

## Features

- [x] Basic ViewController that you can push/present
- [x] JikeHybrid injected
- [x] Wechat-like progress bar
- [x] Wechat-like provider host label underneath the webview

### maybe features

- [ ] Wechat-like history navigation toolbar
- [ ] Centered loading indicator for progress `0..<0.5`
- [ ] Loading progress callback
- [ ] Up-to-date UserActivity
- [ ] Embeded mode, which allows you to use the JKWebViewController().view as a subview on any of your views
- [ ] Extendable JKHybridCallbackHandlerProtocol
- [ ] Extendable right navigation item menu
- [ ] Long press image on webpage

## Example

The example application is the best way to see `JKWebViewKit` in action. Simply open the `JKWebViewKit.xcodeproj` and run the `Example` scheme.

## Installation

### CocoaPods

JKWebViewKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod 'if-JKWebViewKit'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

To integrate JKWebViewKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Arthur Wang/JKWebViewKit"
```

Run `carthage update` to build the framework and drag the built `JKWebViewKit.framework` into your Xcode project.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase” and add the Framework path as mentioned in [Carthage Getting started Step 4, 5 and 6](https://github.com/Carthage/Carthage/blob/master/README.md#if-youre-building-for-ios-tvos-or-watchos)

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/iftechio/JKWebViewKit.git", from: "1.0.0")
]
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate JKWebViewKit into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## UI Usage

1. Integrate it with the way you prefer
2. `import JKWebViewKit` , of course
3. Instantiate  

```swift
let con = JKWebViewController(url: URL(string: "https://github.com/iftechio")!)
```

3. You may want to navigate to other url later

```swift
con.load(url: URL(string: "https://github.com/")!)` to navigate
```

## Hybrid Usage

- Choose a early state of app

```swift
let hybridHandler = JKAlHybridHandler() // or JKHybridHandler
hybridHandler.register()
hybridHandler.enableHybridHandlers()
```

- 4 Built-in actions
    - `request_headers`
    - `rg_close`
    - `rg_toast`
    - `rg_open_webview`

- For changing behaviors of built-in actions, you can
    1. Subclass `JKHybridHandler` or `JKAlHybridHandler`, depends on which layer of WebViewController you're using. 
    2. Override these 4 methods.

- For adding new app-wise actions, you can
    1. Subclass `JKHybridHandler` or `JKAlHybridHandler`, depends on which layer of WebViewController you're using. 
    2. Override `reigster` and `enableHybridHandlers`, add your own actions just like how built-in actions do.
    3. Strongly suggetion to add separate method for your new actions so it would be easier to inherit from and override.


## Contributing
Contributions are very welcome 🙌

## License

```
JKWebViewKit
Copyright (c) 2020 iftech arthraim@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```


