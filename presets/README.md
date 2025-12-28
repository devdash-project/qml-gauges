# QML Gauges Presets

Pre-configured property sets for gauge components, inspired by real-world gauge designs.

## Directory Structure

Presets are organized by compound component:

```
presets/
├── GaugeNeedle/
│   └── autometer.json
├── GaugeArc/
├── GaugeFace/
├── GaugeTick/
└── ...
```

## Preset Format

Each preset is a JSON file with the following structure:

```json
{
  "name": "Display Name",
  "description": "Brief description of the style",
  "source": "docs/example-gauges/reference-image.png",
  "properties": {
    "propertyName": "value",
    ...
  }
}
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Human-readable preset name |
| `description` | Yes | Description of the visual style |
| `source` | No | Path to reference image that inspired the preset |
| `properties` | Yes | Object containing component property values |

## Available Presets

### GaugeNeedle

| Preset | Description |
|--------|-------------|
| `autometer.json` | Classic AutoMeter-style with orange body, dark counterweight, ridge gradient |

## Usage

Presets can be loaded in the Explorer or applied programmatically to components.

### In QML

```qml
import "presets/GaugeNeedle/autometer.json" as AutoMeterPreset

GaugeNeedle {
    frontColor: AutoMeterPreset.properties.frontColor
    frontGradient: AutoMeterPreset.properties.frontGradient
    // ... etc
}
```

### In Explorer

Use the preset loader dropdown (when available) to apply presets to the current component.
