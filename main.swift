
import SwiftUI

// MARK: - Data Models
struct User: ObservableObject {
    @Published var persona: Persona?
    @Published var xp: Int = 0
    @Published var coins: Int = 0
    @Published var level: Int = 1
    @Published var dailyStreak: Int = 0
    @Published var challengeStreak: Int = 0
    @Published var completedChallenges: [Challenge] = []
}

struct Persona {
    let id: Int
    let name: String
    let emoji: String
    let description: String
    let theme: String
    let investmentRange: String
}

struct Challenge {
    let id: String
    let title: String
    let description: String
    let type: ChallengeType
    let duration: Int
    let xpReward: Int
    let coinReward: Int
    var isCompleted: Bool = false
}

enum ChallengeType {
    case learning
    case action
}

struct QuizQuestion {
    let question: String
    let options: [String]
    var selectedIndex: Int?
}

// MARK: - View Models
class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .welcome
    @Published var user = User()
    @Published var quizAnswers: [Int] = []
    @Published var currentQuestionIndex = 0
    @Published var showReward = false
    
    let personas = [
        Persona(id: 1, name: "The Watcher", emoji: "👁️", description: "Observant, cautious", theme: "Micro-investing, streaks", investmentRange: "<$10"),
        Persona(id: 2, name: "The Strategist", emoji: "🧠", description: "Tactical, methodical", theme: "ETFs, planning, automation", investmentRange: "$25-100"),
        Persona(id: 3, name: "The Enforcer", emoji: "⚔️", description: "Bold, structured", theme: "Portfolio building, rebalancing", investmentRange: "$100-250"),
        Persona(id: 4, name: "The Oracle", emoji: "🔮", description: "Visionary, intuitive", theme: "Macroeconomics, forecasting", investmentRange: "$250-500"),
        Persona(id: 5, name: "The Phantom", emoji: "🦅", description: "Elite, dominant", theme: "High-risk strategies, experiments", investmentRange: "$500+")
    ]
    
    let quizQuestions = [
        QuizQuestion(question: "What's your investing experience?", options: ["Complete beginner", "Some knowledge", "Intermediate", "Advanced"]),
        QuizQuestion(question: "What's your main goal?", options: ["Build emergency fund", "Long-term growth", "Regular income", "High returns"]),
        QuizQuestion(question: "How often do you want challenges?", options: ["Daily", "Every few days", "Weekly", "When I have time"]),
        QuizQuestion(question: "Weekly investing amount?", options: ["Under $10", "$25-100", "$100-250", "$250-500", "$500+"])
    ]
    
    func assignPersona() {
        let investmentIndex = quizAnswers.last ?? 0
        user.persona = personas[investmentIndex]
    }
    
    func completeChallenge(_ challenge: Challenge) {
        user.xp += challenge.xpReward
        user.coins += challenge.coinReward
        user.completedChallenges.append(challenge)
        showReward = true
    }
}

enum AppScreen {
    case welcome
    case quiz
    case personaReveal
    case dashboard
    case challengePath
    case challengeDetail
    case paywall
    case leaderboard
}

// MARK: - Main App
struct DiviDashApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                switch viewModel.currentScreen {
                case .welcome:
                    WelcomeScreen(viewModel: viewModel)
                case .quiz:
                    QuizScreen(viewModel: viewModel)
                case .personaReveal:
                    PersonaRevealScreen(viewModel: viewModel)
                case .dashboard:
                    DashboardScreen(viewModel: viewModel)
                case .challengePath:
                    ChallengePathScreen(viewModel: viewModel)
                case .challengeDetail:
                    ChallengeDetailScreen(viewModel: viewModel)
                case .paywall:
                    PaywallScreen(viewModel: viewModel)
                case .leaderboard:
                    LeaderboardScreen(viewModel: viewModel)
                }
                
                if viewModel.showReward {
                    RewardOverlay(viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Welcome Screen
struct WelcomeScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("💎")
                .font(.system(size: 80))
            
            Text("DiviDash")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Gamified investing for the future")
                .font(.title2)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Start Your Journey") {
                viewModel.currentScreen = .quiz
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Quiz Screen
struct QuizScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.quizQuestions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.quizQuestions.count)")
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(viewModel.quizQuestions[viewModel.currentQuestionIndex].question)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 15) {
                ForEach(0..<viewModel.quizQuestions[viewModel.currentQuestionIndex].options.count, id: \.self) { index in
                    Button(viewModel.quizQuestions[viewModel.currentQuestionIndex].options[index]) {
                        selectAnswer(index)
                    }
                    .buttonStyle(QuizOptionButtonStyle())
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    func selectAnswer(_ index: Int) {
        if viewModel.quizAnswers.count <= viewModel.currentQuestionIndex {
            viewModel.quizAnswers.append(index)
        } else {
            viewModel.quizAnswers[viewModel.currentQuestionIndex] = index
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if viewModel.currentQuestionIndex < viewModel.quizQuestions.count - 1 {
                viewModel.currentQuestionIndex += 1
            } else {
                viewModel.assignPersona()
                viewModel.currentScreen = .personaReveal
            }
        }
    }
}

// MARK: - Persona Reveal Screen
struct PersonaRevealScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Your Persona")
                .font(.title)
                .foregroundColor(.white.opacity(0.8))
            
            if let persona = viewModel.user.persona {
                Text(persona.emoji)
                    .font(.system(size: 100))
                    .scaleEffect(1.2)
                
                Text(persona.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(persona.description)
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text(persona.theme)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
            
            Button("Enter DiviDash") {
                viewModel.currentScreen = .dashboard
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Dashboard Screen
struct DashboardScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        if let persona = viewModel.user.persona {
                            Text("Welcome, \(persona.name)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        HStack {
                            Text("🔥 \(viewModel.user.dailyStreak) day streak")
                            Text("⚡ \(viewModel.user.challengeStreak) challenges")
                        }
                        .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    // Avatar
                    if let persona = viewModel.user.persona {
                        Text(persona.emoji)
                            .font(.system(size: 50))
                            .background(Circle().fill(.white.opacity(0.2)))
                            .frame(width: 60, height: 60)
                    }
                }
                .padding()
                
                // Stats
                HStack(spacing: 20) {
                    StatCard(title: "XP", value: "\(viewModel.user.xp)", icon: "⭐")
                    StatCard(title: "Coins", value: "\(viewModel.user.coins)", icon: "🪙")
                    StatCard(title: "Level", value: "\(viewModel.user.level)", icon: "🏆")
                }
                .padding(.horizontal)
                
                // Quick Actions
                VStack(spacing: 15) {
                    Button("Start Challenge Path") {
                        viewModel.currentScreen = .challengePath
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    HStack(spacing: 15) {
                        Button("Paywall") {
                            viewModel.currentScreen = .paywall
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        
                        Button("Leaderboard") {
                            viewModel.currentScreen = .leaderboard
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}

// MARK: - Challenge Path Screen
struct ChallengePathScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    let sampleChallenges = [
        Challenge(id: "1", title: "What is a Stock?", description: "Learn the basics of stock investing", type: .learning, duration: 1, xpReward: 50, coinReward: 10),
        Challenge(id: "2", title: "ETF Fundamentals", description: "Understand Exchange Traded Funds", type: .learning, duration: 2, xpReward: 75, coinReward: 15),
        Challenge(id: "3", title: "Make Your First Investment", description: "Invest $1 in your first stock", type: .action, duration: 1, xpReward: 100, coinReward: 25)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("← Dashboard") {
                    viewModel.currentScreen = .dashboard
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("Challenge Path")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            
            Text("Swipe to choose a challenge")
                .foregroundColor(.white.opacity(0.7))
            
            TabView {
                ForEach(sampleChallenges, id: \.id) { challenge in
                    ChallengeCard(challenge: challenge, viewModel: viewModel)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 400)
            
            Spacer()
        }
    }
}

// MARK: - Challenge Detail Screen
struct ChallengeDetailScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button("← Back") {
                    viewModel.currentScreen = .challengePath
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            
            Text("📚")
                .font(.system(size: 80))
            
            Text("What is a Stock?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Learn the fundamentals of stock investing and how companies raise capital through public markets.")
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
            
            ProgressView(value: 0.3)
                .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                .scaleEffect(x: 1, y: 2, anchor: .center)
                .padding()
            
            Text("Progress: 30%")
                .foregroundColor(.yellow)
            
            Spacer()
            
            Button("Complete Today") {
                let challenge = Challenge(id: "1", title: "What is a Stock?", description: "Learn the basics", type: .learning, duration: 1, xpReward: 50, coinReward: 10)
                viewModel.completeChallenge(challenge)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Paywall Screen
struct PaywallScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Button("× Close") {
                    viewModel.currentScreen = .dashboard
                }
                .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            
            Text("🚀")
                .font(.system(size: 80))
            
            Text("Unlock Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "⚡", text: "2x XP Boost")
                FeatureRow(icon: "👑", text: "Premium Avatar Gear")
                FeatureRow(icon: "🏃", text: "Skip Path Steps")
                FeatureRow(icon: "🔄", text: "Switch Personas")
            }
            .padding()
            
            VStack(spacing: 15) {
                Button("$39.99/year (Save 33%)") {
                    // Handle subscription
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Button("$4.99/month") {
                    // Handle subscription
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button("Continue Free") {
                    viewModel.currentScreen = .dashboard
                }
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Leaderboard Screen
struct LeaderboardScreen: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("← Dashboard") {
                    viewModel.currentScreen = .dashboard
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("Leaderboard")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(1...10, id: \.self) { rank in
                        LeaderboardRow(rank: rank, name: "User \(rank)", xp: 1000 - (rank * 50), persona: viewModel.personas.randomElement()!)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
    }
}

// MARK: - Reward Overlay
struct RewardOverlay: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🎉")
                    .font(.system(size: 100))
                
                Text("Challenge Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 30) {
                    VStack {
                        Text("⭐")
                            .font(.system(size: 40))
                        Text("+50 XP")
                            .foregroundColor(.yellow)
                    }
                    
                    VStack {
                        Text("🪙")
                            .font(.system(size: 40))
                        Text("+10 Coins")
                            .foregroundColor(.yellow)
                    }
                }
                
                Button("Continue") {
                    viewModel.showReward = false
                    viewModel.currentScreen = .dashboard
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views
struct ChallengeCard: View {
    let challenge: Challenge
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text(challenge.type == .learning ? "📚" : "💰")
                .font(.system(size: 50))
            
            Text(challenge.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(challenge.description)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            HStack {
                Text("⭐ \(challenge.xpReward) XP")
                Text("🪙 \(challenge.coinReward) Coins")
            }
            .foregroundColor(.yellow)
            
            Button("Start Challenge") {
                viewModel.currentScreen = .challengeDetail
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.1))
                .stroke(.white.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack {
            Text(icon)
                .font(.title)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white.opacity(0.1))
        )
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            Text(text)
                .foregroundColor(.white)
            Spacer()
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let xp: Int
    let persona: Persona
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(.yellow)
                .frame(width: 40)
            
            Text(persona.emoji)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text(name)
                    .foregroundColor(.white)
                Text(persona.name)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("\(xp) XP")
                .foregroundColor(.yellow)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.1))
        )
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.yellow)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct QuizOptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white.opacity(0.2))
                    .stroke(.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - App Entry Point
@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
