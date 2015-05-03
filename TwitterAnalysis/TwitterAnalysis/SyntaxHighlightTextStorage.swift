//
//  SyntaxHighlightTextStorage.swift
//  SwiftTextKitNotepad
//
//  Created by Gabriel Hauber on 18/07/2014.
//  Copyright (c) 2014 Gabriel Hauber. All rights reserved.
//

import UIKit

class SyntaxHighlightTextStorage: NSTextStorage {
  let backingStore = NSMutableAttributedString()
  var replacements: [String : [NSObject : AnyObject]]!

  override init() {
    super.init()
    createHighlightPatterns()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override var string: String {
    return backingStore.string
  }

  override func attributesAtIndex(index: Int, effectiveRange range: NSRangePointer) -> [NSObject : AnyObject] {
    return backingStore.attributesAtIndex(index, effectiveRange: range)
  }

  override func replaceCharactersInRange(range: NSRange, withString str: String) {
    beginEditing()
    backingStore.replaceCharactersInRange(range, withString:str)
    edited(.EditedCharacters | .EditedAttributes, range: range, changeInLength: (str as NSString).length - range.length)
    endEditing()
  }

  override func setAttributes(attrs: [NSObject : AnyObject]!, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(.EditedAttributes, range: range, changeInLength: 0)
    endEditing()
  }

  func applyStylesToRange(searchRange: NSRange) {
    let normalAttrs = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]

    // iterate over each replacement
    for (pattern, attributes) in replacements {
      let regex = NSRegularExpression(pattern: pattern, options: nil, error: nil)!
      regex.enumerateMatchesInString(backingStore.string, options: nil, range: searchRange) {
        match, flags, stop in
        // apply the style
        let matchRange = match.rangeAtIndex(1)
        self.addAttributes(attributes, range: matchRange)

        // reset the style to the original
        let maxRange = matchRange.location + matchRange.length
        if maxRange + 1 < self.length {
          self.addAttributes(normalAttrs, range: NSMakeRange(maxRange, 1))
        }
      }
    }
  }

  func performReplacementsForRange(changedRange: NSRange) {
    var extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(changedRange.location, 0)))
    extendedRange = NSUnionRange(changedRange, NSString(string: backingStore.string).lineRangeForRange(NSMakeRange(NSMaxRange(changedRange), 0)))
    applyStylesToRange(extendedRange)
  }

  override func processEditing() {
    performReplacementsForRange(self.editedRange)
    super.processEditing()
  }

  func createAttributesForFontStyle(style: String, withTrait trait: UIFontDescriptorSymbolicTraits) -> [NSObject : AnyObject] {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
    let descriptorWithTrait = fontDescriptor.fontDescriptorWithSymbolicTraits(trait)
    let font = UIFont(descriptor: descriptorWithTrait!, size: 0)
    return [NSFontAttributeName : font]
  }

  func createHighlightPatterns() {
    let scriptFontDescriptor = UIFontDescriptor(fontAttributes: [UIFontDescriptorFamilyAttribute : "Zapfino"])

    // 1. base our script font on the preferred body font size
    let bodyFontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
    let bodyFontSize = bodyFontDescriptor.fontAttributes()[UIFontDescriptorSizeAttribute] as! NSNumber
    let scriptFont = UIFont(descriptor: scriptFontDescriptor, size: CGFloat(bodyFontSize.floatValue))

    // 2. create the attributes
    let boldAttributes = createAttributesForFontStyle(UIFontTextStyleBody, withTrait:.TraitBold)
    let italicAttributes = createAttributesForFontStyle(UIFontTextStyleBody, withTrait:.TraitItalic)
    let strikeThroughAttributes = [NSStrikethroughStyleAttributeName : 1]
    let scriptAttributes = [NSFontAttributeName : scriptFont]
    let redTextAttributes = [NSForegroundColorAttributeName : UIColor.redColor()]

    // construct a dictionary of replacements based on regexes
    replacements = [
      "(\\*\\w+(\\s\\w+)*\\*)" : boldAttributes,
      "(_\\w+(\\s\\w+)*_)" : italicAttributes,
      "([0-9]+\\.)\\s" : boldAttributes,
      "(-\\w+(\\s\\w+)*-)" : strikeThroughAttributes,
      "(~\\w+(\\s\\w+)*~)" : scriptAttributes,
      "\\s([A-Z]{2,})\\s" : redTextAttributes
    ]
  }

  func update() {
    // update the highlight patterns
    createHighlightPatterns()

    // change the 'global' font
    let bodyFont = [NSFontAttributeName : UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
    addAttributes(bodyFont, range: NSMakeRange(0, length))

    // re-apply the regex matches
    applyStylesToRange(NSMakeRange(0, length))
  }

}
