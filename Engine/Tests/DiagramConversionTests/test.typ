#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#diagram(
    spacing: 1.8em,
 // External vertices
node((0.0, 0.0), $q$, name: <i1>),
node((4.0, 0.0), $q$, name: <o1>),
node((4.0, 2.0), $H$, name: <o2>),
 // Internal vertices
node((2.0, 1.0), name: <v1>, radius: 2pt, fill: black),
 // External lines
edge(<i1>, <v1>, "-|>-"),
edge(<v1>, <o1>, "-|>-"),
edge(<v1>, <o2>, "-", stroke: (dash: "dashed")),
)