import AppIntents

@available(watchOSApplicationExtension 10.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Configuration"
  static var description: IntentDescription? = IntentDescription("TianganDizhi Widgets")
  
  @Parameter(title: "Date")
  var date: DateComponents
  
  @Parameter(title: "Location")
  var location: String
}
