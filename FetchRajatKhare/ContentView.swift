//
//  ContentView.swift
//  FetchRajatKhare
//
//  Created by Rajat Khare on 3/13/23.
//

import SwiftUI

struct Meal: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String?
    
    var imageUrl: URL? {
        guard let strMealThumb = strMealThumb else {
            return nil
        }
        return URL(string: strMealThumb)
    }
    
    var id: String {
        return idMeal
    }
}

struct MealList: Codable {
    let meals: [Meal]
}

class MealFetcher: ObservableObject {
    @Published var meals = [Meal]()
    
    init() {
        let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(MealList.self, from: data) {
                    DispatchQueue.main.async {
                        self.meals = decodedResponse.meals
                    }
                    return
                }
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct ContentView: View {
    @ObservedObject var mealFetcher = MealFetcher()
    
    var body: some View {
        NavigationView {
            List(mealFetcher.meals) { meal in
                NavigationLink(destination: MealDetailView(meal: meal)) {
                    HStack(spacing: 16) {
                        if let imageUrl = meal.imageUrl, let imageData = try? Data(contentsOf: imageUrl), let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        }
                        Text(meal.strMeal)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitle("Desserts")
        }
    }
}

struct MealDetailView: View {
    let meal: Meal
    
    @State private var mealDetails: MealDetails?
    @State private var checkedIngredients = Set<String>()
    
    var body: some View {
        VStack {
            AsyncImage(url: meal.imageUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()
                @unknown default:
                    fatalError()
                }
            }

            Text(meal.strMeal)
                .font(.title)
                .padding()
            if let mealDetails = mealDetails {
                Text(mealDetails.strInstructions)
                    .padding()
                List {
                    Section(header: Text("Ingredients")) {
                        ForEach(mealDetails.ingredientsWithMeasurements, id: \.0) { ingredient, measurement in
                            Toggle(isOn: binding(for: ingredient)) {
                                VStack(alignment: .leading) {
                                    Text(ingredient)
                                    if !measurement.isEmpty {
                                        Text(measurement)
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }

                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(meal.idMeal)")!
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(MealDetailsList.self, from: data) {
                        DispatchQueue.main.async {
                            self.mealDetails = decodedResponse.meals.first
                        }
                        return
                    }
                }
                
                print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            }.resume()
        }
    }
    
    private func binding(for ingredient: String) -> Binding<Bool> {
        return Binding<Bool>(
            get: {
                checkedIngredients.contains(ingredient)
            },
            set: { newValue in
                if newValue {
                    checkedIngredients.insert(ingredient)
                } else {
                    checkedIngredients.remove(ingredient)
                }
            }
        )
    }
}



struct MealDetailsList: Codable {
    let meals: [MealDetails]
}

struct MealDetails: Codable, Equatable {
    let strInstructions: String
    let strIngredient1: String?
    let strMeasure1: String?
    let strIngredient2: String?
    let strMeasure2: String?
    let strIngredient3: String?
    let strMeasure3: String?
    let strIngredient4: String?
    let strMeasure4: String?
    let strIngredient5: String?
    let strMeasure5: String?
    let strIngredient6: String?
    let strMeasure6: String?
    let strIngredient7: String?
    let strMeasure7: String?
    let strIngredient8: String?
    let strMeasure8: String?
    let strIngredient9: String?
    let strMeasure9: String?
    let strIngredient10: String?
    let strMeasure10: String?
    let strIngredient11: String?
    let strMeasure11: String?
    let strIngredient12: String?
    let strMeasure12: String?
    let strIngredient13: String?
    let strMeasure13: String?
    let strIngredient14: String?
    let strMeasure14: String?
    let strIngredient15: String?
    let strMeasure15: String?
    let strIngredient16: String?
    let strMeasure16: String?
    let strIngredient17: String?
    let strMeasure17: String?
    let strIngredient18: String?
    let strMeasure18: String?
    let strIngredient19: String?
    let strMeasure19: String?
    let strIngredient20: String?
    let strMeasure20: String?

    var ingredientsWithMeasurements: [(String, String)] {
        var result: [(String, String)] = []
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let ingredient = child.value as? String, !ingredient.isEmpty, child.label?.starts(with: "strIngredient") == true {
                let number = child.label?.suffix(1).trimmingCharacters(in: .whitespaces) ?? ""
                if let measurement = mirror.children.first(where: { $0.label == "strMeasure\(number)" })?.value as? String {
                    result.append((ingredient, measurement))
                } else {
                    result.append((ingredient, ""))
                }
            }
        }
        return result
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
