// FIXME: Uncomment
// import SwiftUI
// import SlidableTabPageController
//public extension SlidableTabView {
//    /// Allow for the following DSL syntax:
//    /// ```
//    /// SlidableTabView(config: config) {
//    ///    NavigationView { Text("Hello") }
//    ///    NavigationView { Text("World") }
//    /// }
//    /// ```
//    @inlinable init(config: Config, @SlidableTabPageBuilder _ pageBuilder: () -> [SlidableTabPageControllerPage]) {
//        self.init(config: config, pages: pageBuilder())
//    }
//}
//
//
//@_functionBuilder
//public struct SlidableTabPageBuilder {
//    // Note: Currently doesn't work with single elements due to a bug in the current implementation (15/2/2020):
//    // If you have zero or one elements in the function builder body, the type checker gets confused by the single-expression closure type inference that would normally be in effect and doesn't know which overload to choose, e.g the below currently doesn't work:
//    // ```
//    // SlidableTabView(config: config) {
//    //   Text("Single element")
//    // }
//    // ```
//    public static func buildBlock(_ content: Any...) -> [SlidableTabPageControllerPage] {
//        content.compactMap { v in AnyView(_fromValue: { v }()) }.map { SlidableTabPageControllerPage(view: $0) }
//    }
//}
