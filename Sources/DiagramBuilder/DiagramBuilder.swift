//
//  DiagramBuilder.swift
//  SwiftImportChecks
//
//  Created by Michalis Karagiorgos on 11/5/25.
//

protocol DiagramBuilderProtocol {
    func append(package: SwiftPackageFile)
    func generateDiagram()
}

final class DiagramBuilder: DiagramBuilderProtocol {
    let packagesPath: String
    var packages: [SwiftPackageFile]
    let configs: Configurations
    let echo: (String) -> Void

    init(
        packagesPath: String,
        packages: [SwiftPackageFile] = [],
        configs: Configurations,
        echo: @escaping (String) -> Void = { msg in print(msg) }
    ) {
        self.packagesPath = packagesPath
        self.packages = packages
        self.configs = configs
        self.echo = echo
    }

    func append(package: SwiftPackageFile) {
        packages.append(package)
    }

    func generateDiagram() {
        guard
            !packages.isEmpty,
            let diagrams = configs.diagrams
        else { return }
        if let regularLayers = diagrams.regular?.layers {
            generateRegularDiagram(layers: regularLayers)
        }
    }

    private func generateRegularDiagram(layers: [String]) {
        guard !layers.isEmpty else { return }
        let regularTargetsSorted = packages
            .flatMap { $0.targets }
            .filter { $0.type == .regular && $0.layerNumber != nil }
            .sorted { $0.layerNumber! < $1.layerNumber! }
        guard !regularTargetsSorted.isEmpty else { return }
        var diagramContent = "<html>\n"
        diagramContent += tabs("<body>", count: 1)
        diagramContent += tabs("<pre class=\"mermaid\" align=\"center\">", count: 2)
        diagramContent += tabs("architecture-beta", count: 3)
        for layer in layers {
            diagramContent += tabs(
                "group \(layer.lowercased())(vscode-icons:file-type-swift)[\(layer)]",
                count: 4
            )
            diagramContent += tabs(
                "junction _\(layer.lowercased()) in \(layer.lowercased())",
                count: 4
            )
        }
        var currentLayerNumber = -1
        for target in regularTargetsSorted {
            let layerNumber = target.layerNumber ?? -1
            let layerName = target.layerNumber.map { layers[$0] } ?? "Unknown"
            if layerNumber != currentLayerNumber {
                diagramContent += tabs("%% \(layerName)", count: 4)
                currentLayerNumber = layerNumber
            }
            diagramContent += tabs(
                "service \(target.name.lowercased())(vscode-icons:file-type-package)[\(target.name)] in \(layerName.lowercased())",
                count: 4
            )
        }
        let reversedLayers: [String] = layers.reversed()
        for (index, layer) in reversedLayers.enumerated() {
            guard index != reversedLayers.count - 1 else { continue }
            diagramContent += tabs("_\(layer.lowercased()):B -- T:_\(reversedLayers[index + 1].lowercased())", count: 4)
        }
        diagramContent += tabs("</pre>", count: 2)
        diagramContent += tabs("<script type=\"module\">", count: 2)
        diagramContent += tabs("import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';", count: 3)
        diagramContent += tabs("mermaid.initialize({ startOnLoad: true });", count: 3)
        diagramContent += tabs("mermaid.registerIconPacks([", count: 3)
        diagramContent += tabs("{", count: 4)
        diagramContent += tabs("name: 'vscode-icons',", count: 5)
        diagramContent += tabs("loader: () =>", count: 5)
        diagramContent += tabs("fetch('https://unpkg.com/@iconify-json/vscode-icons@1.2.20/icons.json').then((res) => res.json()),", count: 6)
        diagramContent += tabs("},", count: 4)
        diagramContent += tabs("]);", count: 3)
        diagramContent += tabs("</script>", count: 2)
        diagramContent += tabs("</body>", count: 1)
        diagramContent += "</html>"
        generateHTMLFile(content: diagramContent)
        echo("Packages Diagram generated at \(packagesPath)/packages.html")
    }

    private func generateHTMLFile(content: String) {
        let filePath = "\(packagesPath)/packages.html"
        do {
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            echo("Error writing to file: \(error)")
        }
    }

    private func tabs(_ string: String, count: Int) -> String {
        Array(repeating: DiagramConstants.spacing, count: count).joined() + string + "\n"
    }
}

enum DiagramConstants {
    static let spacing = "  "
}
