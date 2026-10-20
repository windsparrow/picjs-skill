# 太阳系行星分布 — drawio-skill test

用 draw.io 手写 XML 绘制的太阳系八大行星分布示意图，用于验证
`drawio-skill` 在本项目中的生成、结构校验与导出链路。与
[`../solar-system`](../solar-system/) 的 picjs 版本同题，便于对比两种工具的
可编辑产物。

## Files

| File | Description |
| --- | --- |
| [`solar-system.drawio`](solar-system.drawio) | 可编辑源文件（未压缩 XML） |
| [`solar-system.png`](solar-system.png) | 最终 PNG（2181 × 2634），内嵌 draw.io XML，可直接拖回 draw.io 继续编辑 |
| [`solar-system.svg`](solar-system.svg) | 矢量导出，内嵌图像资源与源文件 |

## Contents

- 太阳居中，八条虚线同心轨道由内向外依次为水星、金星、地球、火星、
  木星、土星、天王星、海王星。
- 每颗行星标注中文名与轨道半长轴（AU）：0.39 / 0.72 / 1.00 / 1.52 /
  5.20 / 9.58 / 19.2 / 30.1。
- 行星使用自然色；土星带倾斜光环，太阳带两层柔光晕。
- 类地行星（内侧四颗）与巨行星（外侧四颗）的轨道间距差异一目了然。
- 纸色背景（`#FAF7F2`），与 picjs 版本保持一致的视觉语言。

## Scale

示意式布局，**不是**真实比例：

- 轨道半径按 `r = 110 × 0.9 × √(a / 1 AU)` 像素压缩，把 0.39–30.1 AU
  压缩到 61.6–543.4 px 的绘图半径；图下方已注明。
- 行星直径为示意放大（水星 8.25 px → 木星 24.2 px），否则内侧行星不可见；
  图下方已注明。
- 行星所在角度是示意分布，不代表任何真实历元的位置。
- 1 AU ≈ 1.496 亿公里。

## Validation

```text
python3 <skill>/scripts/validate.py solar-system.drawio --score
0 error(s), 141 warning(s)
score: 705 (0 through-vertex, 0 crossings, 141 overlaps)
```

> `W-OVERLAP` 是这类图的预期结果：八条轨道本来就是同心包含关系，行星标签
> 也刻意叠在轨道线上（用 `labelBackgroundColor` 遮住背后的虚线）。校验器
> 没有“分层天文布局”的概念，因此无需处理这些警告。

## Regenerate

```bash
# 预览（仅用于视觉检查，不嵌入 XML）
drawio -x -f png --width 2000 -o draft.png solar-system.drawio --no-sandbox

# 最终可编辑 PNG + SVG
drawio -x -f png -e -s 2 -o solar-system.png solar-system.drawio --no-sandbox
python3 <skill>/scripts/repair_png.py solar-system.png
drawio -x -f svg -e --embed-svg-images -o solar-system.svg solar-system.drawio --no-sandbox
```

Tool versions used: draw.io CLI **32.4.1**, Python **3.14.4**, macOS。

> `--no-sandbox` 是此桌面环境所必需的（Chromium sandbox 无法初始化），且必须
> 放在命令末尾，否则会被当作输入文件名解析。

## Notes

- 源文件为未压缩 XML，所有图形和文本均可在 draw.io 中直接编辑。
- 轨道使用 `fillColor=none` 的虚线椭圆；行星与标签按 z 序后绘制。
- 标签采用独立的 `text` 单元，避免使用不透明矩形框遮挡行星本体。
