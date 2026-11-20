import Combine
import SwiftUI

@MainActor
final class OverlayModel: ObservableObject {
    @Published var item: DisplayItem?
    @Published var faded = false
}
