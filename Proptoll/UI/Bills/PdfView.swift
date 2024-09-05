import SwiftUI
import PDFKit

struct PdfView: View {
    let urlString: String
    @State private var isSharePresented = false
    var body: some View {
        if let url = URL(string: urlString) {
            PDFKitView(url: url)
        } else {
            ProgressView()
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            uiView.document = document
        }
    }
}

#Preview{
    PdfView(urlString: "https://cdn.proptoll.com/0/staging/PDF/BILL/PropToll_bill_00424.pdf?Expires=4879050204&Key-Pair-Id=K1BLARMAA65UQY&Signature=IPz4mURTFhe60uBNbxxn6sZ551S5ITI0l30Q6lHpUGGRqj80sQQvzWiiKaiy9-EIxjt-qr9te1BGZSvyoAxojvp95FO3kC061tO0eU6za3xk4MYohnvGj0WX97v~iqRTunqvMwTlNYk-uLJkf5UZEkqnlKfeUwBX-zCjGwqkISLMpWeeNJ5bVywCwjNhjOCuOqYdnn3ls8n4-F3ultKbS6jNxNkXBlUtYELjzgnaOZRA4zm8PUjX4POkWkKrC-a3gJICIlrO-WBwzbJmcGNMdR4mOpkvSfjTKbr9spcRNi93PyAxTDSshLxPF2smfXwaleE~rLd7oHDyq7PB-ftbHg__")
}
