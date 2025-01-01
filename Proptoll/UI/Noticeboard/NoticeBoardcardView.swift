import SwiftUI

struct NoticeBoardcardView: View {
    // MARK: - Properties
    let notice: Notice?
    @State private var isImagePresented = false
    @State private var isImagePresented2 = false
    @State private var showFullNotice = false
    @State private var showFullNotice2 = false
    @State private var urlMain: URL = URL(string: "https://www.google.com")!
    @State private var selectdTab = 0
    
    
    // MARK: - Main View
    var body: some View {
        NavigationStack {
            mainContent
                .fullScreenCover(isPresented: $isImagePresented2) {
                    NavigationView {
                        ZoomableImageView(imageURL: urlMain, isPresented: $isImagePresented2, notice: notice, selectedTab: $selectdTab)
                    }
                }
                .fullScreenCover(isPresented: $showFullNotice) {
                    NavigationStack {
                        NewsView(notice: notice, showFullNotice: $showFullNotice)
                            .navigationBarItems(leading: Button("Back") {
                                showFullNotice = false
                            })
                    }
                }
                .navigationDestination(isPresented: $showFullNotice2) {
                        NewsView(notice: notice, showFullNotice: $showFullNotice)
                }
                .padding()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
                .background(.cards)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
    
    // MARK: - Content Views
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let notice = notice {
                headerSection(notice)
                titleSection(notice)
                subtitleSection(notice)
                dateSection(notice)
                imageSection(notice)
                contentSection(notice)
            } else {
                Text("No notice available")
            }
        }
    }
    
    private func headerSection(_ notice: Notice) -> some View {
        HStack {
            categoryLabel(for: notice.noticeCategoryId)
            Spacer()
            Text("#\(notice.postNumber)")
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
    
    private func titleSection(_ notice: Notice) -> some View {
        Text(notice.title)
            .font(.custom("Montserrat-Medium", size: 20))
            .lineLimit(2)
            .foregroundColor(.primary)
            .multilineTextAlignment(.leading)
            .onTapGesture {
                handleTapGesture()
            }
    }
    
    private func subtitleSection(_ notice: Notice) -> some View {
        Text(notice.subTitle)
            .font(.custom("Montserrat-Medium", size: 16))
            .foregroundColor(.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .onTapGesture {
                handleTapGesture()
            }
    }
    
    private func dateSection(_ notice: Notice) -> some View {
        Text(formattedDate(notice.createdAt) == formattedDate(notice.updatedAt)
             ? "Posted on \(formattedDate(notice.createdAt))"
             : "Edited on \(formattedDate(notice.updatedAt))")
        .font(.custom("Montserrat-Regular", size: 16))
            .foregroundColor(.primary)
            .onTapGesture {
                handleTapGesture()
            }
    }
    
    // MARK: - Image Handling
    private func imageSection(_ notice: Notice) -> some View {
        Group {
            if notice.attachments?.count ?? 0 < 2 {
                singleImageView(notice)
            } else {
                HStack{ //jugaad centering
                    Spacer()
                    multipleImagesView(notice)
                    Spacer()
                }
            }
        }
    }
    
    private func singleImageView(_ notice: Notice) -> some View {
        Group {
            if let imageUrlString = notice.attachments?.first?.s3ResourceUrl,
               let url = URL(string: imageUrlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.gray)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.3)
                            .clipped()
                            .onTapGesture {
                                isImagePresented = true
                            }
                    case .failure:
                        ProgressView()
                            .tint(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .fullScreenCover(isPresented: $isImagePresented) {
                    NavigationView {
                        ZoomableImageView(imageURL: url, isPresented: $isImagePresented, selectedTab: .constant(0))
                    }
                }
            }
        }
        .padding(.horizontal, -15)
    }
    
    private func multipleImagesView(_ notice: Notice) -> some View {
        TabView(selection: $selectdTab) {
            ForEach(notice.attachments ?? [], id: \.s3ResourceUrl) { attachment in
                if let imageUrlString = attachment.s3ResourceUrl,
                   let url = URL(string: imageUrlString),
                   let index = notice.attachments?.firstIndex(where: { $0.s3ResourceUrl == attachment.s3ResourceUrl })
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.gray)
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.3)
                                .clipped()
                                .onTapGesture {
                                    handleImageTap(url: url, index: index)
                                }
                        case .failure:
                            ProgressView()
                                .frame(maxHeight: 400)
                                .tint(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(index)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, -15)
        .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.4)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
    }
    
    // MARK: - Content Section
    private func contentSection(_ notice: Notice) -> some View {
        let trimmedContent = notice.content.htmlToString().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.joined(separator: " ")
        let displayContent = trimmedContent.count > 75 ? String(trimmedContent.prefix(60)) : trimmedContent
        
        return Group {
            Text(displayContent).foregroundColor(.primary).font(.custom("Montserrat-Regular", size: 16)) +
            Text(displayContent.count == 60 ? " .." : "").foregroundColor(.primary).font(.custom("Montserrat-Regular", size: 16)) +
            Text(displayContent.count == 60 ? "more details" : "").foregroundColor(.blue).font(.custom("Montserrat-Regular", size: 16))
        }
        .padding(.top)
        .font(.custom("Montserrat-Regular", size: 16))
        .multilineTextAlignment(.leading)
        .onTapGesture {
            handleTapGesture()
        }
    }
    
    // MARK: - Helper Functions
    private func categoryLabel(for id: Int) -> some View {
        let (text, color) = categoryInfo(for: id)
        return Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(20)
    }
    
    private func categoryInfo(for id: Int) -> (String, Color) {
        switch id {
        case 1: return ("General", .general)
        case 2: return ("Information", .blue)
        case 3: return ("Alert", .alert)
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
    
    private func handleTapGesture() {
        dismissKeyboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if #available(iOS 17, *){
                showFullNotice = true
            }
            else {
                UserDefaults.standard.set(true, forKey: "fromSettings")
                showFullNotice2 = true
            }
        }
    }
    
    private func handleImageTap(url: URL, index: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isImagePresented2 = true
        }
    }
}

// MARK: - Preview
#Preview {
    NoticeBoardcardView(notice: Notice(
        title: "Sample Title",
        id: "1",
        content: "Sample Content",
        subTitle: "Sample Subtitle",
        noticeCategoryId: 1,
        createdAt: "2024-03-10T12:00:00.000Z",
        updatedAt: "",
        postNumber: 1,
        attachments: [Attachment(s3ResourceUrl: "https://example.com/sample-image.jpg")]
    ))
}
