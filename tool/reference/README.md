# Chart provenance

`mongolian_alphabet.jpg` is the unmodified image supplied by the app owner:
`Vertical_Mongolian_Script_Alphabet_with_Pronunciation_Guide.jpg`.
The printed attribution is **© Shigüsütei Bagatur**. That credit is retained
here and in the app. This repository does not assert ownership of the chart
or grant a new license to it.

`../trace_chart_letters.py` extracts the printed ink boundaries into filled
vector contours, excluding labels, ruled lines and dotted joining hints.
Contours are resampled and gently smoothed in source-pixel space to remove
photographic stair-stepping. Compact dots are regularized into ellipses; the
app renders closed quadratic curves and retains separate loop contours.
Its manually annotated centerlines define practice segments. The chart is
not a stroke-order diagram: segment order and direction are inferred and
remain pending teacher review. Small dot marks are short separate segments.
The contours and guides share a square coordinate system, preserving aspect
ratio in both previews and handwriting lessons.

There are **73 forms across 23 chart groups**: 68 positional forms and five
alternatives (a/e final, gh/kh medial, n medial). The chart has no initial ng.
Combined readings (o/u, ö/ü, t/d, j/z, ch/ts) stay combined. Identical shapes
across chart rows have shared recognition groups, so the quiz accepts a group
instead of demanding a reading that cannot be inferred without a word.
The existing six lesson IDs and order are retained before the added forms.

The chart is a learning reference, not a complete contextual shaping engine.
For the distinction between contextual variants and underlying characters,
see Unicode's Mongolian chapter:
https://www.unicode.org/versions/Unicode16.0.0/core-spec/chapter-13/#G27703

Regenerate (developer dependencies only):

```sh
python -m pip install numpy opencv-python-headless
python tool/trace_chart_letters.py
dart format lib/src/data/chart_letters.dart
```

`chart_traces.json` contains source cell rectangles, normalized contours and
practice segments for visual inspection and future correction.
