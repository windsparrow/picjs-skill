# 太阳系行星分布 — picjs test

用 picjs 绘制的太阳系八大行星分布示意图，用于验证 `picjs` skill 在
本项目中的安装、渲染与中文排版链路。

## Files

| File | Description |
| --- | --- |
| [`solar-system.picjs`](solar-system.picjs) | 可编辑源文件 |
| [`solar-system.png`](solar-system.png) | 最终 PNG（1600 px 宽） |
| [`solar-system.svg`](solar-system.svg) | 矢量导出，旁边保留 picjs 源码注释 |

## Contents

- 太阳居中，八条虚线轨道由内向外依次为水星、金星、地球、火星、
  木星、土星、天王星、海王星。
- 每颗行星标注中文名与轨道半长轴（AU）：0.39 / 0.72 / 1.00 / 1.52 /
  5.20 / 9.58 / 19.2 / 30.1。
- 行星使用区分度较高的自然色；土星带倾斜光环，太阳带两层柔光晕。
- 类地行星（内侧四颗）与巨行星（外侧四颗）的间距差异一目了然。

## Scale

示意式布局，**不是**真实比例：

- 轨道半径为 `0.9 × √(半长轴/AU)`，把 0.39–30.1 AU 压缩到
  0.56–4.94 的绘图半径；图下方已注明。
- 行星半径为示意放大（水星 0.045 → 木星 0.22），否则内侧行星不可见；
  图下方已注明。

## Regenerate

```bash
node <skill>/scripts/render.mjs solar-system.picjs solar-system.png
node <skill>/scripts/render.mjs solar-system.picjs solar-system.svg
```

Tool versions used: picjs **0.4.0**, Node **26.8.2**,
rsvg-convert **2.63.2**, macOS。

## Notes

- 轨道圆用纸色 `#FAF7F2` 填充（picjs 0.4.0 不支持 `fill none`），
  由外向内绘制，避免相互遮挡。
- 标题为单行中文粗体，picjs 会低估 CJK 宽度，锚点按实测像素左移
  0.73 单位；多行行星标签统一使用三引号形式，`text-anchor="middle"`
  可精确居中。
