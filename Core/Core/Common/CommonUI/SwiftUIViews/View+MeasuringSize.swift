//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

private struct MeasuredSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {

    public func measuringSize(_ onMeasure: @escaping (CGSize) -> Void) -> some View {
        background {
            GeometryReader { g in
                Color.clear.preference(key: MeasuredSizeKey.self, value: g.size)
            }
            .onPreferenceChange(MeasuredSizeKey.self, perform: onMeasure)
        }
    }

    public func measuringSize(_ value: Binding<CGSize>) -> some View {
        measuringSize { newSize in
            value.wrappedValue = newSize
        }
    }

    @ViewBuilder
    func measuringSizeOnce(_ value: Binding<CGSize>) -> some View {
        if value.wrappedValue.isZero {
            measuringSize { newSize in
                value.wrappedValue = newSize
            }
        } else {
            self
        }
    }

    public func onSizeChange(_ perform: @escaping (CGSize) -> Void) -> some View {
        myOnGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { size in
            perform(size)
        }
    }

    public func onSizeChange(update binding: Binding<CGSize>) -> some View {
        myOnGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: { size in
            binding.wrappedValue = size
        }
    }
}

// onGeometryChange backport stolen from https://fatbobman.com/en/posts/geometryreader-blessing-or-curse/
extension View {
    @MainActor
    public func myOnGeometryChange<T>(for _: T.Type, of transform: @escaping (GeometryProxy) -> T, action: @escaping (_ oldValue: T, _ newValue: T) -> Void) -> some View where T: Equatable {
        modifier(MyOnGeometryChange(transform: transform, action1: nil, action2: action))
    }

    @MainActor
    public func myOnGeometryChange<T>(for _: T.Type, of transform: @escaping (GeometryProxy) -> T, action: @escaping (_ newValue: T) -> Void) -> some View where T: Equatable {
        modifier(MyOnGeometryChange(transform: transform, action1: action, action2: nil))
    }
}

@MainActor
struct MyOnGeometryChange<T: Equatable>: ViewModifier {
    @State private var storage: ValueStorage

    init(transform: @escaping (GeometryProxy) -> T, action1: ((T) -> Void)?, action2: ((T, T) -> Void)?) {
        storage = ValueStorage(transform: transform, action1: action1, action2: action2)
    }

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .task(
                            id: EquatableProxy(
                                size: proxy.size,
                                safeAreaInsets: proxy.safeAreaInsets,
                                frame: proxy.frame(in: .global)
                            )
                        ) {
                            storage.setValue(proxy: proxy)
                        }
                }
            )
    }

    struct EquatableProxy: Equatable {
        let size: CGSize
        let safeAreaInsets: EdgeInsets
        let frame: CGRect
    }

    private class ValueStorage {
        private var oldValue: T?
        private var newValue: T?
        private let transform: (GeometryProxy) -> T
        private let action1: ((T) -> Void)?
        private let action2: ((T, T) -> Void)?

        init(transform: @escaping (GeometryProxy) -> T, action1: ((T) -> Void)?, action2: ((T, T) -> Void)?) {
            self.transform = transform
            self.action1 = action1
            self.action2 = action2
        }

        func setValue(proxy: GeometryProxy) {
            let value = transform(proxy)
            if oldValue == nil {
                oldValue = value
                newValue = value
            } else {
                oldValue = newValue
                newValue = value
            }
            if let action1, let newValue = newValue {
                action1(newValue)
            }
            if let action2, let oldValue, let newValue {
                action2(oldValue, newValue)
            }
        }
    }
}
