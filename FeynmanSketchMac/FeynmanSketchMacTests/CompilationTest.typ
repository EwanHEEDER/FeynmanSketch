// Generated with FeynmanSketch alpha version

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#diagram(
    spacing: 1.8em,
 // External vertices
node((9.0, 4.0), $gamma$, name: <i1>),
node((9.0, 9.0), $e$, name: <i2>),
node((19.0, 4.0), $e$, name: <o1>),
node((19.0, 9.0), [], name: <o2>),
 // Internal vertices
node((12.0, 7.0), name: <v1>, radius: 2pt, fill: black),
node((16.0, 7.0), name: <v2>, radius: 2pt, fill: black),
 // External lines
edge(<i1>, <v1>, "-", decorations: "wave"),
edge(<v2>, <o2>, "-", decorations: "wave"),
edge(<i2>, <v1>, "-|>-"),
edge(<v2>, <o1>, "-|>-"),
 // Internal lines
edge(<v1>, <v2>, $e$, "-|>-"),
)