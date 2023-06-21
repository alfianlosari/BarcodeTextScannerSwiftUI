//
//  DataScannerView.swift
//  BarcodeTextScanner
//
//  Created by Alfian Losari on 6/25/22.
//

import Foundation
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: false
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizedItems: [RecognizedItem]
        // Dictionary to store our custom highlights keyed by their associated item ID.
        var itemHighlightViews: [RecognizedItem.ID: HighlightView] = [:]

        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func computeBounds(topLeft: CGPoint, bottomLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint) -> (CGFloat, CGFloat, CGFloat, CGFloat){
            let margin: CGFloat = 5.0
            var left: CGFloat
            var right: CGFloat
            var top: CGFloat
            var bottom: CGFloat
            if topLeft.x < bottomLeft.x {
                left = topLeft.x
            } else {
                left = bottomLeft.x
            }
            if topLeft.y < topRight.y {
                top = topLeft.y
            } else {
                top = topRight.y
            }
            if topRight.x > bottomRight.x {
                right = topRight.x
            } else {
                right = bottomRight.x
            }
            if bottomLeft.y > bottomRight.y {
                bottom = bottomLeft.y
            } else {
                bottom = bottomRight.y
            }

            return (left-margin, right+margin, top-margin, bottom+margin)
        }

        // For each new item, create a new highlight view and add it to the view hierarchy.
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addItems {
                let (left, right, top, bottom) = computeBounds(topLeft: item.bounds.topLeft, bottomLeft: item.bounds.bottomLeft,
                                                               topRight: item.bounds.topRight, bottomRight: item.bounds.bottomRight)
                let newView = HighlightView(frame: CGRect(x: left, y: top, width: right-left, height: bottom-top))
                itemHighlightViews[item.id] = newView
                dataScanner.overlayContainerView.addSubview(newView)
            }
        }


        // Animate highlight views to their new bounds
        func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in updatedItems {
                if itemHighlightViews[item.id] != nil {
                    itemHighlightViews[item.id]?.removeFromSuperview()
                    let (left, right, top, bottom) = computeBounds(topLeft: item.bounds.topLeft, bottomLeft: item.bounds.bottomLeft,
                                                                   topRight: item.bounds.topRight, bottomRight: item.bounds.bottomRight)
                    let newView = HighlightView(frame: CGRect(x: left, y: top, width: right-left, height: bottom-top))
                    itemHighlightViews[item.id] = newView
                    dataScanner.overlayContainerView.addSubview(newView)
                }
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: {$0.id == item.id })
            }
            for item in removedItems {
                 itemHighlightViews[item.id]?.removeFromSuperview()
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
        
    }
    
}
