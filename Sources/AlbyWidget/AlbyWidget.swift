//
//  AlbyWidget.swift
//  AlbyExampleIos
//
//  Created by Thiago Salvatore on 8/22/24.
//

import Foundation
import SwiftUI
import WebKit
#if canImport(BottomSheet)
import BottomSheet
#elseif canImport(BottomSheetSwiftUI)
import BottomSheetSwiftUI
#endif

private struct AlbyWidgetView<Content: View>: View {
    @State var widgetVisible = false
    @State var bottomSheetPosition: BottomSheetPosition = .absolute(80)
    @State var isLoading: Bool = false
    @State var isLoadingText: String?
    @State var sheetExpanded = false
    @State var newUserMessage = ""
    @FocusState private var textInputIsFocused: Bool

    let content: Content
    let bottomOffset: CGFloat
    let productId: String
    let widgetId: String?
    let threadId: String?
    let testId: String?
    let testVersion: String?
    let testDescription: String?
    let isInitiallyExpanded: Bool

    let lightGrayColor = Color(red: 209 / 255.0, green: 213 / 255.0, blue: 219 / 255.0, opacity: 1.0)
    let darkColor = Color(red: 17 / 255.0, green: 25 / 255.0, blue: 40 / 255.0, opacity: 1.0)
    let inputBorderColor = Color(red: 107 / 255.0, green: 114 / 255.0, blue: 128 / 255.0, opacity: 1.0);
    let inputLoadingBg = Color(red: 229 / 255.0, green: 231 / 255.0, blue: 235 / 255.0, opacity: 1.0);
    let placeholderColor = Color(.sRGB, red: 96/255, green: 96/255, blue: 96/255, opacity: 0.6);
    let dragIndicatorColor = Color(.sRGB, red: 121/255, green: 116/255, blue: 126/255, opacity: 0.6);

    @StateObject var viewModel = WebViewModel()

    var body: some View {
        ZStack {
            content
                .padding([.bottom], self.$widgetVisible.wrappedValue && bottomOffset != 0 ? 50 : 0)
            Color.black.opacity(0)
                .bottomSheet(
                    bottomSheetPosition: self.$bottomSheetPosition,
                    switchablePositions: [.hidden, .absolute(80), .relative(0.7), .relativeTop(0.975)]
                ) {
                    if (sheetExpanded) {
                        HStack(spacing: 4) {
                            Text("Powered by")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 147 / 255.0, green: 157 / 255.0, blue: 175 / 255.0, opacity: 1.0))
                            if let imageURL = Bundle.module.url(forResource: "alby_logo", withExtension: "png"),
                               let uiImage = UIImage(contentsOfFile: imageURL.path) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 37, height: 11)
                            }
                            Spacer()
                            Button(action: {
                                self.bottomSheetPosition = .hidden
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color.gray)
                                    .padding()
                            })
                        }.padding(.leading)
                        Divider()
                    }
                    SwiftWebView(
                        url: createURL(),
                        isScrollEnabled: self.$sheetExpanded.wrappedValue,
                        viewModel: viewModel
                    ).safeAreaInset(edge: .bottom) {
                            if sheetExpanded {
                                HStack {
                                    TextField(
                                        "", text: $newUserMessage, prompt: Text(($isLoading.wrappedValue ? $isLoadingText.wrappedValue : "Ask any question about this product")!)
                                            .foregroundColor(placeholderColor))
                                        .onAppear(perform: {
                                                UITextField.appearance().clearButtonMode = .whileEditing
                                            })
                                        .padding([.horizontal], 7)
                                        .padding([.vertical], 12)
                                        .padding(.leading, $isLoading.wrappedValue ? 25 : 7)
                                        .font(.system(size: 14))
                                        .focused($textInputIsFocused)
                                        .disabled($isLoading.wrappedValue)
                                        .foregroundColor(darkColor)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill($isLoading.wrappedValue ? inputLoadingBg : Color.clear)
                                        )
                                        .overlay(
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke($isLoading.wrappedValue ? Color.clear : inputBorderColor, lineWidth: 1)

                                                ;
                                                HStack {
                                                    if ($isLoading.wrappedValue) {
                                                        ProgressView()
                                                            .tint(placeholderColor)
                                                            .scaleEffect(0.8)
                                                            .padding(.leading, 10)
                                                        Spacer() // Align to the right
                                                    }
                                                }
                                            }// Add border using overlay

                                        )

                                        .onSubmit {
                                            handleSendMessage()
                                        }
                                    if textInputIsFocused {
                                        Button {
                                            handleSendMessage()
                                        } label: {
                                            Image(systemName: "paperplane.circle.fill")
                                                .resizable()
                                                .frame(width: 36, height: 36)
                                                .foregroundColor($newUserMessage.wrappedValue.isEmpty ? lightGrayColor : darkColor)


                                        }
                                        .disabled($newUserMessage.wrappedValue.isEmpty)
                                    }
                                }
                                .padding([.bottom], 16)
                                .padding([.horizontal], 16)
                            }
                        }
                }
                .showDragIndicator(true)
                .dragIndicatorColor(dragIndicatorColor)
                .enableFlickThrough(false)
                .enableSwipeToDismiss()
                .enableTapToDismiss(false)
                .onDismiss {
                    widgetVisible = false
                }
                .customBackground(
                                Color.white
                                    .cornerRadius(28, corners: [.topLeft, .topRight])
                                    .shadow(color: .black.opacity(0.3), radius: 1.5, x: 0, y: 1)
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
                            )
                .onReceive(self.$viewModel.callbackValueJS.wrappedValue, perform: { result in
                    switch result {
                    case "widget-rendered":
                        widgetVisible = true
                        if !isInitiallyExpanded {
                            bottomSheetPosition = .absolute(80)
                        } else {
                            sheetExpanded = true
                            bottomSheetPosition = .relativeTop(0.975)
                        }
                        NotificationCenter.default.post(name: .albyWidgetRendered, object: nil)
                        break;
                    case "preview-button-clicked":
                        self.sheetExpanded = true
                        bottomSheetPosition = .relativeTop(0.975)
                        break;
                    case _ where result.contains("streaming-message"):
                        self.isLoading = true;
                        let replacedResult = result.replacingOccurrences(of: "streaming-message:", with: "");
                        self.isLoadingText = replacedResult;
                        break;
                    case _ where result.contains("streaming-finished"):
                        self.isLoading = false;
                        self.isLoadingText = "";
                        break;
                    case _ where result.contains("thread-id-changed"):
                        let threadId = result.replacingOccurrences(of: "thread-id-changed:", with: "")
                        NotificationCenter.default.post(
                            name: .albyThreadIdChanged,
                            object: threadId.isEmpty ? nil : threadId
                        )
                        break;
                    default:
                        break
                    }
                })
                .onChange(of: self.bottomSheetPosition) { newValue in
                    switch newValue {
                    case .absolute(80):
                        self.sheetExpanded = false
                        let sendMessage = "sheet-shrink"
                        self.viewModel.callbackValueFromNative.send(sendMessage)
                        break
                    case .relative(0.7),
                         .relativeTop(0.975):
                        self.sheetExpanded = true
                        let sendMessage = "sheet-expanded"
                        self.viewModel.callbackValueFromNative.send(sendMessage)
                        break
                    default:
                        break
                    }
                }
                .opacity(self.$widgetVisible.wrappedValue  ?  1 : 0)
                .padding([bottomOffset > 0 ? .bottom : .top], self.$widgetVisible.wrappedValue ? abs(bottomOffset) : 0)
        }
    }

    func handleSendMessage() {
        textInputIsFocused = false
        let sendMessage = self.$newUserMessage.wrappedValue
        newUserMessage = ""
        self.viewModel.callbackValueFromNative.send(sendMessage)
    }

    func createURL() -> URL {
        let baseURL = "https://cdn.alby.com/assets/alby_widget.html"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "brandId", value: AlbySDK.shared.brandId),
            URLQueryItem(name: "productId", value: productId),
            URLQueryItem(name: "component", value: "alby-mobile-generative-qa")
        ]
        
        if let widgetId = widgetId {
            components.queryItems?.append(URLQueryItem(name: "widgetId", value: widgetId))
        }
        if let threadId = threadId {
            components.queryItems?.append(URLQueryItem(name: "threadId", value: threadId))
        }
        if let testId = testId {
            components.queryItems?.append(URLQueryItem(name: "testId", value: testId))
        }
        if let testVersion = testVersion {
            components.queryItems?.append(URLQueryItem(name: "testVersion", value: testVersion))
        }
        if let testDescription = testDescription {
            components.queryItems?.append(URLQueryItem(name: "testDescription", value: testDescription))
        }
        
        return components.url!
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
        productId: String, widgetId: String? = nil, bottomOffset: CGFloat = 0, testId: String? = nil, testVersion: String? = nil, testDescription: String? = nil, threadId: String? = nil, isExpanded: Bool = false
    ) -> some View {
        AlbyWidgetView(content: self, bottomOffset: bottomOffset, brandId: brandId, productId: productId, widgetId: widgetId, threadId: threadId, testId: testId, testVersion: testVersion, testDescription: testDescription, isInitiallyExpanded: isExpanded).id(productId)
    }

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
            clipShape( RoundedCorner(radius: radius, corners: corners) )
        }
}

struct RoundedCorner: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Notification.Name {
    /// Notification sent when the Alby widget thread ID changes
    public static let albyThreadIdChanged = Notification.Name("albyThreadIdChanged")
    
    /// Notification sent when the Alby widget is rendered
    public static let albyWidgetRendered = Notification.Name("albyWidgetRendered")
}
