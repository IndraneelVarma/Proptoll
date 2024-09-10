import SwiftUI


//there for experimenting scrolling

struct NoticeListView: View {
    let notices: [Notice]
    
    var body: some View {
        List{
                ForEach(notices) { notice in
                    NoticeBoardcardView(notice: notice)
                }
            }
            .padding()
        
    }
}




