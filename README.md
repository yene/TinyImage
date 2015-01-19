# TinyImage
TinyImages uploads your selected images to tinypng.com and puts a compressed version into your Download folder.

## setup
set api key from https://tinypng.com/developers:
```
defaults write com.yannickweiss.TinyImage apiKey KEYHERE
```

## TODO
* error messages for
* look & feel more like imageoptim

## Source & Credit
* curl -i --user api:YOUR_API_KEY --data-binary @large.png https://api.tinypng.com/shrink
* https://tinypng.com/developers/reference
* Inspired from https://imageoptim.com/