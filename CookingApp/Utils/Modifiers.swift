//
//  Modifiers.swift
//  LiftLogs
//
//  Created by Matt Linder on 5/3/24.
//

import Foundation
import SwiftUI

extension Text {
  func selectable(_ active: Bool, _ thickBackground: Bool = false) -> some View {
    self
      .padding(.horizontal)
      .padding(.vertical, 6)
      .foregroundStyle(active ? .background : .primary)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(active ? Color.accentColor : thickBackground ? Color.background.opacity(0.6) : Color.clear)
      )
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(.ultraThickMaterial)
      )
  }
  
  var asButton: some View {
    self
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity)
      .font(.subheadline)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(.thickMaterial)
      )
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat) -> some View {
    self
      .clipShape(
        RoundedRectangle(cornerRadius: radius)
      )
  }
  
  func asStretchyHeader(startingHeight: CGFloat) -> some View {
    modifier(StretchyHeaderModifier(startingHeight: startingHeight))
  }
  
  func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
    background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
  }
}

struct FrameReader : View {
  let coordinateSpace: CoordinateSpace
  let onChange: (_ frame: CGRect) -> ()
  
  public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
    self.coordinateSpace = coordinateSpace
    self.onChange = onChange
  }
  
  public var body: some View {
    GeometryReader{ geo in
      Text("")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
          onChange(geo.frame(in: coordinateSpace))
        }
        .onChange(of: geo.frame(in: coordinateSpace), perform: onChange)
    }
  }
}

struct StretchyHeaderModifier : ViewModifier {
  var startingHeight: CGFloat = 300
  var coordinateSpace: CoordinateSpace = .global
  
  func body(content: Content) -> some View {
    GeometryReader(content: { geometry in
        content
        .frame(width: geometry.size.width, height: stretchedHeight(geometry))
        .clipped()
        .offset(y: stretchedOffset(geometry))
    })
    .frame(height: startingHeight)
  }
  
  private func yOffset(_ geo: GeometryProxy) -> CGFloat {
    return geo.frame(in: coordinateSpace).minY
  }
  
  private func stretchedHeight(_ geo: GeometryProxy) -> CGFloat {
    let offset = yOffset(geo)
    return offset > 0 ? (startingHeight + offset) : startingHeight
  }
  
  private func stretchedOffset(_ geo: GeometryProxy) -> CGFloat {
    let offset = yOffset(geo)
    return offset > 0 ? -offset : 0
  }
}
