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
    
    var body: some View {
        VStack {
            LineTypeToolbar(toolbox: toolbox, editor: editor)
            DiagramCanvasView(editor: editor, toolbox: toolbox)
        }
    }
}

#Preview {
    ContentView()
}
