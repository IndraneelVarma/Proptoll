import SwiftUI

struct NoticeBoardcardView: View {
    let notice: Notice?
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
                    
                    Text(notice.subTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    var formattedDate: String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        
                        if let date = dateFormatter.date(from: notice.createdAt) {
                            dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
                            dateFormatter.amSymbol = "AM"
                            dateFormatter.pmSymbol = "PM"
                            return dateFormatter.string(from: date)
                        } else {
                            return "Invalid date"
                        }
                    }
                    Text("Posted on \(formattedDate)")
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
                            case .failure:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Text(notice.content.htmlToString())
                        .font(.body)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                    
                    NavigationLink(destination: NewsView(deepLink: "proptollStack://\(notice.postNumber)", title: notice.title, subTitle: notice.subTitle, content: notice.content, image: notice.attachments?.first?.s3ResourceUrl ?? "")){
                        Text("view full")
                            .italic()
                            .font(.system(size: 12.5))
                    }
                    
                        .padding(.top, 5)
                } else {
                    Text("No notice available")
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(12)
            //.shadow(color: Color(UIColor.systemGray4) .opacity(0.4), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.systemGray4) .opacity(0.2), lineWidth: 1)
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
        case 1: return ("General", .blue)
        case 2: return ("Information", .green)
        case 3: return ("Alert", .orange)
        case 4: return ("Emergency", .red)
        case 5: return ("Event", .purple)
        default: return ("Unknown", Color(UIColor.systemGray4) )
        }
    }
}
#Preview {
    NoticeBoardcardView(notice: Notice(title: "Title", id: "", content: "Content", subTitle: "subTitle", noticeCategoryId: 0, createdAt: "Now", postNumber: 0,  attachments: [Attachment(s3ResourceUrl: "https://cdn.proptoll.com/OIP.jpg")]))
}
