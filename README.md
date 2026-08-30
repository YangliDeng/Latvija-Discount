# Latvija Discount

A Flutter app that pulls together the weekly discount leaflets from Latvia's main supermarket chains — Rimi, Maxima, and Lidl — so you don't have to check a different app or website for each one, or go looking for the paper leaflet in store.

## What it does

The home screen shows a carousel with the three stores. Swipe between them and the centered one scales up and lifts slightly. Behind everything there's an animated wave that shifts color depending on which store is currently centered — red for Rimi, blue for Maxima, yellow for Lidl.

Tap a store's logo and it opens that week's leaflet as a PDF, downloaded and shown right in the app.

The store list, discount periods, and PDF links aren't hardcoded — they're read from a manifest.json file hosted on GitHub and served through jsDelivr's CDN. That means updating what the app shows is just a matter of editing that file and pushing new PDFs, no app update required.

## Built with

- Flutter (Dart)
- http, for fetching manifest.json and the PDF files
- carousel_slider, for the store carousel
- pdfx, for rendering the PDF leaflets
- A custom CustomPainter (WavePainter) for the animated background

## Project structure

```
lib/
├── main.dart       - app entry point, home screen, carousel, manifest fetching
├── images.dart      - static list of store logos and their ids
├── leaflet.dart      - Leaflet model, parses each store entry from manifest.json
├── pdf_page.dart     - PDF viewer screen, downloads and displays a leaflet
└── animation.dart     - WavePainter, the animated background
```

## Where the data comes from

The actual content lives in a separate repo, [Latvija-Discount](https://github.com/YangliDeng/Latvija-Discount), which holds manifest.json and a pdfs folder with the leaflet files themselves. The app reads both through jsDelivr's mirror of that repo:

```
https://cdn.jsdelivr.net/gh/YangliDeng/Latvija-Discount@main/
```

manifest.json looks like this:

```json
{
  "stores": [
    {
      "id": "0",
      "name": "MAXIMA",
      "period": "28.07 - 03.08",
      "path": "pdfs/maxima.pdf"
    }
  ]
}
```

## Running it

Clone the repo, then:

```
flutter pub get
flutter run
```

## Ideas for later

A "Best Deal of the Week" section, maybe a draggable sheet showing the standout discount for that week. Also want to cache downloaded PDFs locally so opening one you've already viewed doesn't mean downloading it all over again.
