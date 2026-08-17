//
//  ToolbarView.swift
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
    
    var body: some View {
        HStack {
            Button("Vertex") {
                toolbox.activeTool = .vertex
            }
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .vertex ? .accentColor : .gray)
            
            ForEach(LineType.allCases, id: \.self) {type in
                Button(type.displayName) {
                    toolbox.activeTool = .line(type)
                }
                .buttonStyle(.borderedProminent)
                .tint(toolbox.activeTool == .line(type) ? .accentColor : .gray)
            }
            
            Button("Select") {
                toolbox.activeTool = .select
            }
            .buttonStyle(.borderedProminent)
            .tint(toolbox.activeTool == .select ? .accentColor : .gray)
            
            Button("Delete") {
                editor.deleteSelection()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .disabled(editor.selection == nil)
            
            Button("Label") {
                labelText = editor.selectionLabel ?? ""
                isEditingLabel = true
            }
            .buttonStyle(.bordered)
            .disabled(editor.selection == nil)
            .popover(isPresented: $isEditingLabel) {
                VStack {
                    TextField("Label", text: $labelText)
                    Button("OK") {
                        editor.setLabelOnSelection(labelText)
                        isEditingLabel = false
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}
