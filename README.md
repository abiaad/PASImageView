# PASImageView
============

**Rounded async imageview downloader lightly cached and written in Swift 2.0 **

[Objective-C version here](https://github.com/abiaad/PAImageView)

## Snapshot

![Snapshop PASImageView](https://raw.github.com/abiaad/pasimageview/master/snapshot.gif)

## Usage

```swift
//XIB or directly by code

var imageView = PASImageView(frame: aFrame)
imageView.backgroundProgressColor(UIColor.whiteColor())
imageView.progressColor(UIColor.redColor())
self.view.addSubview(imageView)
// Later
 imageView.imageURL(anURL)
```

**That's all**

## Contact

[Pierre Abi-aad](http://github.com/abiaad)
[@abiaad](https://twitter.com/abiaad)

## License

PASImageView is available under the MIT license.
