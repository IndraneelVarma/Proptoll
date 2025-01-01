import SwiftUI

// MARK: - Main View
struct NewsView: View {
    // MARK: - Properties
    let notice: Notice?
    @State private var isImagePresented = false
    @State private var isImagePresented2 = false
    @State private var dragOffset: CGFloat = 0
    @State private var isSharePresented = false
    @Binding var showFullNotice: Bool
    @State private var urlMain: URL = URL(string: "https://www.google.com")!
    @State private var selectdTab = 0
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            HStack {
                mainContent
                Spacer()
            }
        }
        .offset(x: dragOffset)
        .gesture(swipeBackGesture)
    }
    
    // MARK: - Subviews
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleSection
                metadataSection
                divider
                imageSection
                contentSection
            }
            .padding()
        }
        .onAppear(perform: handleOnAppear)
        .navigationTitle("Post #\(notice?.postNumber ?? 0)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { shareButton }
        .sheet(isPresented: $isSharePresented) {
            ActivityViewController(activityItems: ["https://consumer.proptoll.com/notice/post/\(notice?.id ?? "")"])
        }
        .fullScreenCover(isPresented: $isImagePresented) {
            NavigationStack {
                if let imageUrl = URL(string: notice?.attachments?.first?.s3ResourceUrl ?? "") {
                    ZoomableImageView(imageURL: imageUrl, isPresented: $isImagePresented, selectedTab: .constant(0))
                }
            }
        }
        .fullScreenCover(isPresented: $isImagePresented2) {
            NavigationStack {
                ZoomableImageView(imageURL: urlMain, isPresented: $isImagePresented2, notice: notice, selectedTab: $selectdTab)
            }
        }
        
    }
    
    // MARK: - Subviews
    private var titleSection: some View {
        VStack(alignment: .leading) {
            Text("\(notice?.title.htmlToString() ?? "")")
                .font(.custom("Montserrat-SemiBold", size: 20))
                .multilineTextAlignment(.leading)
            
            Text(notice?.subTitle.htmlToString() ?? "")
                .font(.custom("Montserrat-Medium", size: 17))
                .multilineTextAlignment(.leading)
                .padding(.top, 5)
        }
    }
    
    private var metadataSection: some View {
        HStack {
            categoryLabel(for: notice?.noticeCategoryId ?? 0)
            Text(getFormattedDateText())
                .font(.custom("Montserrat-Normal", size: 13))
                .foregroundColor(.primary)
        }
    }
    
    private var divider: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
        }
        .frame(maxWidth: .infinity, maxHeight: 2)
    }
    
    private var imageSection: some View {
        Group {
            if notice?.attachments?.count ?? 0 < 2 {
                singleImageView
            } else {
                HStack{
                    Spacer()
                    multipleImagesView
                    Spacer()
                }
            }
        }
    }
    
    private var singleImageView: some View {
        Group {
            if let imageUrl = URL(string: notice?.attachments?.first?.s3ResourceUrl ?? "") {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 300, height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.3)
                            .onTapGesture {
                                isImagePresented = true
                            }
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300, height: 200)
                            .foregroundColor(.gray)
                    @unknown default:
                        ProgressView()
                            .frame(height: 200)
                    }
                }
            }
        }
    }
    
    private var multipleImagesView: some View {
        TabView(selection: $selectdTab) {
            ForEach(notice?.attachments ?? [], id: \.s3ResourceUrl) { attachment in
                if let imageUrlString = attachment.s3ResourceUrl,
                   let index = notice?.attachments?.firstIndex(where: { $0.s3ResourceUrl == attachment.s3ResourceUrl }),
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
                                .onTapGesture {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isImagePresented2 = true
                                    }
                                }
                        case .failure:
                            ProgressView()
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
        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.4)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        
    }
    
    private var contentSection: some View {
        Group {
            if #available(iOS 18, *) {
                Text(classToStyle(notice?.content ?? "").htmlToAttributedString2() ?? "")
                    .lineSpacing(3)
                    .padding()
            } else {
                Text(classToStyle(notice?.content ?? "").htmlToAttributedString() ?? "")
                    .lineSpacing(3)
                    .padding()
            }
        }
    }
    
    private var shareButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                matomoTracker.track(eventWithCategory: "share notice", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                isSharePresented = true
            }) {
                Image(systemName: "square.and.arrow.up")
            }
        }
    }
    
    // MARK: - Gestures
    private var swipeBackGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.width > 0 {
                    dragOffset = value.translation.width
                }
            }
            .onEnded { value in
                if value.translation.width > 50 {
                    showFullNotice = false
                } else {
                    withAnimation {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Helper Methods
    private func handleOnAppear() {
        matomoTracker.track(view: ["Full Notice: \(notice?.postNumber ?? 0)"])
        UserDefaults.standard.set("", forKey: "route")
    }
    
    private func getFormattedDateText() -> String {
        let formattedDate = formatDate(notice?.createdAt ?? "")
        let formattedDate2 = formatDate(notice?.updatedAt ?? "")
        return formattedDate == formattedDate2 ?
            "     Posted on \(formattedDate)" :
            "     Edited on \(formattedDate2)"
    }
    
    private func formatDate(_ dateString: String) -> String {
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
    
    private func categoryLabel(for id: Int) -> some View {
        let (text, color) = categoryInfo(for: id)
        return Text(text)
            .font(.custom("Montserrat-Normal", size: 13))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
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
    
    private func classToStyle(_ input: String) -> String {
        let sizeMap = [
            "ql-size-small": "13",
            "ql-size-normal": "16",
            "ql-size-large": "19",
            "ql-size-huge": "22"
        ]
        
        var output = input
        
        for (className, fontSize) in sizeMap {
            let pattern = "class=\"\(className)\""
            let replacement = "style=\"font-size: \(fontSize)px\""
            output = output.replacingOccurrences(of: pattern, with: replacement)
        }
        
        return output
    }
}

// MARK: - ActivityViewController
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
