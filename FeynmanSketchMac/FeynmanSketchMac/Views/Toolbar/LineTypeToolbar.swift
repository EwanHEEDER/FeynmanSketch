//
//  LineTypeToolbar.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 11/08/2026.
//

import SwiftUI
import DiagramModel

/// Main toolbar: tool selection, element actions (delete, rename), reset canvas, code generation.
struct LineTypeToolbar: View {
    /// The toolbox this toolbar writes the active tool to.
    @ObservedObject var toolbox: ToolboxViewModel
    
    /// The diagram editor this toolbar acts on.
    @ObservedObject var editor: DiagramEditorViewModel
    
    /// The text currently being edited in the label popover.
    @State private var labelText: String = ""
    
    /// Whether the label-editing popover is currently being shown.
    @State private var isEditingLabel: Bool = false
    
    /// Whether the reset confirmation alert is currently shown.
    @State private var isConfirmingReset: Bool = false
    
    /// Whether the code panel is currently visible. It is shared with the parent view.
    @Binding var isCodePanelVisible: Bool
    
    /// The most recently generated code. It is shared with the parent view for display.
    @Binding var generatedCode: String
    
    /// A small preview of a given line style, drawn as miniature straight line and used as icon for line style buttons in the toolbar.
    /// - Parameter type: the line type to preview.
    private func lineIcon(for type: LineType) -> some View {
        Canvas { context, size in
            let start = CGPoint(x: 4, y: size.height / 2)
            let end = CGPoint(x: size.width - 4, y: size.height / 2)
            LineStyleRenderer.draw(type, from: start, to: end, curvatureDegrees: 0, color: .primary, in: context)
        }
        .frame(width: 50, height: 16)
    }
    
    var body: some View {
        HStack {
            // Places a new vertex.
            Button {
                toolbox.activeTool = .vertex
            } label: {
                Image(systemName: "circle.fill")
            }
            .help("Vertex")
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .vertex ? .accentColor : .gray)
            
            // Select line styles, one button per style.
            ForEach(LineType.allCases, id: \.self) {type in
                Button {
                    toolbox.activeTool = .line(type)
                } label: {
                    lineIcon(for: type)
                }
                .help(type.displayName)
                .buttonStyle(.borderedProminent)
                .tint(toolbox.activeTool == .line(type) ? .accentColor : .gray)
            }
            // Selection tool.
            Button {
                toolbox.activeTool = .select
            } label: {
                Image(systemName: "cursorarrow")
            }
            .help("Select")
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .select ? .accentColor : .gray)
            
            // Curvature mode. Makes the control point appear for each line on the canvas and allow to drag them.
            Button {
                toolbox.activeTool = .curvature
            } label: {
                Image(systemName: "dot.arrowtriangles.up.right.down.left.circle")
            }
            .help("Set curvature")
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .curvature ? .accentColor : .gray)
            
            // Delete current selection. No alert.
            Button {
                editor.deleteSelection()
            } label: {
                Image(systemName: "trash")
            }
            .help("Delete selection")
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(editor.selection == nil)
            
            // Edit label of current selection. If selected, makes a popover appear to enter new label.
            Button {
                labelText = editor.selectionLabel ?? ""
                isEditingLabel = true
            } label: {
                Image(systemName: "pencil")
            }
            .help("Set label")
            .buttonStyle(.bordered)
            .disabled(editor.selection == nil)
            .popover(isPresented: $isEditingLabel) {
                VStack {
                    TextField("Label", text: $labelText)
                    Button {
                        editor.setLabelOnSelection(labelText)
                        isEditingLabel = false
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                .padding()
            }
            
            // Reset canvas. Alert appears to confirm.
            Button {
                isConfirmingReset = true
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .help("Reset canvas")
            .buttonStyle(.bordered)
            .tint(.red)
            .padding(.leading, 20)
            .alert("Reset diagram canvas?", isPresented: $isConfirmingReset) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    editor.reset()
                }
            } message: {
                Text("This action will delete all diagram vertices and lines.")
            }
            
            // Generates the code and displays it in a new side panel.
            Button("Generate") {
                generatedCode = editor.generatedTypstCode
                isCodePanelVisible = true
            }
            .buttonStyle(.bordered)
            .padding(.leading, 20)
        }
        .padding()
    }
}
