import SwiftUI

struct UserGuideView: View {
    let images = ["image1","image2","image3","image4","image5","image6","image7","image8"] // Add your image names here
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 20) {
                ForEach(images, id: \.self) { imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 350,height: 500)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        
    }
}

struct UserGuideView_Previews: PreviewProvider {
    static var previews: some View {
        UserGuideView()
    }
}
