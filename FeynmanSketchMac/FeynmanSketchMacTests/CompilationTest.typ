// Generated with FeynmanSketch alpha version

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#diagram(
    spacing: 1.8em,
 // External vertices
node((100.0, 80.0), [], name: <i1>),
node((100.0, 220.0), [], name: <o1>),
node((460.0, 80.0), [], name: <i2>),
node((460.0, 220.0), [], name: <o2>),
 // Internal vertices
node((220.0, 160.0), name: <v1>, radius: 2pt, fill: black),
node((340.0, 160.0), name: <v2>, radius: 2pt, fill: black),
 // External lines
edge(<i1>, <v1>, "-|>-"),
edge(<v1>, <o1>, "-|>-"),
edge(<i2>, <v2>, "-|>-"),
edge(<v2>, <o2>, "-|>-"),
 // Internal lines
)