# OCRHelper

A Basic helper to aply [Optical Character Recognition](https://en.wikipedia.org/wiki/Optical_character_recognition) process to an image to get the text.

This package is compatible with MacOS, TvOS, iOS, ipadOS and WatchOS.

# How to use

This package only have the class **OCRHelper**.

### How to get the supported languages

```
let languages: [String] = OCRHelper.supportedLanguages
```

**Note:** if the array is empty the recognition system is not allowed.

### How to get text from an image

There are functions for CGImage, UIImage and NSImage formats.

```
let myImage = // type your code here to get an image
OCRHelper.recognice(cgImage: myImage, 
    languages: ["es-es", "en-us"],
    level: .accurate,
    completed: { result, error in
    guard let result = result else { return }
    for item in result {
        print(item)
    }
})
```

**Note:** The params language and level are optionals.


## Author

This package was developed by Jonathan Chacón .

Please, if you have any question or suggestion you can contact me at [Tyflos Accessible Software](https://www.tyflosaccessiblesoftware.com) web site.

## Contributing

Pull requests are welcome. Feel free to create pull requests for any kind of improvements, bug fixes or enhancements. For major changes, please open an issue first to discuss what you would like to change.

## License

This software was published under the [MIT license](https://choosealicense.com/licenses/mit/)
