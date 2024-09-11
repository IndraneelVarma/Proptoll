import SwiftUI

struct NoticeBoardcardView: View {
    let notice: Notice?
    @State private var isImagePresented = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                if let notice = notice {
                    HStack {
                        categoryLabel(for: notice.noticeCategoryId)
                        Spacer()
                        Text("#\(notice.postNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(notice.title)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    Text(notice.subTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text("Posted on \(formattedDate(notice.createdAt))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let imageUrlString = notice.attachments?.first?.s3ResourceUrl,
                       let url = URL(string: imageUrlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: .infinity)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .onTapGesture {
                                        isImagePresented = true
                                    }
                            case .failure:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .fullScreenCover(isPresented: $isImagePresented) {
                            NavigationView {
                                ZoomableImageView(imageURL: url, isPresented: $isImagePresented)
                            }
                        }
                    }
                    
                    Text(notice.content.htmlToString())
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination: NewsView(deepLink: "https://consumer.proptoll.com/notice/post/\(notice.id)", title: notice.title, subTitle: notice.subTitle, content: notice.content, image: notice.attachments?.first?.s3ResourceUrl ?? "", notice: notice)) {
                        Text("view full")
                            .italic()
                            .font(.system(size: 12.5))
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        matomoTracker.track(eventWithCategory: "view full", action: "tapped", name: "on notice number \(notice.postNumber)", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                    })
                    .padding(.top, 5)
                        
                } else {
                    Text("No notice available")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.systemGray4).opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func categoryLabel(for id: Int) -> some View {
        let (text, color) = categoryInfo(for: id)
        return Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private func categoryInfo(for id: Int) -> (String, Color) {
        switch id {
        case 1: return ("General", .cyan)
        case 2: return ("Information", .blue)
        case 3: return ("Alert", .orange)
        case 4: return ("Emergency", .red)
        case 5: return ("Event", .green)
        default: return ("Unknown", Color(UIColor.systemGray4))
        }
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            return dateFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }
}

#Preview {
    NoticeBoardcardView(notice: Notice(title: "Sample Title", id: "1", content: "Sample Content", subTitle: "Sample Subtitle", noticeCategoryId: 1, createdAt: "2024-03-10T12:00:00.000Z", postNumber: 1, attachments: [Attachment(s3ResourceUrl: "https://example.com/sample-image.jpg")]))
}
