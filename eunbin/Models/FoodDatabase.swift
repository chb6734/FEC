//
//  FoodDatabase.swift
//  eunbin
//
//  Created by Dohyun iOS Engineer
//

import Foundation

enum FoodDatabase {

    static let allFoods: [FoodItem] = koreanFoods + chineseFoods + japaneseFoods + westernFoods + snackFoods + otherFoods

    static func foods(for category: FoodCategory) -> [FoodItem] {
        allFoods.filter { $0.category == category }
    }

    static func foods(for mealType: MealType) -> [FoodItem] {
        allFoods.filter { $0.mealTypes.contains(mealType) }
    }

    // MARK: - 한식 (Korean)

    static let koreanFoods: [FoodItem] = [
        FoodItem(id: "bibimbap", name: "비빔밥", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "야채", "고추장"], baseScore: 1.0),
        FoodItem(id: "kimchi_jjigae", name: "김치찌개", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["찌개", "김치", "돼지고기"], baseScore: 1.0),
        FoodItem(id: "doenjang_jjigae", name: "된장찌개", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["찌개", "된장", "두부"], baseScore: 1.0),
        FoodItem(id: "bulgogi", name: "불고기", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["고기", "소고기"], baseScore: 1.0),
        FoodItem(id: "galbi", name: "갈비", category: .korean,
                 mealTypes: [.dinner], restrictions: [.none],
                 tags: ["고기", "소고기", "특별"], baseScore: 1.0),
        FoodItem(id: "japchae", name: "잡채", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "야채"], baseScore: 1.0),
        FoodItem(id: "kongnamul_gukbap", name: "콩나물국밥", category: .korean,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["국밥", "해장"], baseScore: 1.0),
        FoodItem(id: "samgyetang", name: "삼계탕", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["탕", "닭", "보양"], baseScore: 1.0),
        FoodItem(id: "jeyuk_bokkeum", name: "제육볶음", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["볶음", "돼지고기", "매운"], baseScore: 1.0),
        FoodItem(id: "sundae_gukbap", name: "순대국밥", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["국밥", "순대"], baseScore: 1.0),
        FoodItem(id: "kimchi_bokkeumbap", name: "김치볶음밥", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "볶음", "김치"], baseScore: 1.0),
        FoodItem(id: "haemul_pajeon", name: "해물파전", category: .korean,
                 mealTypes: [.dinner], restrictions: [.none],
                 tags: ["전", "해물"], baseScore: 0.9),
        FoodItem(id: "dakgalbi", name: "닭갈비", category: .korean,
                 mealTypes: [.dinner], restrictions: [.none],
                 tags: ["닭", "매운", "볶음"], baseScore: 1.0),
        FoodItem(id: "gimbap", name: "김밥", category: .korean,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["밥", "간편"], baseScore: 1.0),
        FoodItem(id: "tteokguk", name: "떡국", category: .korean,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["국", "떡"], baseScore: 0.9),
        FoodItem(id: "bibim_naengmyeon", name: "비빔냉면", category: .korean,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "매운", "차가운"], baseScore: 0.9),
        FoodItem(id: "korean_salad", name: "두부 샐러드", category: .korean,
                 mealTypes: [.breakfast, .lunch, .dinner], restrictions: [.vegetarian, .lowCalorie],
                 tags: ["두부", "야채", "가벼운"], baseScore: 0.9),
    ]

    // MARK: - 중식 (Chinese)

    static let chineseFoods: [FoodItem] = [
        FoodItem(id: "jajangmyeon", name: "자장면", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "짜장"], baseScore: 1.0),
        FoodItem(id: "jjamppong", name: "짬뽕", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "해물", "매운"], baseScore: 1.0),
        FoodItem(id: "tangsuyuk", name: "탕수육", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["고기", "돼지고기", "튀김"], baseScore: 1.0),
        FoodItem(id: "mapo_tofu", name: "마파두부", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["두부", "매운"], baseScore: 0.9),
        FoodItem(id: "fried_rice", name: "볶음밥", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "볶음"], baseScore: 1.0),
        FoodItem(id: "kanpunggi", name: "깐풍기", category: .chinese,
                 mealTypes: [.dinner], restrictions: [.none],
                 tags: ["닭", "튀김", "매운"], baseScore: 0.9),
        FoodItem(id: "jjamppong_bap", name: "짬뽕밥", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "해물", "매운"], baseScore: 0.9),
        FoodItem(id: "gun_mandu", name: "군만두", category: .chinese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["만두", "간식"], baseScore: 0.9),
    ]

    // MARK: - 일식 (Japanese)

    static let japaneseFoods: [FoodItem] = [
        FoodItem(id: "sushi", name: "초밥", category: .japanese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "생선"], baseScore: 1.0),
        FoodItem(id: "ramen", name: "라멘", category: .japanese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "국물"], baseScore: 1.0),
        FoodItem(id: "donkatsu", name: "돈카츠", category: .japanese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["고기", "돼지고기", "튀김"], baseScore: 1.0),
        FoodItem(id: "udon", name: "우동", category: .japanese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "국물"], baseScore: 1.0),
        FoodItem(id: "curry_rice", name: "카레라이스", category: .japanese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "카레"], baseScore: 1.0),
        FoodItem(id: "takoyaki", name: "타코야키", category: .japanese,
                 mealTypes: [.lunch], restrictions: [.none],
                 tags: ["간식", "문어"], baseScore: 0.8),
        FoodItem(id: "onigiri", name: "오니기리", category: .japanese,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["밥", "간편"], baseScore: 0.9),
        FoodItem(id: "soba", name: "소바", category: .japanese,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "차가운"], baseScore: 0.9),
    ]

    // MARK: - 양식 (Western)

    static let westernFoods: [FoodItem] = [
        FoodItem(id: "pasta", name: "파스타", category: .western,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "이탈리안"], baseScore: 1.0),
        FoodItem(id: "pizza", name: "피자", category: .western,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["빵", "치즈"], baseScore: 1.0),
        FoodItem(id: "hamburger", name: "햄버거", category: .western,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["빵", "고기", "간편"], baseScore: 1.0),
        FoodItem(id: "steak", name: "스테이크", category: .western,
                 mealTypes: [.dinner], restrictions: [.none],
                 tags: ["고기", "소고기", "특별"], baseScore: 1.0),
        FoodItem(id: "salad", name: "샐러드", category: .western,
                 mealTypes: [.breakfast, .lunch, .dinner], restrictions: [.vegetarian, .glutenFree, .lowCalorie],
                 tags: ["야채", "가벼운"], baseScore: 0.9),
        FoodItem(id: "sandwich", name: "샌드위치", category: .western,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["빵", "간편"], baseScore: 1.0),
        FoodItem(id: "risotto", name: "리조또", category: .western,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["밥", "치즈", "이탈리안"], baseScore: 0.9),
        FoodItem(id: "omelette", name: "오믈렛", category: .western,
                 mealTypes: [.breakfast], restrictions: [.glutenFree],
                 tags: ["달걀", "아침"], baseScore: 1.0),
        FoodItem(id: "fish_and_chips", name: "피쉬앤칩스", category: .western,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["생선", "튀김"], baseScore: 0.9),
        FoodItem(id: "gratin", name: "그라탱", category: .western,
                 mealTypes: [.dinner], restrictions: [.none],
                 tags: ["치즈", "오븐"], baseScore: 0.9),
    ]

    // MARK: - 분식 (Snack/Street Food)

    static let snackFoods: [FoodItem] = [
        FoodItem(id: "tteokbokki", name: "떡볶이", category: .snack,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["떡", "매운"], baseScore: 1.0),
        FoodItem(id: "ramyeon", name: "라면", category: .snack,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["면", "매운", "간편"], baseScore: 1.0),
        FoodItem(id: "twigim", name: "튀김", category: .snack,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["튀김", "간식"], baseScore: 0.9),
        FoodItem(id: "odeng", name: "어묵", category: .snack,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["어묵", "국물"], baseScore: 0.9),
        FoodItem(id: "sundae", name: "순대", category: .snack,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["순대", "간식"], baseScore: 0.9),
        FoodItem(id: "hotdog", name: "핫도그", category: .snack,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["빵", "간편"], baseScore: 0.8),
        FoodItem(id: "mandu", name: "만두", category: .snack,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["만두", "간식"], baseScore: 0.9),
        FoodItem(id: "toast", name: "토스트", category: .snack,
                 mealTypes: [.breakfast, .lunch], restrictions: [.none],
                 tags: ["빵", "간편", "아침"], baseScore: 1.0),
    ]

    // MARK: - 기타 (Other)

    static let otherFoods: [FoodItem] = [
        FoodItem(id: "porridge", name: "죽", category: .other,
                 mealTypes: [.breakfast, .lunch], restrictions: [.glutenFree, .lowCalorie],
                 tags: ["죽", "가벼운", "아침"], baseScore: 0.9),
        FoodItem(id: "cereal", name: "시리얼", category: .other,
                 mealTypes: [.breakfast], restrictions: [.vegetarian],
                 tags: ["간편", "아침"], baseScore: 0.8),
        FoodItem(id: "yogurt_granola", name: "요거트 그래놀라", category: .other,
                 mealTypes: [.breakfast], restrictions: [.vegetarian],
                 tags: ["간편", "아침", "가벼운"], baseScore: 0.9),
        FoodItem(id: "pho", name: "쌀국수", category: .other,
                 mealTypes: [.lunch, .dinner], restrictions: [.glutenFree],
                 tags: ["면", "국물", "베트남"], baseScore: 1.0),
        FoodItem(id: "pad_thai", name: "팟타이", category: .other,
                 mealTypes: [.lunch, .dinner], restrictions: [.glutenFree],
                 tags: ["면", "볶음", "태국"], baseScore: 0.9),
        FoodItem(id: "burrito", name: "부리또", category: .other,
                 mealTypes: [.lunch, .dinner], restrictions: [.none],
                 tags: ["멕시칸", "간편"], baseScore: 0.9),
        FoodItem(id: "bibim_guksu", name: "비빔국수", category: .other,
                 mealTypes: [.lunch], restrictions: [.none],
                 tags: ["면", "매운", "차가운"], baseScore: 0.9),
    ]
}
