# SecretSharing (iOS Demo)

This project demonstrates how to share secrets between two iOS devices using QR codes. The goal is to exchange information without the need of using network, bluetooth, or NFC connections, while an adversary is observing the displays of the devices, e.g., shoulder surfer, surveillance camera.

<img src="https://raw.githubusercontent.com/AppPETs/SecretSharing-iOS/master/Artilcle/figures/mockup@3x.png" height="400px" width="798px" alt="Mockup of the user interface of the demo application."/>

For details about the mechanism, see the [white paper](https://github.com/AppPETs/SecretSharing-iOS/master/Article/article.pdf).

## Compilation

First, check out the project:

```sh
git clone --recursive https://github.com/AppPETs/SecretSharing-iOS.git
```
The file `SecretSharing.xcodeproj` can be opened with Xcode for compilation of the demo app.

In order to compile the white paper with LaTeX:

```sh
cd Article/
latexmk -pdf -interaction=nonstopmode -f article.tex
```

