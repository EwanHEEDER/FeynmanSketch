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
        }
    }
}
