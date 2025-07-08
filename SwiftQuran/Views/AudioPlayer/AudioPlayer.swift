import SwiftUI

struct AudioPlayer: View {
    @Environment(\.tabViewBottomAccessoryPlacement) var placement
    
    var body: some View {
        if placement == .inline {
            InlineAudioPlayer()
        } else {
            ExpandedAudioPlayer()
        }
    }
}
