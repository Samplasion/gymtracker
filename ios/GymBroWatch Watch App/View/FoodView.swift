//
//  FoodView.swift
//  GymBroWatch Watch App
//
//  Created by Francesco Arieti on 06/01/26.
//

import SwiftUI

struct FoodView: View {
    @EnvironmentObject var viewModel: FoodViewModel
    
    @State private var selectedTab: Tab = .gauge
    @State private var presentMenu: Bool = false
    
    enum Tab: String, CaseIterable {
        case gauge, diary, nutrition
    }
    
    func labelFor(tab: Tab) -> LocalizedStringKey {
        switch tab {
        case .gauge: return "Food"
        case .diary: return "Diary"
        case .nutrition: return "Nutrition split"
        }
    }
    
    @ViewBuilder
    var innerBody: some View {
        switch selectedTab {
        case .gauge:
            FoodGaugeView()
        case .diary:
            FoodDiaryView()
        case .nutrition:
            FoodNutritionView()
        }
    }
    
    var placement: ToolbarItemPlacement {
        if #available(watchOS 10, *) {
            return .topBarLeading
        } else {
            return .cancellationAction
        }
    }
    
    var body: some View {
        NavigationView {
            innerBody
            //        TabView(selection: $selectedTab) {
            //            FoodGaugeView().tag(Tab.gauge)
            //            FoodDiaryView().tag(Tab.diary)
            //            FoodNutritionView().tag(Tab.nutrition)
            //        }
            //        .tabViewStyle(.page)
                .animation(.interpolatingSpring(bounce: 0.5), value: selectedTab)
                .toolbar(content: {
                    ToolbarItem(placement: placement) {
                        Button {
                            presentMenu = true
                        } label: {
                            Image(systemName: "info")
                        }
                    }
                })
                .sheet(isPresented: $presentMenu, content: {
                    List {
                        ForEach(Tab.allCases, id: \.rawValue) { tab in
                            Button {
                                selectedTab = tab
                                presentMenu = false
                            } label: {
                                Text(labelFor(tab: tab))
                            }
                        }
                    }
                })
        }
    }
}

#Preview {
    FoodView()
        .environmentObject(FoodViewModel())
}
