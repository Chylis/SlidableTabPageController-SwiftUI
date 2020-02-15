import SwiftUI
import SlidableTabPageController


public final class SlidableTabViewCoordinator: SlidableTabPageControllerDelegate {
    public var currentPageNumber: Binding<Int>?
    
    init(currentPageNumber: Binding<Int>?) {
        self.currentPageNumber = currentPageNumber
    }
    
    public func slidableTabPageController(_ slidableTabPageController: SlidableTabPageController,
                                          didNavigateFrom oldPage: Int, to newPage: Int) {
        currentPageNumber?.wrappedValue = newPage
    }
}


public struct SlidableTabView: UIViewControllerRepresentable {
    public struct Config {
        public var indexBarPosition: SlidableTabPageController.IndexBarPosition
        public var indexBarElementColor: UIColor
        public var indexBarElementHighlightedColor: UIColor
        public var maxNumberOfIndexBarElementsPerScreen: Double
        
        public init(indexBarPosition: SlidableTabPageController.IndexBarPosition = .top,
                    maxNumberOfIndexBarElementsPerScreen: Double = 3.5,
                    indexBarElementColor: UIColor = .black,
                    indexBarElementHighlightedColor: UIColor = .red) {
            self.indexBarPosition = indexBarPosition
            self.maxNumberOfIndexBarElementsPerScreen = maxNumberOfIndexBarElementsPerScreen
            self.indexBarElementColor = indexBarElementColor
            self.indexBarElementHighlightedColor = indexBarElementHighlightedColor
        }
        
        func apply(_ vc: SlidableTabPageController) {
            vc.indexBarElementColor = indexBarElementColor
            vc.indexBarElementHighlightedColor = indexBarElementHighlightedColor
            if vc.maxNumberOfIndexBarElementsPerScreen != maxNumberOfIndexBarElementsPerScreen {
                vc.maxNumberOfIndexBarElementsPerScreen = maxNumberOfIndexBarElementsPerScreen
            }
            if vc.indexBarPosition != indexBarPosition {
                vc.indexBarPosition = indexBarPosition
            }
        }
    }
    
    public let config: Config
    public let pages: [SlidableTabPageControllerPage]
    public var currentPageNumber: Binding<Int>?
    
    public init(config: Config, pages: [SlidableTabPageControllerPage], currentPageNumber: Binding<Int>? = nil) {
        self.config = config
        self.pages = pages
        self.currentPageNumber = currentPageNumber
    }
    
    // SwiftUI creates and retains our coordinator object and stores it in the context that
    // is passed down to the two UIViewControllerRepresentable protocol methods.
    public func makeCoordinator() -> SlidableTabViewCoordinator {
        SlidableTabViewCoordinator(currentPageNumber: currentPageNumber)
    }
    
    // The vc we create here is also retained by SwiftUI
    public func makeUIViewController(context: UIViewControllerRepresentableContext<SlidableTabView>) ->  SlidableTabPageController {
        let vc = SlidableTabPageControllerFactory.make(pages: pages)
        // Use the context.coordinator to store stuff we wish to retain...
        context.coordinator.currentPageNumber = currentPageNumber
        vc.delegate = context.coordinator
        
        config.apply(vc)
        return vc
    }
    
    public func updateUIViewController(_ vc: SlidableTabPageController,
                                       context: UIViewControllerRepresentableContext<SlidableTabView>) {
        
        config.apply(vc)
        context.coordinator.currentPageNumber = currentPageNumber
        
        var hasModifiedPages = false
        if pages.count != vc.pages.count {
            hasModifiedPages = true
        } else {
            // We are unable to check if the contents of a page has been changed, since:
            // 1) the content view controller will be a new UIHostingViewController instance every re-render, thus always being marked as dirty
            // 2) the content view is is a struct, thus having no identity of its own...
            // Therefore we check if the index bar element of each page has been changed, and if so we update the vc accordingly...
            for (index, oldPage) in vc.pages.enumerated() {
                let newPage = pages[index]
                switch (oldPage.indexBarElement, newPage.indexBarElement) {
                case let (.title(old), .title(new)) where old == new: ()
                case let (.image(old1, old2), .image(new1, new2)) where old1 == new1 && old2 == new2: ()
                case (_, _): hasModifiedPages = true
                }
                if hasModifiedPages {
                    break
                }
            }
        }
        
        if hasModifiedPages {
            vc.pages = pages
        }
    }
}


//MARK: - Preview Provider

#if DEBUG
struct TestView: View {
    let config = SlidableTabView.Config()
    @State var currentPageNumber: Int = 0
    
    let pages: [SlidableTabPageControllerPage] = [
        SlidableTabPageControllerPage(indexBarElement: .title("First"), view: Text("test1")),
        SlidableTabPageControllerPage(indexBarElement: .title("Second"), view: Text("test2")),
        SlidableTabPageControllerPage(indexBarElement: .image(UIImage(named: "icon-a")!, UIImage(named: "icon-m")!),
                                      view: Text("test3")),
        SlidableTabPageControllerPage(indexBarElement: .title("Fourth"), view: Text("test4"))
    ]
    
    var body: some View {
        VStack {
            SlidableTabView(config: config,
                            pages: pages,
                            currentPageNumber: $currentPageNumber)
            Text("Current page: \(currentPageNumber)")
        }
    }
}

struct SlidableTabView_Previews : PreviewProvider {
    
    static var previews: some View {
        TestView()
    }
}

#endif
