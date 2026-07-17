import Foundation
import Combine

class WebViewModel: ObservableObject {
    // iOS to Javascript
    var callbackValueFromNative = PassthroughSubject<String, Never>()

    // Javascript to IOS
    var callbackValueJS = PassthroughSubject<String, Never>()

    @Published var contentHeight: CGFloat = 0

    /// When false, contentSize KVO updates are ignored. Used by the inline widget to
    /// skip the large pre-render contentSize spike before `widget-rendered`.
    var tracksContentHeight = false
}
