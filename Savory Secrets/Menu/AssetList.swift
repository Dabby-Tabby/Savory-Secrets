//
//  AssetList.swift
//  Savory Secrets
//
//  Created by Nick Watts on 7/21/24.
//

import Foundation
import SwiftUI

let pastelRed = Color(red: 0.960784, green: 0.654901, blue: 0.650980)
let pastelOrange = Color(red: 0.960784, green: 0.8117647, blue: 0.6235)
let pastelYellow = Color(red: 0.95294, green: 0.9607, blue: 0.6627)
let pastelBlue = Color(red: 0.815686, green: 0.8941176, blue: 0.93333)
let pastelPurple = Color(red: 0.83529, green: 0.8196, blue: 0.9137)
let pastelLightBlue = Color(red: 0.752941, green: 0.847058, blue: 0.890196)
let pastelWhite = Color(red: 0.992156, green: 0.964705, blue: 0.949019)
let pastelBrown = Color(red: 0.6549, green: 0.55294, blue: 0.541176)
let pastelSalmon = Color(red: 0.88235, green: 0.541176, blue: 0.478431)
let pastelTan = Color(red: 0.93333, green: 0.725490, blue: 0.63529)
let pastelGreen = Color(red: 0.7568627, green: 0.8823529, blue: 0.756827)
let pastelBlack = Color(red: 0.19607843137254902, green: 0.19607843137254902, blue: 0.19607843137254902
)
let pastelDarkBlue = Color(red:0.4666666666666667, green:0.6196078431372549, blue: 0.796078431372549)


struct HighlightButtonStyle: ButtonStyle {
    var highlightColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? highlightColor : Color.clear)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 1.1 : 1.0)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}

struct IngredientDetailView: View {
    @Binding var list: [String]
    @State private var selectedItem: String
    @State private var ingredients: [String] = []
    @State private var newIngredient: String = ""
    
    init(list: Binding<[String]>, selectedItem: String) {
        _list = list
        _selectedItem = State(initialValue: selectedItem)
    }

    var body: some View {
        VStack {
            Text("Ingredients for \(selectedItem)")
                .font(.headline)
                .padding()

            TextField("Enter ingredient", text: $newIngredient)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                addIngredient()
            }) {
                Text("Add Ingredient")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            List(ingredients, id: \.self) { ingredient in
                Text(ingredient)
            }

            Spacer()
        }
        .navigationTitle(selectedItem)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func addIngredient() {
        guard !newIngredient.isEmpty else { return }
        ingredients.append(newIngredient)
        newIngredient = ""
    }
}

struct GlowBorder: ViewModifier {
    var color: Color
    var lineWidth: Int
    
    func body(content: Content) -> some View {
        applyShadow(content: AnyView(content), lineWidth: lineWidth)
    }
    
    func applyShadow(content: AnyView, lineWidth: Int) -> AnyView {
        if lineWidth == 0 {
            return content
        } else {
            return applyShadow(content: AnyView(content.shadow(color: color, radius: 1)), lineWidth: lineWidth - 1)
        }
    }
}

extension View {
    func glowBorder(color: Color, lineWidth: Int) -> some View {
        self.modifier(GlowBorder(color: color, lineWidth: lineWidth))
    }
}

#Preview {
    ContentView()
}
