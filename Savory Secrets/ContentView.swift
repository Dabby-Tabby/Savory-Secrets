import SwiftUI
import PhotosUI

// RecipeManager class to manage the recipes
class RecipeManager: ObservableObject {
    @Published var recipes: [(name: String, image: UIImage?, ingredients: [String: String])] = []
    
    // Adds a new recipe
    func addRecipe(name: String, image: UIImage?, ingredients: [String: String]) {
        recipes.append((name: name, image: image, ingredients: ingredients))
    }
    
    // Updates the image for a recipe by its name
    func updateImage(forRecipeName name: String, withImage image: UIImage) {
        if let index = recipes.firstIndex(where: { $0.name == name }) {
            recipes[index].image = image
        }
    }
    
    // Adds an ingredient to a specific recipe
    func addIngredient(toRecipeName name: String, ingredient: String, quantity: String) {
        if let index = recipes.firstIndex(where: { $0.name == name }) {
            recipes[index].ingredients[ingredient] = quantity
        }
    }
}

// Main content view with a tab view
struct ContentView: View {
    @StateObject private var recipeManager = RecipeManager()

    var body: some View {
        TabView {
            // Recipes View
            NavigationView {
                ViewRecipe()
                    .environmentObject(recipeManager)
                    .navigationTitle("Recipes")
            }
            .tabItem {
                Image(systemName: "list.clipboard.fill")
                Text("Recipes")
            }
            
            // Create Recipe View
            NavigationView {
                CreateRecipe()
                    .environmentObject(recipeManager)
                    .navigationTitle("Create Recipe")
            }
            .tabItem {
                Image(systemName: "plus.app.fill")
                Text("Create")
            }
            
            // Shopping List View
            NavigationView {
                ShoppingList()
                    .navigationTitle("Shopping List")
            }
            .tabItem {
                Image(systemName: "cart.fill")
                Text("Shopping List")
            }
        }
        .accentColor(pastelDarkBlue) // Custom accent color
    }
}

// View to display the list of recipes
struct ViewRecipe: View {
    @EnvironmentObject var recipeManager: RecipeManager

    var body: some View {
        ZStack {
            // Background Image
            Image("KitchenWhite")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            // Content Layer
            ScrollView {
                LazyVStack {
                    if recipeManager.recipes.isEmpty {
                        Text("No recipes available.\nHead to Create at the bottom!")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        ForEach(recipeManager.recipes, id: \.name) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                Text(recipe.name)
                                    .glowBorder(color: .white, lineWidth: 5)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(minWidth: 370, minHeight: 180)
                                    .background(
                                        recipe.image.map { Image(uiImage: $0).resizable() } ??
                                        Image(systemName: "photo").resizable()
                                    )
                                    .background(pastelWhite)
                                    .cornerRadius(18)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// View to create a new recipe
struct CreateRecipe: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var newRecipeName: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var ingredients: [String: String] = [:]
    @State private var newIngredient: String = ""
    @State private var ingredientQuantity: String = ""
    @State private var showingAddIngredientSheet = false

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // Background Image
                Image("KitchenModern")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .scaleEffect(1.1)
                    .offset(y: -16)
                    .edgesIgnoringSafeArea(.all)
            }

            // Content Layer
            VStack {
                TextField("Enter recipe name", text: $newRecipeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    Text("Select Image")
                        .font(.headline)
                        .padding()
                        .background(pastelBlack)
                        .foregroundColor(pastelWhite)
                        .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    showingAddIngredientSheet = true
                }) {
                    Text("Add Ingredients")
                        .font(.headline)
                        .padding()
                        .background(pastelBlack)
                        .foregroundColor(pastelWhite)
                        .cornerRadius(10)
                }
                .padding()
                
                List(ingredients.keys.sorted(), id: \.self) { ingredient in
                    HStack {
                        Text(ingredient)
                        Spacer()
                        Text(ingredients[ingredient] ?? "")
                    }
                }
                .padding()
                
                if !ingredients.isEmpty {
                    Button(action: {
                        if !newRecipeName.isEmpty {
                            recipeManager.addRecipe(name: newRecipeName, image: selectedImage, ingredients: ingredients)
                            newRecipeName = ""
                            selectedImage = nil
                            ingredients = [:]
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Add Recipe")
                            .font(.headline)
                            .padding()
                            .background(pastelBlack)
                            .foregroundColor(pastelWhite)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingAddIngredientSheet) {
            VStack {
                TextField("Enter ingredient", text: $newIngredient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Enter quantity", text: $ingredientQuantity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !newIngredient.isEmpty, !ingredientQuantity.isEmpty {
                        ingredients[newIngredient] = ingredientQuantity
                        newIngredient = ""
                        ingredientQuantity = ""
                    }
                }) {
                    Text("Add Ingredient")
                        .font(.headline)
                        .padding()
                        .background(pastelBlack)
                        .foregroundColor(pastelWhite)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
}

// View to show detailed information about a recipe
struct RecipeDetailView: View {
    var recipe: (name: String, image: UIImage?, ingredients: [String: String])
    
    var body: some View {
        VStack {
            Text(recipe.name)
                .font(.largeTitle)
                .padding()
            
            recipe.image.map { Image(uiImage: $0).resizable() }
                .frame(width: 300, height: 300)
                .cornerRadius(50)
                .clipped()
                .padding()
            
            List(recipe.ingredients.keys.sorted(), id: \.self) { ingredient in
                HStack {
                    Text(ingredient)
                    Spacer()
                    Text(recipe.ingredients[ingredient] ?? "")
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

// Custom Image Picker for selecting images from the photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        UIImagePickerController()
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.delegate = context.coordinator
    }
}

// View to display and manage the shopping list
struct ShoppingList: View {
    @State private var list: [String] = []
    @State private var showingAddItemSheet = false
    @State private var newItemName = ""

    var body: some View {
        NavigationView {
            ZStack {
                GeometryReader { geometry in
                    // Background Image
                    Image("KitchenBase")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .scaleEffect(1.1)
                        .offset(x: -400, y: -75)
                        .edgesIgnoringSafeArea(.all)
                }

                VStack {
                    ScrollView {
                        LazyVStack {
                            if list.isEmpty {
                                Text("No items in the list.")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding()
                            } else {
                                ForEach(list, id: \.self) { item in
                                    NavigationLink(destination: IngredientDetailView(list: $list, selectedItem: item)) {
                                        Text(item)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(pastelBrown)
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                            .padding(.vertical, 5)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $showingAddItemSheet) {
                    VStack {
                        Text("Create New Shopping List")
                            .font(.headline)
                            .padding()
                        
                        TextField("Enter shopping list name", text: $newItemName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button(action: {
                            addItem()
                        }) {
                            Text("Create List")
                                .padding()
                                .background(pastelOrange)
                                .foregroundColor(pastelWhite)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarItems(trailing: Button(action: {
                showingAddItemSheet = true
            }) {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
            })
        }
    }

    // Adds a new item to the shopping list
    private func addItem() {
        guard !newItemName.isEmpty else { return }
        list.append(newItemName)
        newItemName = ""
        showingAddItemSheet = false
    }
}

// Preview provider for ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
