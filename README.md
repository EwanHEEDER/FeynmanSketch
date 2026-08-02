This projet is a tool to generate typst code corresponding to a feynman diagram drawn in a GUI. It is mainly written in Swift, with punctuak usage of C for diagram objects and JSON for storage. 

Very first step is the creation of the GUI with functional drawing tools to allow user to represent any possible feynman diagram. As a first sterp, this GUI will be designed with SwiftUI, and will be able to run on macOS only, but the first improvements will be to make it run on Linux as well.

Then, program shoud be able to convert this drawing into a diagram structure, made of nodes and edges, which can be serialized into JSON format. 

Finally, Typst code will be generated from the JSON representation. 

Future development will include:
- GUI for Linux
- a compilation of the generated code to check the result in the tool itself
- the ability to generate LaTeX code as well
- add tags to the diagram objects.
- The possibility to export the diagram as an image (png, svg, etc.)
- the possibility to browse through previous diagrams