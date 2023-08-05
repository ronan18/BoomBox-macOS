//
//  Wraping Stack.swift
//  BoomBoxUI
//
//  Created by Ronan Furuta on 8/4/23.
//

import Foundation
import SwiftUI

/// An HStack that grows vertically when single line overflows
@available(iOS 14, macOS 11, *)
public struct WrappingHStack<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    
    public let data: Data
    public var content: (Data.Element) -> Content
    public var id: KeyPath<Data.Element, ID>
    public var alignment: Alignment
    public var horizontalSpacing: CGFloat
    public var verticalSpacing: CGFloat
    
    @State private var sizes: [ID: CGSize] = [:]
    @State private var calculatesSizesKeys: Set<ID> = []
    
    private let idsForCalculatingSizes: Set<ID>
    private var dataForCalculatingSizes: [Data.Element] {
        var result: [Data.Element] = []
        var idsToProcess: Set<ID> = idsForCalculatingSizes
        idsToProcess.subtract(calculatesSizesKeys)
        
        data.forEach { item in
            let itemId = item[keyPath: id]
            if idsToProcess.contains(itemId) {
                idsToProcess.remove(itemId)
                result.append(item)
            }
        }
        return result
    }
    
    /// Creates a new WrappingHStack
    ///
    /// - Parameters:
    ///   - id: a keypath of element identifier
    ///   - alignment: horizontal and vertical alignment. Vertical alignment is applied to every row
    ///   - horizontalSpacing: horizontal spacing between elements
    ///   - verticalSpacing: vertical spacing between the lines
    ///   - create: a method that creates an array of elements
    public init(
        id: KeyPath<Data.Element, ID>,
        alignment: Alignment = .center,
        horizontalSpacing: CGFloat = 0,
        verticalSpacing: CGFloat = 0,
        @ViewBuilder content create: () -> ForEach<Data, ID, Content>
    ) {
        let forEach = create()
        data = forEach.data
        content = forEach.content
        idsForCalculatingSizes = Set(data.map { $0[keyPath: id] })
        self.id = id
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }
    
    private func splitIntoLines(maxWidth: CGFloat) -> [Range<Data.Index>] {
        let lines = Lines(elements: data, spacing: horizontalSpacing) { element in
            sizes[element[keyPath: id]]?.width ?? 0
        }
        return lines.split(lengthLimit: maxWidth)
    }
    
    public var body: some View {
        if calculatesSizesKeys.isSuperset(of: idsForCalculatingSizes) {
            // All sizes are calculated, displaying the view
            laidOutContent
        } else {
            // Calculating sizes
            sizeCalculatorView
        }
    }
    
    private var laidOutContent: some View {
        TightHeightGeometryReader(alignment: alignment) { geometry in
            let splited = splitIntoLines(maxWidth: geometry.size.width)
            
            // All sizes are known
            VStack(alignment: alignment.horizontal, spacing: verticalSpacing) {
                ForEach(Array(splited.enumerated()), id: \.offset) { list in
                    HStack(alignment: alignment.vertical, spacing: horizontalSpacing) {
                        ForEach(data[list.element], id: id) {
                            content($0)
                        }
                    }
                }
            }
        }
    }
    
    private var sizeCalculatorView: some View {
        VStack {
            ForEach(dataForCalculatingSizes, id: id) { d in
                content(d)
                    .onSizeChange { size in
                        let key = d[keyPath: id]
                        sizes[key] = size
                        calculatesSizesKeys.insert(key)
                    }
            }
        }
    }
}

@available(iOS 14, macOS 11, *)
extension WrappingHStack where ID == Data.Element.ID, Data.Element: Identifiable {
    /// Creates a new WrappingHStack
    ///
    /// - Parameters:
    ///   - alignment: horizontal and vertical alignment. Vertical alignment is applied to every row
    ///   - horizontalSpacing: horizontal spacing between elements
    ///   - verticalSpacing: vertical spacing between the lines
    ///   - create: a method that creates an array of elements
    public init(
        alignment: Alignment = .center,
        horizontalSpacing: CGFloat = 0,
        verticalSpacing: CGFloat = 0,
        @ViewBuilder content create: () -> ForEach<Data, ID, Content>
    ) {
        self.init(id: \.id,
                  alignment: alignment,
                  horizontalSpacing: horizontalSpacing,
                  verticalSpacing: verticalSpacing,
                  content: create)
    }
}

struct Lines<S: RandomAccessCollection, Weight: AdditiveArithmetic & Comparable> {
    typealias Element = S.Element
    typealias Index = S.Index
    
    var elements: S
    var spacing: Weight
    var length: (Element) -> Weight
    
    func split(lengthLimit: Weight) -> [Range<Index>] {
        var currentLength: Weight = .zero
        var numberOfElementsInCurrentLine = 0
        var result: [Range<Index>] = []
        var lineStart = elements.startIndex
        
        for element in elements {
            let elementLength = length(element)
            let newLength = currentLength + elementLength
            
            // element could safely be added to the line
            // or line is empty
            if newLength <= lengthLimit || numberOfElementsInCurrentLine == 0 {
                currentLength = newLength + spacing
                numberOfElementsInCurrentLine += 1
            } else {                                    // moving element to the next line
                currentLength = elementLength + spacing
                let lineEnd = elements.index(lineStart, offsetBy: numberOfElementsInCurrentLine)
                result.append(lineStart ..< lineEnd)
                numberOfElementsInCurrentLine = 1
                lineStart = lineEnd
            }
        }
        
        if lineStart != elements.endIndex {
            result.append(lineStart ..< elements.endIndex)
        }
        return result
    }
}

extension View {
    func onSizeChange(perform action: @escaping (CGSize) -> ()) -> some View {
        modifier(SizeReader(onChange: action))
    }
}

@available(iOS 14, macOS 11, *)
private struct SizeReader: ViewModifier {
    var onChange: (CGSize) -> ()
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometry.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

@available(iOS 14, macOS 11, *)
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

struct TightHeightGeometryReader<Content: View>: View {
    var alignment: Alignment
    @State private var height: CGFloat = 0

    var content: (GeometryProxy) -> Content
    
    init(
        alignment: Alignment = .topLeading,
        @ViewBuilder content: @escaping (GeometryProxy) -> Content
    ) {
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            content(geometry)
                .onSizeChange { size in
                    if self.height != size.height {
                        self.height = size.height
                    }
                }
                .frame(maxWidth: .infinity, alignment: alignment)
        }
        .frame(height: height)
    }
}
