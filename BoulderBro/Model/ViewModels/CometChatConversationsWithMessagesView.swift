import SwiftUI
import CometChatUIKitSwift

struct CometChatConversationsWithMessagesView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Create and return the CometChatConversationsWithMessages view controller
        let cometChatConversationsWithMessages = CometChatConversationsWithMessages()
        return cometChatConversationsWithMessages
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Handle updates to the view controller if needed
    }
}
