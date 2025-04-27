//
//   FoodEntryView.swift
//  PeakPerformance
//
//  Created by Pranit mathyam on 4/25/25.
//

import SwiftUI

struct FoodEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var authManager: AuthManager
    
    @State private var foodName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var servingSize = ""
    @State private var servingUnit = "g"
    @State private var selectedMealType = FoodEntry.MealType.breakfast
    @State private var date = Date()
    @State private var showingErrorAlert = false
    
    // For edit mode
    private var existingEntry: FoodEntry?
    private var isEditMode: Bool
    
    let servingUnits = ["g", "ml", "oz", "cup", "tbsp", "tsp", "piece"]
    
    // Initialize for creating a new entry
    init() {
        self.existingEntry = nil
        self.isEditMode = false
    }
    
    // Initialize for editing an existing entry
    init(entry: FoodEntry) {
        self.existingEntry = entry
        self.isEditMode = true
        
        // Initialize state variables with existing values
        _foodName = State(initialValue: entry.name)
        _calories = State(initialValue: String(entry.calories))
        _protein = State(initialValue: String(format: "%.1f", entry.protein))
        _carbs = State(initialValue: String(format: "%.1f", entry.carbs))
        _fat = State(initialValue: String(format: "%.1f", entry.fat))
        _servingSize = State(initialValue: String(format: "%.1f", entry.servingSize))
        _servingUnit = State(initialValue: entry.servingUnit)
        _selectedMealType = State(initialValue: entry.mealType)
        _date = State(initialValue: entry.date)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Food Name", text: $foodName)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                    
                    Picker("Meal", selection: $selectedMealType) {
                        ForEach(FoodEntry.MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }
                }
                
                Section(header: Text("Nutrition")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("kcal")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Serving")) {
                    HStack {
                        Text("Serving Size")
                        Spacer()
                        TextField("0", text: $servingSize)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        
                        Picker("", selection: $servingUnit) {
                            ForEach(servingUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 80)
                    }
                }
                
                Section {
                    Button(isEditMode ? "Update Food Entry" : "Save Food Entry") {
                        saveFoodEntry()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.red)
                    .disabled(foodName.isEmpty || calories.isEmpty)
                }
            }
            .navigationTitle(isEditMode ? "Edit Food" : "Add Food")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(firestoreManager.errorMessage ?? "Unknown error occurred")
            }
        }
    }
    
    private func saveFoodEntry() {
        guard let userId = authManager.user?.uid else { return }
        
        // Convert string inputs to appropriate types
        guard let caloriesValue = Int(calories),
              let proteinValue = Double(protein.isEmpty ? "0" : protein),
              let carbsValue = Double(carbs.isEmpty ? "0" : carbs),
              let fatValue = Double(fat.isEmpty ? "0" : fat),
              let servingSizeValue = Double(servingSize.isEmpty ? "0" : servingSize) else {
            firestoreManager.errorMessage = "Please enter valid numbers"
            showingErrorAlert = true
            return
        }
        
        if isEditMode, let existingEntry = existingEntry, let entryId = existingEntry.id {
            // Update existing entry
            var updatedEntry = existingEntry
            updatedEntry.name = foodName
            updatedEntry.calories = caloriesValue
            updatedEntry.protein = proteinValue
            updatedEntry.carbs = carbsValue
            updatedEntry.fat = fatValue
            updatedEntry.date = date
            updatedEntry.mealType = selectedMealType
            updatedEntry.servingSize = servingSizeValue
            updatedEntry.servingUnit = servingUnit
            
            firestoreManager.updateFoodEntry(userId: userId, entryId: entryId, entry: updatedEntry) { success in
                if success {
                    dismiss()
                } else {
                    showingErrorAlert = true
                }
            }
        } else {
            // Create new entry
            let foodEntry = FoodEntry(
                userId: userId,
                name: foodName,
                calories: caloriesValue,
                protein: proteinValue,
                carbs: carbsValue,
                fat: fatValue,
                date: date,
                mealType: selectedMealType,
                servingSize: servingSizeValue,
                servingUnit: servingUnit
            )
            
            firestoreManager.addFoodEntry(userId: userId, foodEntry: foodEntry) { success in
                if success {
                    dismiss()
                } else {
                    showingErrorAlert = true
                }
            }
        }
    }
}
