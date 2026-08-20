//
//  TypstCodeView.swift
//  FeynmanSketchMac
//
//  Created by HEEDER Ewan on 20/08/2026.
//

import SwiftUI
import AppKit

struct TypstCodeView: View {
    let code: String
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(code, forType: .string)
            } label: {
                Label("Copier dans le presse-papier", systemImage: "doc.on.clipboard")
            }
            .padding(.bottom)
            
            Button {
                isVisible = false
            } label: {
                Text("Hide result panel")
            }
            .padding(.bottom)
        }
        .frame(width: 320)
        .background(Color(nsColor: .textBackgroundColor))
    }
}
