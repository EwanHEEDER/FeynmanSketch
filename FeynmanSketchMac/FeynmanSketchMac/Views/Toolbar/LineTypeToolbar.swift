//
//  LineTypeToolbar.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 11/08/2026.
//

import SwiftUI
import DiagramModel

struct LineTypeToolbar: View {
    @ObservedObject var toolbox: ToolboxViewModel
    @ObservedObject var editor: DiagramEditorViewModel
    
    @State private var labelText: String = ""
    @State private var isEditingLabel: Bool = false
    
    private func lineIcon(for type: LineType) -> some View {
        Canvas { context, size in
            let start = CGPoint(x: 4, y: size.height / 2)
            let end = CGPoint(x: size.width - 4, y: size.height / 2)
            LineStyleRenderer.draw(type, from: start, to: end, color: .primary, in: context)
        }
        .frame(width: 50, height: 16)
    }
    
    var body: some View {
        HStack {
            Button {
                toolbox.activeTool = .vertex
            } label: {
                Image(systemName: "circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .vertex ? .accentColor : .gray)
            
            ForEach(LineType.allCases, id: \.self) {type in
                Button {
                    toolbox.activeTool = .line(type)
                } label: {
                    lineIcon(for: type)
                }
                .buttonStyle(.borderedProminent)
                .tint(toolbox.activeTool == .line(type) ? .accentColor : .gray)
            }
            
            Button {
                toolbox.activeTool = .select
            } label: {
                Image(systemName: "cursorarrow")
            }
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .select ? .accentColor : .gray)
            
            Button {
                editor.deleteSelection()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(editor.selection == nil)
            
            Button {
                labelText = editor.selectionLabel ?? ""
                isEditingLabel = true
            } label: {
                Image(systemName: "pencil")
            }
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
        }
        .padding()
    }
}
