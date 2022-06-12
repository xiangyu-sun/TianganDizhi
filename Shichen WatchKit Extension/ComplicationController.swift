//
//  ComplicationController.swift
//  Shichen WatchKit Extension
//
//  Created by 孙翔宇 on 10/16/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import ClockKit
import ChineseAstrologyCalendar

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "current_shichen_complication",
                                      displayName: "當前時辰",
                                      supportedFamilies: CLKComplicationFamily.allCases)
            // Multiple complication support can be added here with more descriptors
        ]
        
        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(Date().addingTimeInterval(24.0 * 60.0 * 60.0))
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        handler(createTimelineEntry(forComplication: complication, date: Date()))
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let fiveMinutes = 5.0 * 60.0
        let twentyFourHours = 24.0 * 60.0 * 60.0
        
        // Create an array to hold the timeline entries.
        var entries = [CLKComplicationTimelineEntry]()
        
        // Calculate the start and end dates.
        var current = date.addingTimeInterval(fiveMinutes)
        let endDate = date.addingTimeInterval(twentyFourHours)
        
        // Create a timeline entry for every five minutes from the starting time.
        // Stop once you reach the limit or the end date.
        while (current.compare(endDate) == .orderedAscending) && (entries.count < limit) {
            entries.append(createTimelineEntry(forComplication: complication, date: current))
            current = current.addingTimeInterval(fiveMinutes)
        }
        
        handler(entries)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // Calculate the date 25 hours from now.
        // Since it's more than 24 hours in the future,
        // Our template will always show zero cups and zero mg caffeine.
        let future = Date().addingTimeInterval(25.0 * 60.0 * 60.0)
        let template = createTemplate(forComplication: complication, date: future)
        handler(template)
    }
    
    func getAlwaysOnTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // Calculate the date 25 hours from now.
        // Since it's more than 24 hours in the future,
        // Our template will always show zero cups and zero mg caffeine.
        let future = Date().addingTimeInterval(25.0 * 60.0 * 60.0)
        let template = createTemplate(forComplication: complication, date: future)
        handler(template)
    }
    
    // MARK: - Private Methods
    
    // Return a timeline entry for the specified complication and date.
    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
        
        // Get the correct template based on the complication.
        let template = createTemplate(forComplication: complication, date: date)
        
        // Use the template and date to create a timeline entry.
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }

    // Select the correct template based on the complication's family.
    private func createTemplate(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTemplate {
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate(forDate: date)
        case .modularLarge:
            return createModularLargeTemplate(forDate: date)
        case .utilitarianSmall, .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(forDate: date)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(forDate: date)
        case .circularSmall:
            return createCircularSmallTemplate(forDate: date)
        case .extraLarge:
            return createExtraLargeTemplate(forDate: date)
        case .graphicCorner:
            return createGraphicCornerTemplate(forDate: date)
        case .graphicCircular:
            return createGraphicCircleTemplate(forDate: date)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(forDate: date)
        case .graphicBezel:
            return createGraphicBezelTemplate(forDate: date)
        case .graphicExtraLarge:
            return createGraphicExtraLargeTemplate(forDate: date)
        @unknown default:
            fatalError()
        }
    }
    
    // Return a modular small template.
    private func createModularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let zodiac = try! GanzhiDateConverter.zodiac(date)
        let year = date.chineseYearMonthDate
        let shichen = try! GanzhiDateConverter.shichen(date)
        // Create the data providers.
        let yearText = CLKSimpleTextProvider(text: year)
        let shichenText = CLKSimpleTextProvider(text: shichen.chineseCharactor)
        // Create the template using the providers.
        return CLKComplicationTemplateModularSmallStackText(line1TextProvider: yearText, line2TextProvider: shichenText)
    }
    
    // Return a modular large template.
    private func createModularLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        
        let zodiac = try! GanzhiDateConverter.zodiac(date)
        let year = date.chineseYearMonthDate
        let shichen = try! GanzhiDateConverter.shichen(date)
        // Create the data providers.
        let titleTextProvider = CLKSimpleTextProvider(text: year, shortText: zodiac.rawValue)

        let shichenText = CLKSimpleTextProvider(text: shichen.chineseCharactor)
        let shichenAliasText = CLKSimpleTextProvider(text: shichen.aliasName)
    
        // Create the template using the providers.
        let imageProvider = CLKImageProvider(onePieceImage: zodiac.emoji.textToImage()!)
        return CLKComplicationTemplateModularLargeStandardBody(headerImageProvider: imageProvider,
                                                               headerTextProvider: titleTextProvider,
                                                               body1TextProvider: shichenText,
                                                               body2TextProvider: shichenAliasText)
    }
    
    // Return a utilitarian small flat template.
    private func createUtilitarianSmallFlatTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let zodiac = try! GanzhiDateConverter.zodiac(date)
        let shichen = try! GanzhiDateConverter.shichen(date)
  
        // Create the data providers.
        let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: zodiac.emoji.textToImage()!)

        let combinedMGProvider = CLKTextProvider(format: "%@ %@", shichen.chineseCharactor, shichen.aliasName)
        
        // Create the template using the providers.
        return CLKComplicationTemplateUtilitarianSmallFlat(textProvider: combinedMGProvider,
                                                           imageProvider: flatUtilitarianImageProvider)
    }
    
    // Return a utilitarian large template.
    private func createUtilitarianLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let zodiac = try! GanzhiDateConverter.zodiac(date)
        let shichen = try! GanzhiDateConverter.shichen(date)
        
        // Create the data providers.
        let flatUtilitarianImageProvider = CLKImageProvider(onePieceImage: zodiac.emoji.textToImage()!)
        
        let combinedMGProvider = CLKTextProvider(format: "%@ %@", shichen.chineseCharactor, shichen.aliasName)
        
        // Create the template using the providers.
        return CLKComplicationTemplateUtilitarianLargeFlat(textProvider: combinedMGProvider,
                                                           imageProvider: flatUtilitarianImageProvider)
    }
    
    // Return a circular small template.
    private func createCircularSmallTemplate(forDate date: Date) -> CLKComplicationTemplate {
        let shichen = try! GanzhiDateConverter.shichen(date)
        let year = try! GanzhiDateConverter.zodiac(date).rawValue
        // Create the data providers.
        let yearText = CLKSimpleTextProvider(text: year)
        let shichenText = CLKSimpleTextProvider(text: shichen.chineseCharactor)
        
        // Create the template using the providers.
        return CLKComplicationTemplateCircularSmallStackText(line1TextProvider: yearText,
                                                             line2TextProvider: shichenText)
    }
    
    // Return an extra large template.
    private func createExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
        let shichen = try! GanzhiDateConverter.shichen(date)
        let year = try! GanzhiDateConverter.zodiac(date).rawValue
        // Create the data providers.
        let yearText = CLKSimpleTextProvider(text: year)
        let shichenText = CLKSimpleTextProvider(text: shichen.chineseCharactor)
        
        // Create the template using the providers.
        return CLKComplicationTemplateExtraLargeStackText(line1TextProvider: yearText,
                                                          line2TextProvider: shichenText)
    }
    
    // Return a graphic template that fills the corner of the watch face.
    private func createGraphicCornerTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
        let leadingValueProvider = CLKSimpleTextProvider(text: "0")
        
        let trailingValueProvider = CLKSimpleTextProvider(text: "500")

        
        let shichen = try! GanzhiDateConverter.shichen(date)
        let yearText = CLKSimpleTextProvider(text: shichen.chineseCharactor)
        
        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
                                                   fillFraction: percentage)
        
        // Create the template using the providers.
        return CLKComplicationTemplateGraphicCornerGaugeText(gaugeProvider: gaugeProvider,
                                                             leadingTextProvider: leadingValueProvider,
                                                             trailingTextProvider: trailingValueProvider,
                                                             outerTextProvider: yearText)
    }
    
    // Return a graphic circle template.
    private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
                                                   fillFraction: percentage)
        
        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
        
        // Create the template using the providers.
        return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(gaugeProvider: gaugeProvider,
                                                                         bottomTextProvider: CLKSimpleTextProvider(text: "mg"),
                                                                         centerTextProvider: mgCaffeineProvider)
    }
    
    // Return a large rectangular graphic template.
    private func createGraphicRectangularTemplate(forDate date: Date) -> CLKComplicationTemplate {
        // Create the data providers.
        let imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicRectangular"))
        let titleTextProvider = CLKSimpleTextProvider(text: "Coffee Tracker", shortText: "Coffee")
        
        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
        
        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
                                                   fillFraction: percentage)
        
        // Create the template using the providers.
        
        return CLKComplicationTemplateGraphicRectangularTextGauge(headerImageProvider: imageProvider,
                                                                  headerTextProvider: titleTextProvider,
                                                                  body1TextProvider: combinedMGProvider,
                                                                  gaugeProvider: gaugeProvider)
    }
    
    // Return a circular template with text that wraps around the top of the watch's bezel.
    private func createGraphicBezelTemplate(forDate date: Date) -> CLKComplicationTemplate {
        
        // Create a graphic circular template with an image provider.
        let circle = CLKComplicationTemplateGraphicCircularImage(imageProvider: CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "CoffeeGraphicCircular")))
        
        // Create the text provider.
        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
        let mgUnitProvider = CLKSimpleTextProvider(text: "mg Caffeine", shortText: "mg")
        mgUnitProvider.tintColor = data.color(forCaffeineDose: data.mgCaffeine(atDate: date))
        let combinedMGProvider = CLKTextProvider(format: "%@ %@", mgCaffeineProvider, mgUnitProvider)
               
        let numberOfCupsProvider = CLKSimpleTextProvider(text: data.totalCupsTodayString)
        let cupsUnitProvider = CLKSimpleTextProvider(text: "Cups", shortText: "C")
        cupsUnitProvider.tintColor = data.color(forTotalCups: data.totalCupsToday)
        let combinedCupsProvider = CLKTextProvider(format: "%@ %@", numberOfCupsProvider, cupsUnitProvider)
        
        let separator = NSLocalizedString(",", comment: "Separator for compound data strings.")
        let textProvider = CLKTextProvider(format: "%@%@ %@",
                                           combinedMGProvider,
                                           separator,
                                           combinedCupsProvider)
        
        // Create the bezel template using the circle template and the text provider.
        return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: circle,
                                                               textProvider: textProvider)
    }
    
    // Returns an extra large graphic template.
    private func createGraphicExtraLargeTemplate(forDate date: Date) -> CLKComplicationTemplate {
        
        // Create the data providers.
        let percentage = Float(min(data.mgCaffeine(atDate: date) / 500.0, 1.0))
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColors: [.green, .yellow, .red],
                                                   gaugeColorLocations: [0.0, 300.0 / 500.0, 450.0 / 500.0] as [NSNumber],
                                                   fillFraction: percentage)
        
        let mgCaffeineProvider = CLKSimpleTextProvider(text: data.mgCaffeineString(atDate: date))
        
        return CLKComplicationTemplateGraphicExtraLargeCircularOpenGaugeSimpleText(
            gaugeProvider: gaugeProvider,
            bottomTextProvider: CLKSimpleTextProvider(text: "mg"),
            centerTextProvider: mgCaffeineProvider)
    }
}
