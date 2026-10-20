# Transformer architecture — drawio-skill test

主图（encoder–decoder 架构）的 draw.io 可编辑图，用于验证 `drawio-skill`
在本项目中的安装与导出链路。

## Files

| File | Description |
| --- | --- |
| [`transformer.drawio`](transformer.drawio) | 可编辑源文件（未压缩 XML） |
| [`transformer.png`](transformer.png) | 最终 PNG，内嵌 draw.io XML，可直接拖回 draw.io 继续编辑 |
| [`transformer.svg`](transformer.svg) | 矢量导出，内嵌图像资源 |

## Contents

- **Encoder × 6**：Multi-Head Self-Attention (8 heads) → Add & Norm →
  Feed Forward (d_ff = 3072, GELU) → Add & Norm。
- **Decoder × 6**：Masked Multi-Head Self-Attention → Add & Norm →
  Cross-Attention (Q from decoder, K/V from encoder) → Add & Norm →
  Feed Forward → Add & Norm。
- **Input/output paths**：source/target token embeddings + sinusoidal positional
  encoding, then Linear → Softmax → output probabilities over vocabulary V.
- **Tensor annotations** (`(B, T_src, 768)` / `(B, T_tgt, V)`) on every stage;
  color legend for attention, Add & Norm, feed-forward/linear, embeddings,
  positional encoding, and softmax.
- The purple `K, V` connector shows the encoder output feeding the decoder's
  cross-attention.

## Validation

```text
python3 <skill>/scripts/validate.py transformer.drawio --score
0 error(s), 0 warning(s)
score: 0 (0 through-vertex, 0 crossings, 0 overlaps)
```

## Regenerate

```bash
# Draft (visual check only; never embed XML)
drawio -x -f png --width 2000 -o draft.png transformer.drawio --no-sandbox

# Final editable PNG + SVG
drawio -x -f png -e -s 2 -o transformer.png transformer.drawio --no-sandbox
python3 <skill>/scripts/repair_png.py transformer.png
drawio -x -f svg -e --embed-svg-images -o transformer.svg transformer.drawio --no-sandbox
```

Tool versions used: draw.io CLI **32.4.1**, Python **3.13.5**, macOS.

> `--no-sandbox` is required in this sandboxed desktop environment: draw.io's
> Chromium sandbox cannot initialize here. Place the flag at the very end of the
> command (otherwise it is parsed as the input filename).

## Notes

- Main figure only: no C4/multi-page views, Story page, or review artifacts.
- Residual connections are implied by the Add & Norm blocks rather than drawn as
  separate skip arrows, keeping the main figure readable.
