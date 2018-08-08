# SecretSharing

This project demonstrates how to share secrets between two iOS devices.

## Compilation

First, check out the project:

```sh
git clone …
cd SecretSharing/
git submodule update --init --recursive
```
The file `SecretSharing.xcodeproj` can be opened with Xcode for compilation of the demo app.

In order to compile the white paper with LaTeX​:

```sh
cd Article/
latexmk -pdf -interaction=nonstopmode -f article.tex
```

