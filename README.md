# manuel_route_builder

A Flutter package for creating manual routes on a map. Users can select an area on the map (circle or free draw), choose a starting point, and the package automatically calculates the optimal route through all points within the selected area using the nearest neighbor algorithm.

---

## Features

- **Area selection** — Two modes: tap to place a circle, or free-hand draw a polygon
- **Dynamic radius** — Circle radius scales relative to the visible map area, ensuring consistent visual size regardless of zoom level
- **Starting point selection** — Use current GPS location or tap anywhere on the map
- **Nearest neighbor routing** — Automatically orders points by proximity for an efficient route
- **Result screen** — Displays the route on a map with numbered markers (first point green, last point red with flag, focused point amber with halo) and a scrollable list
- **Tap to focus** — Tapping a list item zooms the map to that point and highlights it
- **Tablet support** — Result screen uses a side-by-side layout on screens wider than 600px
- **Fully customizable** — Primary color, success color, custom scaffold builder, custom list item builder, and save callback

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  manuel_route_builder: ^1.0.0
```


Then run:

```bash
flutter pub get
```

### Platform setup

**Android** — Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** — Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is needed to set the route start point.</string>
```

---

## Quick start

```dart
import 'package:manuel_route_builder/manuel_route_builder.dart';

// 1. Convert your data model to RoutePoint
final points = myPoints.map((p) => RoutePoint(
  id: p.id.toString(),
  title: p.name,
  location: LatLng(p.lat, p.lng),
)).toList();

// 2. Open the screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ManualRouteCreationScreen(
      allPoints: points,
      onGetCurrentLocation: () async {
        final pos = await Geolocator.getCurrentPosition();
        return LatLng(pos.latitude, pos.longitude);
      },
      onRouteSaved: (route, startPoint) {
        // Handle the saved route
        print('Route has ${route.length} points');
      },
    ),
  ),
);
```

---

## RoutePoint model

```dart
RoutePoint({
  required String id,       // Unique identifier
  required String title,    // Display name shown on markers and list
  required LatLng location, // Coordinates
  Map<String, dynamic> extra = const {}, // Optional extra data
})
```

Use `extra` to carry your original model alongside the `RoutePoint`:

```dart
RoutePoint(
  id: p.id.toString(),
  title: p.name,
  location: LatLng(p.lat, p.lng),
  extra: {'original': p},
)

// Retrieve it in the save callback
onRouteSaved: (route, startPoint) {
  final originals = route.map((r) => r.extra['original'] as MyPoint).toList();
},
```

---

## ManualRouteCreationScreen parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `allPoints` | `List<RoutePoint>` | required | All points shown on the map |
| `onGetCurrentLocation` | `Future<LatLng?> Function()?` | null | Callback to fetch GPS location |
| `primaryColor` | `Color` | `#534AB7` | Main accent color |
| `successColor` | `Color` | `#1D9E75` | Success/confirm color |
| `startPointThresholdMeters` | `double` | `2000` | If the start point is farther than this from the route center, it is hidden on the result map to prevent rendering issues |
| `routeResultItemBuilder` | `Widget Function(BuildContext, RoutePoint, int)?` | null | Custom list item builder for the result screen |
| `onRouteSaved` | `void Function(List<RoutePoint>, LatLng)?` | null | Called when the user taps Save |
| `scaffoldBuilder` | `ScaffoldBuilder?` | null | Custom scaffold wrapper — see below |

---

## Custom scaffold

Use `scaffoldBuilder` to wrap the screens in your own `Scaffold` or design system component:

```dart
ManualRouteCreationScreen(
  allPoints: points,
  scaffoldBuilder: (context, appBar, stepIndicator, body) {
    return MyAppScaffold(
      appBar: MyAppBar(
        title: 'Create route',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: stepIndicator,
        ),
      ),
      body: body,
    );
  },
)
```

`appBar` is a pre-built `PreferredSizeWidget` you can use as-is or replace entirely. `stepIndicator` is the animated step dots widget — pass it to your own app bar's `bottom` if you want to keep it.

---

## Custom list item

Override the default list tile in the result screen:

```dart
ManualRouteCreationScreen(
  allPoints: points,
  routeResultItemBuilder: (context, point, index) {
    return ListTile(
      leading: CircleAvatar(child: Text('${index + 1}')),
      title: Text(point.title),
      subtitle: Text(point.extra['address'] ?? ''),
    );
  },
)
```

---

## Using the service directly

If you only need the routing algorithm without the UI:

```dart
import 'package:manuel_route_builder/manuel_route_builder.dart';

// Filter points inside a circle
final inZone = RouteBuilderService.filterInCircle(
  allPoints,       // List<RoutePoint>
  center,          // LatLng
  radiusMeters,    // double
);

// Build an ordered route from a starting location
final route = RouteBuilderService.buildNearestNeighborRoute(
  inZone,          // List<RoutePoint>
  startLocation,   // LatLng
);

// Calculate distance between two coordinates (metres)
final dist = RouteBuilderService.haversineDistance(a, b);

// Get LatLngBounds covering a list of points
final bounds = RouteBuilderService.computeBounds(
  points,
  startPoint: optionalStartPoint,
);

// Get an appropriate initial CameraPosition for a list of points
final camera = RouteBuilderService.computeInitialCamera(points);
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `google_maps_flutter` | Map rendering, markers, circles, polygons, polylines |
| `maps_toolkit` | Point-in-polygon check for free-draw area selection |

---

## File structure

```
lib/
├── manuel_route_builder.dart       # Barrel export
├── enums/
│   └── selection_mode.dart         # none / circle / freeDraw
├── models/
│   └── route_point.dart            # RoutePoint data class
├── services/
│   └── route_builder_service.dart  # Haversine, filter, route, bounds
├── utils/
│   └── free_draw_painter.dart      # CustomPainter for drawing overlay
└── screens/
    ├── manual_route_creation/
    │   ├── manual_route_creation_screen.dart
    │   ├── manual_route_creation_controller.dart
    │   └── widgets/
    │       ├── bottom_sheet_content.dart
    │       └── step_indicator.dart
    └── route_result_screen/
        └── route_result_screen.dart
```

---

## Running the example

To run the example app you need a Google Maps API key.
Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in:
- `example/android/app/src/main/AndroidManifest.xml`
- `example/ios/Runner/AppDelegate.swift`

## License

MIT