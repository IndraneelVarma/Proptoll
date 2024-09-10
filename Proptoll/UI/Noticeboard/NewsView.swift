import SwiftUI

struct NewsView: View {
    var deepLink: String
    var title: String
    var subTitle: String
    var content: String
    var image: String?
    let notice: Notice?
    @State private var isSharePresented = false
    
    var body: some View {
        HStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 20) {
                    Text("#\(notice?.postNumber ?? 0): \(title.htmlToString())")
                        .font(.title)
                        .multilineTextAlignment(.leading)
                    
                    Text(subTitle.htmlToString())
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                    
                    HStack{
                        categoryLabel(for: notice?.noticeCategoryId ?? 0)
                        var formattedDate: String {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            
                            if let date = dateFormatter.date(from: notice?.createdAt ?? "") {
                                dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
                                dateFormatter.amSymbol = "AM"
                                dateFormatter.pmSymbol = "PM"
                                return dateFormatter.string(from: date)
                            } else {
                                return "Invalid date"
                            }
                        }
                        Text("     Posted on \(formattedDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 2)
                    
                    if let imageUrl = URL(string: image ?? "https://picsum.photos/200") {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 300, height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    } else {
                        //fallback if no image
                    }
                    Text(classToStyle(content).htmlToAttributedString() ?? "")
                        .padding()
                }
                .padding()
            }
            .onAppear(){
                matomoTracker.track(view: ["Full Notice: \(notice?.postNumber ?? 0)"])
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        matomoTracker.track(eventWithCategory: "share notice", action: "tapped", url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                        isSharePresented = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $isSharePresented) {
                ActivityViewController(activityItems: [deepLink])
            }
        Spacer()}
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
        default: return ("Unknown", Color(UIColor.systemGray4) )
        }
    }
    func classToStyle(_ input: String) -> String {
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

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

#Preview {
    NavigationView {
        NewsView(deepLink: "https://example.com", title: "Test", subTitle: "subtitle ajdlajdafh", content: "akdhakfhkahfkjahfkjahfa akhfkjahfkahfkahfahf alfhlkahflkahflahfla ajkfgjyafhagfkag  jagfjhagfjagfh ajhgfhjafgkjagf ajfgjahfgjhagfjh", image: nil,notice: nil)
    }
}
