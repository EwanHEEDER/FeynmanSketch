# FeynmanSketch
![License: GPL v3](https://img.shields.io/badge/license-GPLv3-blue.svg)
![Swift](https://img.shields.io/badge/swift-5.10%2B-orange.svg)
![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-lightgrey.svg)

[![Documentation](https://img.shields.io/badge/doc-DocC-blue.svg)](https://ewanheeder.github.io/FeynmanSketch/)

FeynmanSketch is a drawing tool for converting Feynman diagrams into editable Typst source code, using the [fletcher](https://typst.app/universe/package/fletcher)
package.

The project is designed to be cross-platform: the underlying engine (diagram model and
Typst code generation) is written in Swift and has no dependency on any particular UI framework or operating system.
Currently, a native macOS interface (built with SwiftUI) is available; a Linux interface is
planned for a future release.

The goal is speed: sketch a diagram with a few clicks, get clean, human-editable Typst code
you can drop straight into your document and tweak further if needed.

## Installation

### macOS

Requires macOS 13 or later. No additional software is required. 

Download the latest `.dmg` from the [Releases](../../releases) page of this repository, open
it, and drag FeynmanSketch into your Applications folder.

> **Note:** the app is not signed with an Apple Developer certificate. On first launch, macOS
> will likely block it and show a security warning. To open it:
> 1. Try to open the app normally (double-click). macOS will block it with a warning dialog.
> 2. Go to **System Settings > Privacy & Security**, scroll down to the Security section, and
>    you should see a message about FeynmanSketch being blocked. Click **Open Anyway**.
> 3. Confirm by clicking **Open** in the dialog that appears.

### Linux

Not yet available — a native Linux interface is planned for a future release. See
[Future improvements](#future-improvements).

## Quick start

The canvas has four tools plus a curvature and delete mode, all accessible from the toolbar:

- **Vertex** — tap the canvas to place a vertex, snapped to the nearest grid node.
- **Line** (one button per style: fermion, vector, gluon, scalar) — tap a first vertex, then a
  second one, to draw a line of that type between them. Tapping the same vertex twice cancels
  the line in progress, as well as changing the line type mid-draw.
- **Select** — tap a vertex or line to select it. A selected element can be deleted or
  relabeled using the toolbar buttons.
- **Curvature** — reveals a small draggable handle at the midpoint of every line. Drag a
  handle to bend that line; the angle snaps to round values (0°, ±45°, ±90°) when close enough.

- **Delete** — delete selected object. Deleting a vertex also deletes all lines connected to it.
- **Edit label** — edit label of the selected object.
- **Reset** — return to empty canvas.

Once your diagram looks right, press **Generate** to produce the corresponding Typst/fletcher
code in a side panel. You can then copy it in your clipboard.

## Developer documentation

The engine (`DiagramModel` and `DiagramConversion`) is fully documented. A generated, browsable version is available at:

**[https://ewanheeder.github.io/FeynmanSketch/](https://ewanheeder.github.io/FeynmanSketch/)**

## Development

FeynmanSketch is a monorepo with two parts:

- `Engine/` — a portable Swift package (no UI dependencies), containing the diagram model and
  Typst code generator. See the [developer documentation](#developer-documentation) above.
- `FeynmanSketchMac/` — the native macOS interface, built with SwiftUI, referencing `Engine`
  as a local Swift package.

Following [the licence](#licence), I provide XCode workspace `FeynmanSketch.xcworkspace` to make easier for anyone to work on this project.

## Licence

FeynmanSketch is licensed under the [GNU General Public License v3.0](LICENSE). You are free
to use, modify, and share this project, provided that any derivative work remains free and is
distributed under the same licence.

## Future improvements

- [ ] **Linux interface**, reusing the same portable `Engine` package.
- [ ] **Undo/redo** for drawing actions (adding/removing a vertex or line), excluding the full
  canvas reset.
- [ ] **Live compiled preview**, using the local `typst` binary to render the diagram as it is
  being edited, rather than only exporting source code.