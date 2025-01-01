import SwiftUI

struct NoticeBoardStep: View {
    @State private var isAnimated = false
    
    let notices = [
        (title: "Important Updates", subtitle: "Stay informed about critical announcements", icon: "bell.fill", color: Color.red.opacity(0.8)),
        (title: "Maintenance Notice", subtitle: "Track scheduled maintenance and repairs", icon: "wrench.fill", color: Color.orange.opacity(0.8)),
        (title: "Community Events", subtitle: "Don't miss upcoming community activities", icon: "calendar", color: Color.green.opacity(0.8))
    ]
    
    var body: some View {
        OnboardingStepView3(
            title: "Notice Board",
            description: "Stay updated with the latest announcements and important information",
            systemImage: "noticeboardOB"
        ) {
            EmptyView()
        }
    }
}
