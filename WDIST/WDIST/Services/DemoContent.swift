import Foundation

enum DemoContent {
    static let samples: [ScreenshotItem] = [
        ScreenshotItem(assetIdentifier: "demo-internship", capturedAt: .now.addingTimeInterval(-86_400), ocrText: "LinkedIn\nProduct Design Intern at Northstar\nApplications close Friday", analysis: AIAnalysis(summary: "A LinkedIn listing for a Product Design Intern role at Northstar, with applications closing Friday.", category: "Job Posts", tags: ["LinkedIn", "internship", "product design", "Northstar"], importantEntities: ["Northstar", "Friday"]), isDemo: true),
        ScreenshotItem(assetIdentifier: "demo-recipe", capturedAt: .now.addingTimeInterval(-172_800), ocrText: "Creamy mushroom pasta\nIngredients: mushrooms, garlic, cream, parmesan", analysis: AIAnalysis(summary: "A creamy mushroom pasta recipe with garlic, cream, and parmesan.", category: "Recipes", tags: ["mushrooms", "pasta", "recipe", "dinner"], importantEntities: ["parmesan"]), isDemo: true),
        ScreenshotItem(assetIdentifier: "demo-qr", capturedAt: .now.addingTimeInterval(-259_200), ocrText: "Hackathon 2026\nScan to register\nAugust 22", analysis: AIAnalysis(summary: "A registration QR code for Hackathon 2026 on August 22.", category: "QR Codes", tags: ["QR code", "hackathon", "registration"], importantEntities: ["Hackathon 2026", "August 22"]), isDemo: true)
    ]
}
