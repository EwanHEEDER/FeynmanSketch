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
        VStack(alignment: .center) {
            ScrollView {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
            
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(code, forType: .string)
            } label: {
                Image(systemName: "doc.on.clipboard")
            }
            .help("Copy code")
            .padding(.bottom)
            
            Button {
                isVisible = false
            } label: {
                Text("Hide panel")
            }
            .padding(.bottom)
        }
        .frame(width: 320)
        .background(Color.gray.opacity(0.15))
    }
}
