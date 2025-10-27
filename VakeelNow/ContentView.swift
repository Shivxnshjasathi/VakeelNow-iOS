import SwiftUI
import Foundation
import Combine
import AVFoundation // Added for TextToSpeech
import UIKit // FIXED: Added to fix 'UIPasteboard' error

// MARK: - Models (from Models.swift)
struct Message: Identifiable, Codable, Equatable, Hashable { // FIXED: Added Hashable
    var id: String = UUID().uuidString
    let text: String
    let isFromUser: Bool
}

struct Conversation: Identifiable, Codable, Equatable, Hashable { // FIXED: Added Hashable
    var id: String = UUID().uuidString
    var title: String
    var messages: [Message]
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    
    // Helper to get the most recent message for the history list
    var lastMessageText: String {
        messages.last?.text ?? "No messages"
    }
}

// MARK: - Localization (from Localization.swift)
struct AppStrings {
    struct Language: Identifiable, Hashable {
        var id: String { code } // FIXED: Changed 'let' to 'var'
        let code: String
        let name: String
    }
    
    static let supportedLanguages = [
        Language(code: "en", name: "English"),
        Language(code: "hi", name: "हिन्दी"),
        Language(code: "bn", name: "বাংলা"),
        Language(code: "gu", name: "ગુજરાતી"),
        Language(code: "pa", name: "ਪੰਜਾਬੀ"),
        Language(code: "kn", name: "ಕನ್ನಡ"),
        Language(code: "ml", name: "മലയാളം"),
        Language(code: "or", name: "ଓଡ଼ିଆ"),
        Language(code: "ur", name: "اردو"),
        Language(code: "ta", name: "தமிழ்"),
        Language(code: "te", name: "తెలుగు")
    ]
    
    // String data
    // FIXED: Added all language data
    private static let strings: [String: [String: String]] = [
        "en": [
            "welcome_message": "Welcome to Vakeelnow! I am your AI Legal Assistant. How can I assist you today?",
            "new_chat": "New Chat",
            "start_new_chat": "Start New Chat",
            "find_lawyer": "Find a Lawyer",
            "recent_chats": "Recent Chats",
            "theme": "Theme",
            "language": "Language",
            "voice": "Voice",
            "app_title": "VakeelNow",
            "app_subtitle": "A Legal Assistant to help you with legal matters",
            "ask_anything": "Ask me anything...",
            "share_conversation": "Share Conversation",
            "find_local_lawyer": "Find a Local Lawyer",
            "enter_city": "Enter City",
            "area_of_law": "Area of Law",
            "search": "Search",
            "error_message": "Sorry, an error occurred: %s"
        ],
        "hi": [
            "welcome_message": "वकीलनॉउ में आपका स्वागत है! मैं आपका एआई कानूनी सहायक हूं। मैं आज आपकी कैसे सहायता कर सकता हूं?",
            "new_chat": "नई चैट",
            "start_new_chat": "नई चैट शुरू करें",
            "find_lawyer": "वकील खोजें",
            "recent_chats": "हाल की चैट",
            "theme": "थीम",
            "language": "भाषा",
            "voice": "आवाज़",
            "app_title": "वकीलनॉउ",
            "app_subtitle": "कानूनी मामलों में आपकी मदद करने के लिए एक कानूनी सहायक",
            "ask_anything": "मुझसे कुछ भी पूछें...",
            "share_conversation": "बातचीत साझा करें",
            "find_local_lawyer": "स्थानीय वकील खोजें",
            "enter_city": "शहर दर्ज करें",
            "area_of_law": "कानून का क्षेत्र",
            "search": "खोजें",
            "error_message": "क्षमा करें, एक त्रुटि हुई: %s"
        ],
        "bn": [
            "welcome_message": "Vakeelnow-তে স্বাগতম! আমি আপনার AI আইনি সহকারী। আমি আজ আপনাকে কিভাবে সাহায্য করতে পারি?",
            "new_chat": "নতুন চ্যাট",
            "start_new_chat": "নতুন চ্যাট শুরু করুন",
            "find_lawyer": "আইনজীবী খুঁজুন",
            "recent_chats": "সাম্প্রতিক চ্যাট",
            "theme": "থিম",
            "language": "ভাষা",
            "voice": "কণ্ঠ",
            "app_title": "VakeelNow",
            "app_subtitle": "আইনি বিষয়ে আপনাকে সাহায্য করার জন্য একজন আইনি সহকারী",
            "ask_anything": "আমাকে কিছু জিজ্ঞাসা করুন...",
            "share_conversation": "কথোপকথন শেয়ার করুন",
            "find_local_lawyer": "স্থানীয় আইনজীবী খুঁজুন",
            "enter_city": "শহর লিখুন",
            "area_of_law": "আইনের ক্ষেত্র",
            "search": "অনুসন্ধান করুন",
            "error_message": "দুঃখিত, একটি ত্রুটি ঘটেছে: %s"
        ],
        "gu": [
            "welcome_message": "વકીલનાઉમાં આપનું સ્વાગત છે! હું તમારો AI કાનૂની સહાયક છું. હું આજે તમને કેવી રીતે મદદ કરી શકું?",
            "new_chat": "નવી ચેટ",
            "start_new_chat": "નવી ચેટ શરૂ કરો",
            "find_lawyer": "વકીલ શોધો",
            "recent_chats": "તાજેતરની ચેટ્સ",
            "theme": "થીમ",
            "language": "ભાષા",
            "voice": "અવાજ",
            "app_title": "વકીલનાઉ",
            "app_subtitle": "કાનૂની બાબતોમાં તમને મદદ કરવા માટે કાનૂની સહાયક",
            "ask_anything": "મને કંઈપણ પૂછો...",
            "share_conversation": "વાર્તાલાપ શેર કરો",
            "find_local_lawyer": "સ્થાનિક વકીલ શોધો",
            "enter_city": "શહેર દાખલ કરો",
            "area_of_law": "કાયદાનું ક્ષેત્ર",
            "search": "શોધો",
            "error_message": "માફ કરશો, એક ભૂલ આવી: %s"
        ],
        "pa": [
            "welcome_message": "ਵਕੀਲਨਾਉ ਵਿੱਚ ਤੁਹਾਡਾ ਸੁਆਗਤ ਹੈ! ਮੈਂ ਤੁਹਾਡਾ ਏਆਈ ਕਾਨੂੰਨੀ ਸਹਾਇਕ ਹਾਂ। ਮੈਂ ਅੱਜ ਤੁਹਾਡੀ ਕਿਵੇਂ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ?",
            "new_chat": "ਨਵੀਂ ਗੱਲਬਾਤ",
            "start_new_chat": "ਨਵੀਂ ਗੱਲਬਾਤ ਸ਼ੁਰੂ ਕਰੋ",
            "find_lawyer": "ਵਕੀਲ ਲੱਭੋ",
            "recent_chats": "ਹਾਲੀਆ ਗੱਲਬਾਤਾਂ",
            "theme": "ਥੀਮ",
            "language": "ਭਾਸ਼ਾ",
            "voice": "ਆਵਾਜ਼",
            "app_title": "ਵਕੀਲਨਾਉ",
            "app_subtitle": "ਕਾਨੂੰਨੀ ਮਾਮਲਿਆਂ ਵਿੱਚ ਤੁਹਾਡੀ ਮਦਦ ਕਰਨ ਲਈ ਇੱਕ ਕਾਨੂੰਨੀ ਸਹਾਇਕ",
            "ask_anything": "ਮੈਨੂੰ ਕੁਝ ਵੀ ਪੁੱਛੋ...",
            "share_conversation": "ਗੱਲਬਾਤ ਸਾਂਝੀ ਕਰੋ",
            "find_local_lawyer": "ਸਥਾਨਕ ਵਕੀਲ ਲੱਭੋ",
            "enter_city": "ਸ਼ਹਿਰ ਦਾਖਲ ਕਰੋ",
            "area_of_law": "ਕਾਨੂੰਨ ਦਾ ਖੇਤਰ",
            "search": "ਖੋਜ",
            "error_message": "ਮੁਆਫ ਕਰਨਾ, ਇੱਕ ਗਲਤੀ ਹੋਈ: %s"
        ],
        "kn": [
            "welcome_message": "ವಕೀಲ್‌ನೌಗೆ ಸುಸ್ವಾಗತ! ನಾನು ನಿಮ್ಮ AI ಕಾನೂನು ಸಹಾಯಕ. ನಾನು ಇಂದು ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಲಿ?",
            "new_chat": "ಹೊಸ ಚಾಟ್",
            "start_new_chat": "ಹೊಸ ಚಾಟ್ ಪ್ರಾರಂಭಿಸಿ",
            "find_lawyer": "ವಕೀಲರನ್ನು ಹುಡುಕಿ",
            "recent_chats": "ಇತ್ತೀಚಿನ ಚಾಟ್‌ಗಳು",
            "theme": "ಥೀಮ್",
            "language": "ಭಾಷೆ",
            "voice": "ಧ್ವನಿ",
            "app_title": "ವಕೀಲ್‌ನೌ",
            "app_subtitle": "ಕಾನೂನು ವಿಷಯಗಳಲ್ಲಿ ನಿಮಗೆ ಸಹಾಯ ಮಾಡಲು ಕಾನೂನು ಸಹಾಯಕ",
            "ask_anything": "ನನ್ನನ್ನು ಏನು ಬೇಕಾದರೂ ಕೇಳಿ...",
            "share_conversation": "ಸಂಭಾಷಣೆಯನ್ನು ಹಂಚಿಕೊಳ್ಳಿ",
            "find_local_lawyer": "ಸ್ಥಳೀಯ ವಕೀಲರನ್ನು ಹುಡುಕಿ",
            "enter_city": "ನಗರವನ್ನು ನಮೂದಿಸಿ",
            "area_of_law": "ಕಾನೂನಿನ ಕ್ಷೇತ್ರ",
            "search": "ಹುಡುಕಿ",
            "error_message": "ಕ್ಷಮಿಸಿ, ದೋಷವೊಂದು ಸಂಭವಿಸಿದೆ: %s"
        ],
        "ml": [
            "welcome_message": "വക്കീൽനൗ-ലേക്ക് സ്വാഗതം! ഞാൻ നിങ്ങളുടെ AI നിയമ സഹായിയാണ്. ഇന്ന് ഞാൻ നിങ്ങളെ എങ്ങനെ സഹായിക്കും?",
            "new_chat": "പുതിയ ചാറ്റ്",
            "start_new_chat": "പുതിയ ചാറ്റ് ആരംഭിക്കുക",
            "find_lawyer": "അഭിഭാഷകനെ കണ്ടെത്തുക",
            "recent_chats": "സമീപകാല ചാറ്റുകൾ",
            "theme": "തീം",
            "language": "ഭാഷ",
            "voice": "ശബ്ദം",
            "app_title": "വക്കീൽനൗ",
            "app_subtitle": "നിയമപരമായ കാര്യങ്ങളിൽ നിങ്ങളെ സഹായിക്കാൻ ഒരു നിയമ സഹായി",
            "ask_anything": "എന്നെ എന്തും ചോദിക്കൂ...",
            "share_conversation": "സംഭാഷണം പങ്കിടുക",
            "find_local_lawyer": "പ്രാദേശിക അഭിഭാഷകനെ കണ്ടെത്തുക",
            "enter_city": "നഗരം നൽകുക",
            "area_of_law": "നിയമ മേഖല",
            "search": "തിരയുക",
            "error_message": "ക്ഷമിക്കണം, ഒരു പിശക് സംഭവിച്ചു: %s"
        ],
        "or": [
            "welcome_message": "Vakeelnowକୁ ସ୍ଵାଗତ! ମୁଁ ଆପଣଙ୍କର AI ଆଇନଗତ ସହାୟକ। ମୁଁ ଆଜି ଆପଣଙ୍କୁ କିପରି ସାହାଯ୍ୟ କରିପାରିବି?",
            "new_chat": "ନୂଆ ଚାଟ୍",
            "start_new_chat": "ନୂଆ ଚାଟ୍ ଆରମ୍ଭ କରନ୍ତୁ",
            "find_lawyer": "ଓକିଲ ଖୋଜନ୍ତୁ",
            "recent_chats": "ସାମ୍ପ୍ରତିକ ଚାଟ୍",
            "theme": "ଥିମ୍",
            "language": "ଭਾଷା",
            "voice": "ଭଏସ୍",
            "app_title": "VakeelNow",
            "app_subtitle": "ଆଇନଗତ ମାମଲାରେ ଆପଣଙ୍କୁ ସାହାଯଯ କରିବା ପାଇଁ ଜଣେ ଆଇନଗତ ସହାୟକ",
            "ask_anything": "ମୋତେ କିଛି ବି ପଚାରନ୍ତୁ...",
            "share_conversation": "ବାର୍ତ୍ତାଳପ ସେୟାର କରନ୍ତୁ",
            "find_local_lawyer": "ସ୍ଥାନୀୟ ଓକିଲ ଖୋଜନ୍ତୁ",
            "enter_city": "ସହର ପ୍ରବେଶ କରନ୍ତୁ",
            "area_of_law": "ଆଇନର କ୍ଷେତ୍ର",
            "search": "ଖୋଜନ୍ତୁ",
            "error_message": "ଦୁଃଖିତ, ଏକ ତ୍ରୁଟି ଘଟିଛି: %s"
        ],
        "ur": [
            "welcome_message": "Vakeelnow میں خوش آمدید! میں آپ کا AI قانونی اسسٹنٹ ہوں۔ میں آج آپ کی کس طرح مدد کر سکتا ہوں؟",
            "new_chat": "نئی چیٹ",
            "start_new_chat": "نئی چیٹ شروع کریں",
            "find_lawyer": "وکیل تلاش کریں",
            "recent_chats": "حالیہ چیٹس",
            "theme": "تھیم",
            "language": "زبان",
            "voice": "آواز",
            "app_title": "VakeelNow",
            "app_subtitle": "قانونی معاملات میں آپ کی مدد کے لیے ایک قانونی اسسٹنٹ",
            "ask_anything": "مجھ سے کچھ بھی پوچھیں...",
            "share_conversation": "گفتگو کا اشتراک کریں",
            "find_local_lawyer": "مقامی وکیل تلاش کریں",
            "enter_city": "شہر درج کریں",
            "area_of_law": "قانون کا شعبہ",
            "search": "تلاش کریں",
            "error_message": "معذرت، ایک خرابی پیش آگئی: %s"
        ],
        "ta": [
            "welcome_message": "Vakeelnow-க்கு வரவேற்கிறோம்! நான் உங்கள் AI சட்ட உதவியாளர். இன்று நான் உங்களுக்கு எப்படி உதவ முடியும்?",
            "new_chat": "புதிய அரட்டை",
            "start_new_chat": "புதிய அரட்டையைத் தொடங்கு",
            "find_lawyer": "வழக்கறிஞரைக் கண்டுபிடி",
            "recent_chats": "சமீபத்திய அரட்டைகள்",
            "theme": "தீம்",
            "language": "மொழி",
            "voice": "குரல்",
            "app_title": "VakeelNow",
            "app_subtitle": "சட்ட விஷயங்களில் உங்களுக்கு உதவ ஒரு சட்ட உதவியாளர்",
            "ask_anything": "என்னிடம் எதையும் கேளுங்கள்...",
            "share_conversation": "உரையாடலைப் பகிரவும்",
            "find_local_lawyer": "உள்ளூர் வழக்கறிஞரைக் கண்டுபிடி",
            "enter_city": "நகரத்தை உள்ளிடவும்",
            "area_of_law": "சட்டப் பகுதி",
            "search": "தேடு",
            "error_message": "மன்னிக்கவும், ஒரு பிழை ஏற்பட்டது: %s"
        ],
        "te": [
            "welcome_message": "వకీల్‌నౌకు స్వాగతం! నేను మీ AI లీగల్ అసిస్టెంట్‌ని. ఈ రోజు నేను మీకు ఎలా సహాయపడగలను?",
            "new_chat": "కొత్త చాట్",
            "start_new_chat": "కొత్త చాట్ ప్రారంభించండి",
            "find_lawyer": "న్యాయవాదిని కనుగొనండి",
            "recent_chats": "ఇటీవలి చాట్‌లు",
            "theme": "థీమ్",
            "language": "భాష",
            "voice": "వాయిస్",
            "app_title": "వకీల్‌నౌ",
            "app_subtitle": "చట్టపరమైన విషయాలలో మీకు సహాయం చేయడానికి ఒక లీగల్ అసిస్టెంట్",
            "ask_anything": "నన్ను ఏదైనా అడగండి...",
            "share_conversation": "సంభాషణను పంచుకోండి",
            "find_local_lawyer": "స్థానిక న్యాయవాదిని కనుగొనండి",
            "enter_city": "నగరాన్ని నమోదు చేయండి",
            "area_of_law": "చట్టం యొక్క ప్రాంతం",
            "search": "వెతకండి",
            "error_message": "క్షమించండి, లోపం సంభవించింది: %s"
        ]
    ]

    
    // Helper function to get the correct string
    static func getString(_ langCode: String, key: String) -> String {
        return strings[langCode]?[key] ?? strings["en"]?[key] ?? ""
    }
}

// MARK: - Theme (from Theme.swift)
extension Color {
    // Light Colors
    static let lightPrimary = Color(hex: "#006AFF")
    static let lightBackground = Color(hex: "#F4F6FC") // Light gray background
    static let lightSurface = Color(hex: "#FFFFFF") // White surface for bubbles/rows
    static let lightOnSurface = Color(hex: "#1C1C1E")
    
    // Dark Colors
    static let darkPrimary = Color(hex: "#7B9BFF")
    static let darkBackground = Color(hex: "#121212") // Very dark background
    static let darkSurface = Color(hex: "#1E1E1E") // Dark gray for bubbles/rows
    static let darkOnSurface = Color(hex: "#EAEAEA")
    
    // Helper to initialize Color from a hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// We can define our custom bubble shape
struct ChatBubbleShape: Shape {
    var isFromUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [
                                    .topLeft,
                                    .topRight,
                                    isFromUser ? .bottomLeft : .bottomRight
                                ],
                                cornerRadii: CGSize(width: 20, height: 20))
        return Path(path.cgPath)
    }
}

// MARK: - Data Persistence (from ConversationRepository.swift)
@MainActor // FIXED: Added to resolve concurrency warnings
class ConversationRepository: ObservableObject {
    @Published var conversations: [Conversation] {
        didSet { saveConversations() }
    }
    
    private let conversationsKey = "conversation_history"
    
    init() {
        self.conversations = [] // Start empty
        self.conversations = loadConversations() // Then load
    }
    
    func createNewConversation(langCode: String) -> Conversation {
        let welcomeMessage = Message(
            text: AppStrings.getString(langCode, key: "welcome_message"),
            isFromUser: false
        )
        return Conversation(
            title: AppStrings.getString(langCode, key: "new_chat"),
            messages: [welcomeMessage]
        )
    }
    
    func addOrUpdateConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            // Update existing
            conversations[index] = conversation
        } else {
            // Add new
            conversations.insert(conversation, at: 0)
        }
        // Sort by timestamp
        conversations.sort { $0.timestamp > $1.timestamp }
    }
    
    func deleteConversation(at offsets: IndexSet) {
        conversations.remove(atOffsets: offsets)
    }
    
    func deleteConversation(id: String) {
        conversations.removeAll { $0.id == id }
    }

    private func saveConversations() {
        if let encoded = try? JSONEncoder().encode(conversations) {
            UserDefaults.standard.set(encoded, forKey: conversationsKey)
        }
    }
    
    private func loadConversations() -> [Conversation] {
        if let data = UserDefaults.standard.data(forKey: conversationsKey),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            return decoded
        }
        return []
    }
}

// MARK: - Networking (from APIService.swift)
class APIService {
    // This prompt is taken directly from your Android code
    private let basePrompt = "Think of me as your guide through the complexities of Indian law. I'll help you understand your situation from a legal perspective, drawing on experience with the Indian Constitution, various laws like the IPC, CrPC, CPC, and the Contract Act, and the procedures of our courts.\n\nMy goal is to provide you with a comprehensive, structured, and educational analysis of your legal situation for informational purposes only. It is crucial to understand that I am not providing a definitive legal opinion or legal advice, and this interaction does not create a lawyer-client relationship.\n\nTo give you the clearest possible picture, I will break everything down for you using the following structure:\n1. Initial Disclaimer: I'll start with a clear disclaimer so you understand the nature of this analysis.2. Summary of Your Situation: First, I'll summarize the facts as I understand them. This is to ensure we are both on the same page before we proceed.3. The Core Legal Questions: Based on the facts, I'll pinpoint the central legal issues at stake. Are we looking at a breach of contract? A potential criminal offense? A violation of your rights? This is where we define the legal battleground.4. The Laws That Apply: I'll walk you through the specific laws and sections that are relevant here. I'll cite the relevant Acts and explain, in plain English, what each legal provision means for you.5. How Past Court Cases Might Affect You: Precedent is key in our legal system. I'll discuss important rulings from the Supreme Court and relevant High Courts. I'll explain the stories behind these cases and how the court's reasoning (ratio decidendi) might influence the outcome of a situation like yours.6. Your Constitutional Rights (If Applicable): If your fundamental rights are in question, we'll look directly at the Constitution of India. I'll explain the specific Articles that protect you and how they apply here.7. Detailed Analysis of Your Position: This is the heart of our discussion. I'll connect the dots between the facts of your case, the applicable laws, and the court precedents. We'll discuss what you'd need to prove to make your case, the strengths of your position, and the nuances a judge would likely consider.8. Potential Challenges and The Other Side's Arguments: To be fully prepared, you need to see the whole picture. I'll outline potential weaknesses in your position and the arguments an opposing party is likely to raise. We'll also cover common hurdles, like challenges in gathering evidence.9. The Typical Path Forward: So, what usually happens in these situations? I'll outline a typical step-by-step procedural path—from gathering evidence and sending a legal notice to filing a case in the appropriate court or considering mediation. This isn't me telling you what to do, but rather showing you the road map for matters like these.10. Final Concluding Disclaimer: I will end by reiterating that this analysis is for your information only and will strongly recommend that you consult with a qualified lawyer for formal advice tailored to your specific case.Here is my situation:"
    
    func fetchResponse(for query: String) async throws -> String {
        let fullPrompt = "\(basePrompt) \(query)"
        
        guard let encodedPrompt = fullPrompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw URLError(.badURL)
        }
        
        guard let url = URL(string: "https://text.pollinations.ai/\(encodedPrompt)") else {
            throw URLError(.badURL)
        }
        
        // Perform the network request
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decode the response
        guard let result = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return result
    }
}

// MARK: - Text-to-Speech (from TextToSpeechService.swift)
@MainActor // FIXED: Added to resolve concurrency warnings
class TextToSpeechService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var playingMessageId: String? = nil
    @Published var availableVoices: [AVSpeechSynthesisVoice] = []
    
    private var currentLanguageCode: String = "en-US"
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func setLanguage(langCode: String) {
        // Map app lang code to BCP-47 code for speech
        let bcp47Code = Locale.canonicalLanguageIdentifier(from: langCode)
        currentLanguageCode = bcp47Code
        
        // Update available voices for this language
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == bcp47Code }
            .sorted { $0.name < $1.name }
    }
    
    func speak(message: Message, voiceIdentifier: String) {
        if synthesizer.isSpeaking {
            stop()
            if playingMessageId == message.id {
                // Was playing this message, so just stop
                return
            }
        }
        
        let utterance = AVSpeechUtterance(string: message.text)
        
        // Find the selected voice or use a default for the language
        if let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: currentLanguageCode)
        }

        // Store the ID *before* speaking
        self.playingMessageId = message.id
        synthesizer.speak(utterance)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        playingMessageId = nil
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.playingMessageId = nil
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.playingMessageId = nil
        }
    }
}

// MARK: - Sidebar View (from DrawerContentView.swift)
struct DrawerContentView: View {
    @EnvironmentObject private var repository: ConversationRepository
    @EnvironmentObject private var ttsService: TextToSpeechService
    @Environment(\.colorScheme) private var colorScheme

    @Binding var selection: Conversation?
    @Binding var showLawyerSearch: Bool
    @Binding var languageCode: String
    @Binding var isDarkMode: Bool
    @Binding var isDrawerOpen: Bool // NEW: To close the drawer
    
    @AppStorage("voiceIdentifier") private var voiceIdentifier: String = ""
    
    // FIXED: Use correct colors for backgrounds
    private var drawerBgColor: Color { colorScheme == .dark ? .black : .white }
    private var listBgColor: Color { colorScheme == .dark ? .black : Color(.systemGroupedBackground) } // Slightly gray list background in light mode
    private var surfaceColor: Color { colorScheme == .dark ? Color.darkSurface : Color.lightSurface }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // --- App Title ---
            VStack(alignment: .leading) {
                Text(AppStrings.getString(languageCode, key: "app_title"))
                    .font(.title2)
                    .fontWeight(.bold)
                Text(AppStrings.getString(languageCode, key: "app_subtitle"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            // --- Top Buttons ---
            VStack(spacing: 12) {
                Button {
                    let newConvo = repository.createNewConversation(langCode: languageCode)
                    repository.addOrUpdateConversation(newConvo)
                    selection = newConvo
                    isDrawerOpen = false // Close drawer
                } label: {
                    Label(AppStrings.getString(languageCode, key: "start_new_chat"), systemImage: "plus")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorScheme == .dark ? .darkPrimary : .lightPrimary)
                
                Button {
                    showLawyerSearch = true
                    isDrawerOpen = false // Close drawer
                } label: {
                    Label(AppStrings.getString(languageCode, key: "find_lawyer"), systemImage: "magnifyingglass")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(colorScheme == .dark ? .darkPrimary : .lightPrimary)
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // --- RECENT CHATS ---
            List(selection: $selection) {
                Section(header: Text(AppStrings.getString(languageCode, key: "recent_chats"))) {
                    ForEach(repository.conversations) { conversation in
                        ConversationHistoryItem(conversation: conversation)
                            .tag(conversation) // Makes the row selectable
                            .swipeActions(allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    if selection?.id == conversation.id {
                                        selection = nil
                                    }
                                    repository.deleteConversation(id: conversation.id)
                                } label: {
                                    Label("Delete", systemImage: "trash.fill")
                                }
                            }
                            // Use surface color for rows
                            .listRowBackground(surfaceColor)
                            
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)) // Add padding
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            
            .background(surfaceColor) // Use list background color
            .onChange(of: selection) { oldValue, newValue in
                // Close drawer when a chat is selected
                if newValue != nil {
                    isDrawerOpen = false
                }
            }
            
            // --- SETTINGS ---
            VStack(spacing: 0) {
                Divider()

                Toggle(isOn: $isDarkMode.animation()) {
                    Label(AppStrings.getString(languageCode, key: "theme"), systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                }
                .padding()

                Divider()

                HStack {
                    Label(AppStrings.getString(languageCode, key: "language"), systemImage: "globe")
                    Spacer()
                    Picker(selection: $languageCode) {
                        ForEach(AppStrings.supportedLanguages) { lang in
                            Text(lang.name).tag(lang.code)
                        }
                    } label: { Text("Language") }.pickerStyle(.menu)
                    .tint(colorScheme == .dark ? .darkOnSurface : .lightOnSurface)
                }
                .padding()

                Divider()

                HStack {
                    Label(AppStrings.getString(languageCode, key: "voice"), systemImage: "speaker.wave.2.fill")
                    Spacer()
                    Picker(selection: $voiceIdentifier) {
                        if ttsService.availableVoices.isEmpty {
                            Text("Default Voice").tag("")
                        }
                        ForEach(ttsService.availableVoices, id: \.identifier) { voice in
                            Text(voice.name).tag(voice.identifier)
                        }
                    } label: { Text("Voice") }.pickerStyle(.menu)
                    .tint(colorScheme == .dark ? .darkOnSurface : .lightOnSurface)
                    .disabled(ttsService.availableVoices.isEmpty)
                }
                .padding()
            }
            .background(surfaceColor) // Use surface color for settings
        }
        .background(drawerBgColor) // FIXED: Use white/black for main drawer background
    }
}

// --- List Item View (from DrawerContentView.swift) ---
struct ConversationHistoryItem: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title)
                .font(.headline)
                .lineLimit(1)
            Text(conversation.lastMessageText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Chat Screen (from ChatScreen.swift)
struct ChatScreen: View {
    @Binding var conversation: Conversation
    var onOpenDrawer: () -> Void // NEW: Closure to open the drawer
    
    @EnvironmentObject private var repository: ConversationRepository
    @EnvironmentObject private var ttsService: TextToSpeechService
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("languageCode") private var languageCode: String = "en"
    @AppStorage("voiceIdentifier") private var voiceIdentifier: String = ""

    @State private var userInput: String = ""
    @State private var isLoading: Bool = false
    @State private var apiService = APIService()

    var body: some View {
        VStack(spacing: 0) {
            // --- MESSAGE LIST ---
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(conversation.messages) { message in
                            MessageView(
                                message: message,
                                isPlaying: ttsService.playingMessageId == message.id,
                                onPlaybackToggle: {
                                    ttsService.speak(message: message, voiceIdentifier: voiceIdentifier)
                                }
                            )
                            .id(message.id)
                        }
                        
                        if isLoading {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .background(colorScheme == .dark ? Color.darkBackground : Color.lightBackground)
                // FIXED: Add a tap gesture to the ScrollView to dismiss the keyboard
                .onTapGesture {
                    dismissKeyboard()
                }
                .onChange(of: conversation.messages.count) { oldValue, newValue in
                    scrollToBottom(proxy: proxy)
                }
                .onAppear {
                    scrollToBottom(proxy: proxy)
                }
            }
            
            // --- INPUT BAR ---
            ChatInputBar(
                text: $userInput,
                hint: AppStrings.getString(languageCode, key: "ask_anything"),
                isLoading: isLoading,
                onSend: sendMessage
            )
        }
        .navigationTitle(conversation.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // NEW: Hamburger menu button
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onOpenDrawer) {
                    Image(systemName: "line.3.horizontal")
                }
            }
            
            // --- SHARE BUTTON ---
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: generateShareText()) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .background(colorScheme == .dark ? Color.darkBackground : Color.lightBackground)
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let userMessage = Message(text: userInput, isFromUser: true)
        conversation.messages.append(userMessage)
        
        if conversation.messages.filter({ $0.isFromUser }).count == 1 {
            conversation.title = userInput
        }
        
        let query = userInput
        userInput = ""
        isLoading = true
        
        repository.addOrUpdateConversation(conversation)
        
        Task {
            do {
                let responseText = try await apiService.fetchResponse(for: query)
                let botMessage = Message(text: responseText, isFromUser: false)
                conversation.messages.append(botMessage)
            } catch {
                let errorMessage = AppStrings.getString(languageCode, key: "error_message")
                let errorBotMessage = Message(text: String(format: errorMessage, error.localizedDescription), isFromUser: false)
                conversation.messages.append(errorBotMessage)
            }
            
            isLoading = false
            repository.addOrUpdateConversation(conversation)
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastId = conversation.messages.last?.id {
            withAnimation(.spring()) {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
    
    private func generateShareText() -> String {
        conversation.messages.map {
            "\( $0.isFromUser ? "You" : "AI" ):\n\($0.text)"
        }.joined(separator: "\n\n")
    }
    
    // FIXED: Helper function to dismiss the keyboard
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// --- MESSAGE BUBBLE VIEW (from ChatScreen.swift) ---
struct MessageView: View {
    let message: Message
    let isPlaying: Bool
    let onPlaybackToggle: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
            // --- THE BUBBLE ---
            Text(message.text)
                .padding()
                .background(bubbleBackground)
                .foregroundStyle(message.isFromUser ? .white : (colorScheme == .dark ? Color.darkOnSurface : Color.lightOnSurface))
                .clipShape(ChatBubbleShape(isFromUser: message.isFromUser))
                .frame(maxWidth: 320, alignment: message.isFromUser ? .trailing : .leading)
            
            // --- ACTION BUTTONS ---
            HStack {
                // Copy Button
                Button {
                    UIPasteboard.general.string = message.text
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.caption)
                }
                
                // TTS Button (Bot only)
                if !message.isFromUser {
                    Button(action: onPlaybackToggle) {
                        Image(systemName: isPlaying ? "stop.fill" : "speaker.wave.2.fill")
                            .font(.caption)
                            .foregroundStyle(isPlaying ? Color.accentColor : .secondary)
                    }
                }
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, alignment: message.isFromUser ? .trailing : .leading)
    }
    
    // Custom bubble background (gradient for user)
    @ViewBuilder
    private var bubbleBackground: some View {
        if message.isFromUser {
            LinearGradient(
                colors: [colorScheme == .dark ? .darkPrimary : .lightPrimary, Color(hex: "#3A86FF")],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            colorScheme == .dark ? Color.darkSurface : Color.lightSurface
        }
    }
}

// --- CHAT INPUT BAR (from ChatScreen.swift) ---
struct ChatInputBar: View {
    @Binding var text: String
    var hint: String
    var isLoading: Bool
    let onSend: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            TextField(hint, text: $text, axis: .vertical)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? Color.darkSurface : Color.lightSurface)
                .clipShape(Capsule())
                .lineLimit(1...5)
            
            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.headline.weight(.bold))
                    .padding(10)
                    .background(colorScheme == .dark ? Color.darkPrimary : Color.lightPrimary)
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    .clipShape(Circle())
            }
            .disabled(text.isEmpty || isLoading)
            .opacity(text.isEmpty ? 0.5 : 1.0)
        }
        .padding()
        .background(colorScheme == .dark ? Color.darkBackground : Color.lightBackground)
    }
}

// --- TYPING INDICATOR (from ChatScreen.swift) ---
struct TypingIndicator: View {
    @State private var scale: [CGFloat] = [0.5, 0.5, 0.5]
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 8, height: 8)
                    .scaleEffect(scale[i])
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15)) {
                            scale[i] = 1.0
                        }
                    }
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.darkSurface : Color.lightSurface)
        .clipShape(ChatBubbleShape(isFromUser: false))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Lawyer Search View (from FindLawyerView.swift)
struct FindLawyerView: View {
    let languageCode: String
    @State private var city: String = ""
    @State private var areaOfLaw: String = "Civil"
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let lawAreas = ["Civil", "Criminal", "Family", "Corporate", "Tax", "Intellectual Property"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(AppStrings.getString(languageCode, key: "find_local_lawyer"))) {
                    TextField(AppStrings.getString(languageCode, key: "enter_city"), text: $city)
                    
                    Picker(AppStrings.getString(languageCode, key: "area_of_law"), selection: $areaOfLaw) {
                        ForEach(lawAreas, id: \.self) { area in
                            Text(area).tag(area)
                        }
                    }
                }
                
                Section {
                    Button(action: search) {
                        Label(AppStrings.getString(languageCode, key: "search"), systemImage: "magnifyingglass")
                    }
                    .disabled(city.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle(AppStrings.getString(languageCode, key: "find_lawyer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func search() {
        let query = "\(areaOfLaw) lawyer in \(city)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.google.com/search?q=\(encodedQuery)") else {
            return
        }
        
        openURL(url)
        dismiss()
    }
}


// MARK: - Main Content View
struct ContentView: View {
    // Get the services from the environment
    @EnvironmentObject private var repository: ConversationRepository
    @EnvironmentObject private var ttsService: TextToSpeechService
    
    // State for the currently selected conversation
    @State private var currentConversation: Conversation?
    
    // State for managing app settings
    @AppStorage("languageCode") private var languageCode: String = "en"
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // State for the lawyer search modal
    @State private var showLawyerSearch = false
    
    // NEW: State for controlling the drawer
    @State private var isDrawerOpen = false
    private let drawerWidth = UIScreen.main.bounds.width * 0.85

    var body: some View {
        // NEW: Replaced NavigationSplitView with ZStack for slide-out drawer
        ZStack(alignment: .leading) {
            // --- MAIN CONTENT (CHAT SCREEN) ---
            NavigationStack {
                // Show chat screen or a placeholder
                if let conversation = currentConversation,
                   let binding = $repository.conversations.first(where: { $0.id == conversation.id }) {
                    ChatScreen(
                        conversation: binding,
                        onOpenDrawer: {
                            withAnimation(.spring()) {
                                isDrawerOpen = true
                            }
                        }
                    )
                } else {
                    // Placeholder when no chat is selected (e.g., first launch)
                    VStack {
                        Text("Welcome to VakeelNow")
                            .font(.title)
                        Text("Select a chat or start a new one.")
                            .foregroundStyle(.secondary)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    isDrawerOpen = true
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                            }
                        }
                    }
                }
            }
            .disabled(isDrawerOpen) // Disable main content when drawer is open
            .blur(radius: isDrawerOpen ? 3.0 : 0) // Blur main content
            
            // --- SCRIM (DIMMED BACKGROUND) ---
            if isDrawerOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isDrawerOpen = false
                        }
                    }
            }
            
            // --- DRAWER (SIDEBAR) ---
            DrawerContentView(
                selection: $currentConversation,
                showLawyerSearch: $showLawyerSearch,
                languageCode: $languageCode,
                isDarkMode: $isDarkMode,
                isDrawerOpen: $isDrawerOpen // Pass binding to close
            )
            .frame(width: drawerWidth)
            .offset(x: isDrawerOpen ? 0 : -drawerWidth) // Slide in/out
            //.shadow(radius: 10)
        }
        .sheet(isPresented: $showLawyerSearch) {
            FindLawyerView(languageCode: languageCode)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .onAppear {
            if currentConversation == nil {
                // On first launch, check if we have old convos
                if let firstConvo = repository.conversations.first {
                    currentConversation = firstConvo
                } else {
                    // If not, create a new one
                    let newConvo = repository.createNewConversation(langCode: languageCode)
                    repository.addOrUpdateConversation(newConvo)
                    currentConversation = newConvo
                }
            }
        }
        .onChange(of: languageCode) { oldValue, newLang in
            ttsService.setLanguage(langCode: newLang)
            
            if var convo = currentConversation, convo.messages.count == 1, !convo.messages[0].isFromUser {
                let newWelcome = AppStrings.getString(newLang, key: "welcome_message")
                convo.messages[0] = Message(text: newWelcome, isFromUser: false)
                convo.title = AppStrings.getString(newLang, key: "new_chat")
                repository.addOrUpdateConversation(convo)
                currentConversation = convo
            }
        }
        .task {
            ttsService.setLanguage(langCode: languageCode)
        }
    }
}
