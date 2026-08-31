//
//  ContentView.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 02/08/2026.
//

import SwiftUI

/// App's root view: owns both view models, assemble the toolbar, canvas and code panel into an overall layout.
struct ContentView: View {
    /// The ViewModel for diagram being currently edited / interacted with. It is owned here so it does not outlive the main window.
    @StateObject private var editor = DiagramEditorViewModel()
    /// The ViewModel for active tool. Is also owned here for same reason.
    @StateObject private var toolbox = ToolboxViewModel()
    /// Whether the generated-code panel is currently shown.
    @State private var isCodePanelVisible = false
    /// Source code most recently generated via toolbar's dedicated button.
    @State private var generatedCode = ""
    
    var body: some View {
        HStack {
            VStack {
                LineTypeToolbar(
                    toolbox: toolbox,
                    editor: editor,
                    isCodePanelVisible: $isCodePanelVisible,
                    generatedCode: $generatedCode
                )
                DiagramCanvasView(editor: editor, toolbox: toolbox)
            }
            .padding()
            
            if isCodePanelVisible {
                TypstCodeView(code: generatedCode, isVisible: $isCodePanelVisible)
            }
        }
    }
}

#Preview {
    ContentView()
}
