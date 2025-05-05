<p align="center">
    <img src="https://img.shields.io/badge/Swift-6.0-red.svg" />
    <img src="https://codecov.io/gh/michaelversus/SwiftImportChecks/graph/badge.svg?token=K8H49TQ6SZ"/>
</p>

# 📦 SwiftImportChecks

This is a tool that enforces only explicitly declared dependencies are imported.
Swift build provides the `--explicit-target-dependency-import-check` flag but unfortunatelly it is not available with `xcodebuild`.

## 💡 Suggestion

- Use the above tool as a pre-commit hook to avoid increasing your build time.

## 🛠️ Instalation

- Remove existing tap if present (ignore this if you never tapped michaelversus/formulae before):
`brew untap michaelversus/formulae`
- Add tap again
`brew tap michaelversus/formulae`
- Install
`brew install michaelversus/formulae/swiftimportchecks`

## ⚙️ Command line flags
### Required:
- `-r`

## 📖 Usage


## 🤝 Contributions

Contributions are more than welcome!
