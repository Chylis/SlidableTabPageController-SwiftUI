import SwiftUI
import SlidableTabPageController

public struct SlidableTabViewPage {
    public let indexBarElement: IndexBarElement
    public let view: AnyView
    /// A value uniquely identifying the contents of this page.
    /// Used when SwiftUI re-renders to determine if the SlidableTabPageController's pages should be reloaded or not.
    public let hashValue: Int
    
    public init (indexBarElement: IndexBarElement, hashValue: Int, view: AnyView) {
        self.indexBarElement = indexBarElement
        self.hashValue = hashValue
        self.view = view
    }
}

internal extension SlidableTabPageControllerPage {
    init<ViewType: View>(view: ViewType) {
        //FIXME: No title - attempt to read navigationBarTitle somehow (or allow passing a title)
        self.init(contentViewController: UIHostingController(rootView: view))
    }
    
    init<ViewType: View>(indexBarElement: IndexBarElement, view: ViewType) {
        self.init(indexBarElement: indexBarElement, contentViewController: UIHostingController(rootView: view))
    }
}
