import SwiftUI
import SlidableTabPageController

public final class SlidableTabViewCoordinator: SlidableTabPageControllerDelegate {
    public var currentPageNumber: Binding<Int>?
    public var pageHashes: [Int]
    
    init(currentPageNumber: Binding<Int>?, pageHashes: [Int]) {
        self.currentPageNumber = currentPageNumber
        self.pageHashes = pageHashes
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
    public let pages: [SlidableTabViewPage]
    public var currentPageNumber: Binding<Int>?
    
    public init(config: Config, pages: [SlidableTabViewPage], currentPageNumber: Binding<Int>? = nil) {
        self.config = config
        self.pages = pages
        self.currentPageNumber = currentPageNumber
    }
    
    // SwiftUI calls the makeCoordinator() method before makeUIViewController(context:),
    // so that you have access to the coordinator object when configuring your view controller.
    // The coordinator is retained and stored it in the context that is passed down to the two UIViewControllerRepresentable protocol methods.
    // You can use this coordinator to implement common Cocoa patterns, such as delegates, data sources, and responding to user events via target-action.
    public func makeCoordinator() -> SlidableTabViewCoordinator {
        return SlidableTabViewCoordinator(currentPageNumber: currentPageNumber, pageHashes: pages.map { $0.hashValue })
    }
    
    // SwiftUI calls this method a single time when it’s ready to display the view,
    // and then manages the view controller’s life cycle.
    // The vc we create here is retained by SwiftUI.
    public func makeUIViewController(context: UIViewControllerRepresentableContext<SlidableTabView>) ->  SlidableTabPageController {
        let vc = SlidableTabPageControllerFactory.make(pages: pages.map { page in
            SlidableTabPageControllerPage(indexBarElement: page.indexBarElement, view: page.view)
        })
        // Use the context.coordinator to store stuff we wish to retain...
        context.coordinator.currentPageNumber = currentPageNumber
        vc.delegate = context.coordinator
        
        config.apply(vc)
        return vc
    }
    
    // SwiftUI calls this method on re-renders. Here you should update your view controller, if required...
    public func updateUIViewController(_ vc: SlidableTabPageController,
                                       context: UIViewControllerRepresentableContext<SlidableTabView>) {
        let currentHashes = pages.map { $0.hashValue }
        let oldHashes = context.coordinator.pageHashes
        var hasModifiedPages = false
        
        if currentHashes.count != oldHashes.count {
            hasModifiedPages = true
        } else {
            for (index, pageHash) in currentHashes.enumerated() {
                if pageHash != oldHashes[index] {
                    hasModifiedPages = true
                    break
                }
            }
        }
        
        config.apply(vc)
        context.coordinator.pageHashes = currentHashes
        context.coordinator.currentPageNumber = currentPageNumber

        // On a SwiftUI re-render, we don't want to re-populate the SlidableTabPageController's 'pages' property if no changes have occurred, since it results in a force-removal and re-population of the entire UI.
        // However, we are unable to check if the contents of a page has been changed, since:
        // 1) the content view controller will be a new UIHostingViewController instance (with a new memory location) every re-render (thus always being marked as dirty)
        // 2) the content view is is a struct, thus having no identity of its own...
        // Therefore we have added a 'hashValue' to each page, delegating the responsibility of marking a page as "dirty" to the the implementing application.
        if hasModifiedPages {
            vc.pages = pages.map { SlidableTabPageControllerPage(indexBarElement: $0.indexBarElement, view: $0.view) }
        }
    }
}


//MARK: - Preview Provider

#if DEBUG
struct TestView: View {
    let config = SlidableTabView.Config()
    @State var currentPageNumber: Int = 0

    let pages: [SlidableTabViewPage] = [
        SlidableTabViewPage(indexBarElement: .title("First"), hashValue: 1, view: AnyView(Text("test1"))),
        SlidableTabViewPage(indexBarElement: .title("Second"), hashValue: 1, view: AnyView(Text("test2"))),
        SlidableTabViewPage(indexBarElement: .image(UIImage(named: "icon-a")!, UIImage(named: "icon-m")!),
                            hashValue: 1,
                            view: AnyView(Text("test3"))),
        SlidableTabViewPage(indexBarElement: .title("Fourth"),
                            hashValue: 1,
                            view: AnyView(Text("test4")))
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
