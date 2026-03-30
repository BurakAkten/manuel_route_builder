import 'manuel_route_builder_l10n.dart';

class ManuelRouteBuilderDefaultL10n implements ManuelRouteBuilderL10n {
  @override
  String get generatedRoute => "Generated Route";

  @override
  String get save => "Save";

  @override
  String get startPointWarning => "Start point is too far";

  @override
  String get starting => "Starting";

  @override
  String get generatedManuelRoute => "Generated Manuel Route";

  @override
  String get touchTheMapForStartingPoint => "Touch the map for starting point";

  @override
  String get routeGenerating => "Route generating...";

  @override
  String get wayOfAreaSelection => "Way of area selection";

  @override
  String get circleSelectionMode => "Circle selection mode";

  @override
  String get freeDrawSelectionMode => "Free draw selection mode";

  @override
  String get radius => "Radius";

  @override
  String get selectAreaOnMap => "Select area on map";

  @override
  String get drawCircleByClickingOnMap => "Draw a circle by clicking on the map.";

  @override
  String get freeDrawOnMap => "Free draw on map";

  @override
  String get pointsInArea => "points in this area";

  @override
  String get noPointsInArea => "No points in this area";

  @override
  String get continueButton => "Continue →";

  @override
  String get areaNotDrawnYet => "Area has not been drawn yet";

  @override
  String get startDrawing => "Start drawing";

  @override
  String get reset => "Reset";

  @override
  String get dragOnMapToDraw => "Drag your finger on the map";

  @override
  String get startPointTitle => "Start point";

  @override
  String get startPointSelected => "Start point selected";

  @override
  String get selectOptionOrTapMap => "Choose an option or tap on the map";

  @override
  String get myLocation => "My location";

  @override
  String get selectFromMap => "From map";

  @override
  String get buildRoute => "Build route";

  @override
  String pointsCountInArea(int count) => "$count point${count > 1 ? 's' : ''} in this area";
  String pointsCount(int count) => "$count point${count > 1 ? 's' : ''}";
}
