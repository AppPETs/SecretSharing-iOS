# SecretSharing (iOS Demo)

This project demonstrates how to share secrets between two iOS devices using QR codes. The goal is to exchange information without the need of using network, bluetooth, or NFC connections, while an adversary is observing the displays of the devices, e.g., shoulder surfer, surveillance camera.

<img src="https://raw.githubusercontent.com/AppPETs/SecretSharing-Whitepaper/master/figures/mockup%403x.png" height="798px" width="400px" alt="Mockup of the user interface of the demo application."/>

For details about the mechanism, see the [white paper](https://github.com/AppPETs/SecretSharing-Whitepaper) [[Download PDF](https://github.com/AppPETs/SecretSharing-Whitepaper/releases/download/v1.0.0/article.pdf)].

## Compilation

First, check out the project:

```sh
git clone --recursive https://github.com/AppPETs/SecretSharing-iOS.git
```
The file `SecretSharing.xcodeproj` can be opened with Xcode for compilation of the demo app.
