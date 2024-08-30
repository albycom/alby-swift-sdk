//
//  AlbyWidget.swift
//  AlbyExampleIos
//
//  Created by Thiago Salvatore on 8/22/24.
//

import Foundation
import SwiftUI
import WebKit
import BottomSheetSwiftUI


private struct AlbyWidgetView<Content: View>: View {
    @State var widgetVisible = false
    @State var bottomSheetPosition: BottomSheetPosition = .absolute(100)
    @State var sheetExpanded = false
    @State var newUserMessage = ""
    @FocusState private var textInputIsFocused: Bool

    let content: Content
    let bottomOffset: CGFloat
    @ObservedObject var viewModel = WebViewModel()


    var body: some View {
        ZStack {
            content
                .padding([.bottom], self.$widgetVisible.wrappedValue && bottomOffset != 0 ? 50 : 0)
            Color.black.opacity(0)
            .bottomSheet(
                bottomSheetPosition: self.$bottomSheetPosition,
                switchablePositions: [.hidden, .relative(0.7), .relativeTop(0.975)]
            ) {
                SwiftWebView(url: URL(string: "https://cdn.alby.com/assets/alby_widget.html")!, viewModel: viewModel)
                    .safeAreaInset(edge: .bottom) {
                        if (sheetExpanded) {
                            HStack {
                                TextField("Ask a question", text: $newUserMessage)
                                    .focused($textInputIsFocused)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.white))
                                    .onSubmit {
                                        handleSendMessage()
                                    }
                                Button {
                                    handleSendMessage()
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                }
                                .disabled($newUserMessage.wrappedValue.isEmpty)
                            }
                            .padding()

                        } else {
                            EmptyView()
                        }
                    }
            }
            .showDragIndicator(true)
            .enableSwipeToDismiss()
            .onDismiss {
                widgetVisible = false;
            }
            .onDragEnded{ value in
                let threshold = -100.0
                if (value.translation.height < threshold && !self.sheetExpanded) {
                    self.sheetExpanded = true;
                    let sendMessage = "sheet-expanded";
                    self.viewModel.callbackValueFromNative.send(sendMessage);
                }
            }
            .onReceive(self.$viewModel.callbackValueJS.wrappedValue, perform: { result in
                switch (result) {
                case "widget-rendered":
                    widgetVisible = true;
                    bottomSheetPosition = .absolute(100)
                    break
                case "preview-button-clicked":
                    self.sheetExpanded = true;
                    bottomSheetPosition = .relativeTop(0.975)
                    break
                default:
                    break
                }
            })
            .offset(y: self.$widgetVisible.wrappedValue ? bottomOffset : -10000)
            .padding([bottomOffset > 0 ? .bottom : .top], self.$widgetVisible.wrappedValue ? abs(bottomOffset) : 0)
        }
    }

    func handleSendMessage() {
        textInputIsFocused = false
        let sendMessage = self.$newUserMessage.wrappedValue;
        newUserMessage = "";
        self.viewModel.callbackValueFromNative.send(sendMessage);
    }


    func handlePreviewButtonClicked() {
        self.bottomSheetPosition = .relative(0.5);
        self.sheetExpanded = true;
    }

}

public extension View {

    /// Adds a BottomSheet to the view.
    ///
    /// - Parameter bottomSheetPosition: A binding that holds the current position/state of the BottomSheet.
    /// For more information about the possible positions see `BottomSheetPosition`.
    /// - Parameter switchablePositions: An array that contains the positions/states of the BottomSheet.
    /// Only the positions/states contained in the array can be switched into
    /// (via tapping the drag indicator or swiping the BottomSheet).
    /// - Parameter headerContent: A view that is used as header content for the BottomSheet.
    /// You can use a String that is displayed as title instead.
    /// - Parameter mainContent: A view that is used as main content for the BottomSheet.

    func addAlbyWidget(
        productId: String, bottomOffset: CGFloat = 0
    ) -> some View {
        AlbyWidgetView(content: self, bottomOffset: bottomOffset)
    }
}
