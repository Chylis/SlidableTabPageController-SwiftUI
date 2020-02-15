import SwiftUI
import SlidableTabPageController

public extension SlidableTabPageControllerPage {
    init<ViewType: View>(view: ViewType) {
        //FIXME: No title - attempt to read navigationBarTitle somehow (or allow passing a title)
        self.init(contentViewController: UIHostingController(rootView: view))
    }
    
    init<ViewType: View>(indexBarElement: IndexBarElement, view: ViewType) {
        self.init(indexBarElement: indexBarElement, contentViewController: UIHostingController(rootView: view))
    }
}
