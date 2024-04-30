# Monitor your iOS using OpenTelemetry

This is a demo project showing how you can monitor your iOS app using the [OpenTelemetry](https://opentelemetry.io) o11y framework.

The benefits of using OpenTelemetry to monitor your mobile apps is that you don't lock yourself into one single vendor. OpenTelemetry is an open-source project that follows open standards for telemetry data (traces, metrics, and logs).

In this iOS example app, we show you how to use the OpenTelemetry Swift SDK to add tracing and logging to an iOS app. In this example, this data is then sent to Grafana Cloud for monitoring.

[Here](https://www.loom.com/share/a313a2799b0648a6a8fea731819ab954?sid=fe1077f1-7019-443d-a4f8-94cd30c2b984) is a short video showcasing this demo project.

## Setup

### 0. Prerequisites

You need to have Xcode installed.  
This project was built and tested using Xcode 15.3

### 1. Setup Grafana Cloud

Go to [Grafana.com](https://grafana.com) and set up a new account.
Then go to your account overview and tap the `Configure` button on the OpenTelemetry-tile.

SEE IMAGE

There you need to find these 3 things

1. Endpoint for sending OTLP signals
1. Instance ID
1. Password / API Token

If you don't have a token yet, then you first need to tap the `Generate now` button in the token section.

SEE IMAGE

### 2. Configure OpenTelemetry in the Xcode project

Now you can open the Xcode project by opening this file: [AppO11yDemo.xcodeproj](AppO11yDemo.xcodeproj).  
The first thing you will need to do is to enter your Grafana-Cloud-OpenTelemetry config into the [OTelConfig](/AppO11yDemo/OpenTelemetry/OTelConfig.swift)

Open that file and fill in the `token`, `instanceId` and `endpointUrl`.  
Optionally you can also change the other config names in there, like the service name. But that is not needed to get this example working.

That's all you need to do.

### 3. Compile and run

Now you can build and run the iOS app. It is probably easiest to run it on the iOS Simulator (if you want to run it on a real device, then you will need to set up provisioning and signing. This is outside the scope of this example).

## What is the app doing

The app is pretty basic. It fetches a list of `Coffee` items from this url https://api.sampleapis.com/coffee/hot and shows them in a list. You can tap a `Coffee` item to see more details about it and also brew it (unfortunately no real coffee is created, only virtual caffeine).

The app uses the [OpenTelemetry Swift SDK](https://github.com/open-telemetry/opentelemetry-swift) to capture traces and logs. To simplify the usage of the OpenTelemetry Swift SDK, there are some small helper classes which helps you with initialization and logging and more. But these are really lightweight. You are mostly interacting directly with the pure OpenTelemetry Swift SDK.

### Initializing the OpenTelemetry Swift SDK

In the [AppO11yDemoApp](/AppO11yDemo/AppO11yDemoApp.swift) we initialize the SDK. This is done via small helper classes. This is how it looks like:

```swift
@main
struct AppO11yDemoApp: App {
    init() {
        OTelTraces.instance.initialize()
        OTelLogs.instance.initialize()
    }
    ...
}
```

These `initialize` methods take the config data which you provided into the [OTelConfig](/AppO11yDemo/OpenTelemetry/OTelConfig.swift) and sets up the OpenTelemetry SDK for you. If you wanna have a look at the config or do some more customization then have a look inside these files:

- [OTelTraces.swift](/AppO11yDemo/OpenTelemetry/OTelTraces.swift)
- [OTelLogs.swift.swift](/AppO11yDemo/OpenTelemetry/OTelLogs.swift.swift)

Generally you should not need to tweak things in there. But for example you might want to change the `SpanProcessor` which is used. By default we only use the `SimpleSpanProcessor` which exports data directly, which is good during development. But for prod builds you might want to change this to use the `BatchSpanProcessor`.

Another thing which you might want to configure in the `OTelTraces.swift` is the automatic URLSession-tracing capture. Feel free to tweak the config passed into the `URLSessionInstrumentationConfiguration`. Here you can for example change how the automatically captured spans are named and more.

### Interacting with the OpenTelemetry Swift SDK

After the initialization is completed, then you start capturing manual spans and sending logs.

#### Doing some logging

To send logs, you will need to access the logger. You get this by calling:

```swift
let logger = OTelLogs.instance.getLogger()
```

On this logger object you can then call `log(...)` and start collecting important data. You need to provide a log message and a log severity. Optionally you can pass in a custom date when the log was collected, and also custom attributes.  
Here is an example of how you can call the logger:

```swift
logger.log("AppO11yDemo was started", severity: .debug)
logger.log(
    "Starting to brew a new coffee",
    severity: .info,
    attributes: ["CoffeeType": coffee.title]
)
```

#### Capture the traces

If you want to capture some traces, then you will need to get hold of a `Span`. You get these `spans` from a `tracer.spanBuilder(...)`. And you get the tracer by calling this:

```swift
let tracer = OTelTraces.instance.getTracer()
```

Now you are ready to create a span:

```swift
let someSpan = tracer.spanBuilder(spanName: "BrewingCoffee")
    .setSpanKind(spanKind: .server)
    .startSpan()
someSpan.setAttribute(key: "CoffeeType", value: coffee.title.safeTracingName)

...
// Do some work
...

someSpan.end()
```

If you want, you can also define a status on your span. This is optional, but might make sense if an error occurs. By default the status is `unset`.

```swift
if didCompleteBrewing {
    parentSpan.status = .ok
} else {
    parentSpan.status = .error(description: "Failed_to_make_coffee")
}
parentSpan.end()
```

It is important to note that you need to call `.end()` on your spans for them to be recorded correctly.

You can also nest spans. So you can have a parent span and a child span. Here is an example showcasing this:

```swift
let parentSpan = tracer.spanBuilder(spanName: "MamaSpan")
    .setSpanKind(spanKind: .server)
    .startSpan()

...

let childSpan = tracer.spanBuilder(spanName: "BabySpan")
    .setParent(parentSpan)
    .setSpanKind(spanKind: .server)
    .startSpan()
```

One important thing to note here. If you want to use Grafana Application O11y, then you need to set the `spanKind` to `.server`. Otherwise Grafana Application O11y will not be able to automatically collect your data.

## Checking out the data in Grafana.com

Once you have the app running and you collected some data, then it is time to observe it in Grafana App O11y!

Go to `Grafana App Observability`. It will have this url: `https://{your-stack}.grafana.net/a/grafana-app-observability-app/services`

You should be able to see your service pop up there.
It will look something like this:

SEE IMAGE.

Tap on your service and then you get to the details and heath for that service.

SEE IMAGE.

From here you can inspect traces and logs and run analysis on your mobile app and make sure everything works as expected!

And if not, then this is the perfect place to start the next big bug hunt!
Happy monitoring 😁
