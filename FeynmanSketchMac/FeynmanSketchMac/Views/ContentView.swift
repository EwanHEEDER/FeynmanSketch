//
//  ContentView.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 02/08/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var editor = DiagramEditorViewModel()
    @StateObject private var toolbox = ToolboxViewModel()
    @State private var isCodePanelVisible = false
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
