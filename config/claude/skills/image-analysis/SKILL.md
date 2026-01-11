---
name: image-analysis
description: Analyze images with automatic cropping to examine fine details like chart axes, small text, legends, and dense data regions
allowed-tools:
  - Bash
  - Read
---

# Deep Image Analysis with Cropping

When analyzing images containing fine details (charts, documents, diagrams, screenshots with text), use a multi-pass approach to ensure accuracy.

## When to Use This Skill

- Charts or graphs where axis labels, legends, or data points need to be read
- Documents or screenshots with small text
- Dense diagrams with fine details
- Any image where you are uncertain about values or text

## Process

### Step 1: Initial Read
Read the full image to understand its structure and identify regions needing closer inspection.

```bash
# The Read tool handles images natively
```

### Step 2: Identify Regions of Interest
Based on the initial view, identify specific regions that:
- Contain text too small to read confidently
- Have dense data you need to examine
- Include legends, axes, labels, or annotations

### Step 3: Crop and Examine
Use `crop-image` to extract regions using normalized 0-1 coordinates:

```bash
# crop-image IMAGE x1 y1 x2 y2 [OUTPUT]
# (x1,y1) = top-left corner, (x2,y2) = bottom-right corner

# Examples for common chart regions:
crop-image chart.png 0.0 0.0 0.15 1.0 /tmp/y_axis.png      # Y-axis (left strip)
crop-image chart.png 0.0 0.85 1.0 1.0 /tmp/x_axis.png      # X-axis (bottom strip)
crop-image chart.png 0.7 0.0 1.0 0.3 /tmp/legend.png       # Legend (top-right)
crop-image chart.png 0.15 0.1 0.85 0.85 /tmp/data.png      # Data area (center)
```

### Step 4: Read Cropped Images
Immediately read each cropped region to examine details:

```bash
# Then use the Read tool on /tmp/cropped.png
```

### Step 5: Synthesize
Combine findings from all passes into the final answer.

## Critical Rules

1. **Never guess values** - If you cannot read text or numbers clearly, crop and zoom
2. **Never hallucinate** - Uncertain? Crop first, answer second
3. **Be systematic** - For charts, always examine: axes, legend, title, data regions
4. **Iterate if needed** - Crop again at higher zoom if still unclear

## Coordinate Reference

```
(0,0) -------- (1,0)
  |              |
  |    IMAGE     |
  |              |
(0,1) -------- (1,1)
```

- `x` increases left to right (0 = left edge, 1 = right edge)
- `y` increases top to bottom (0 = top edge, 1 = bottom edge)
