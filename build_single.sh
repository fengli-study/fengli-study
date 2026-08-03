#!/bin/bash
# 把 CSS 和 JS 内嵌到 index.html 生成单个文件
# 输出到 /workspace/凤梨工作台/index_full.html 用于部署

# 用 Python 做替换（避免 awk 参数过长）
python3 << 'PYEOF'
import re, os, base64

with open("/workspace/凤梨工作台/index.html", "r") as f:
    html = f.read()

with open("/workspace/凤梨工作台/css/style.css", "r") as f:
    css = f.read()
with open("/workspace/凤梨工作台/js/data.js", "r") as f:
    data_js = f.read()
with open("/workspace/凤梨工作台/js/app.js", "r") as f:
    app_js = f.read()

# 去掉外部 CSS 引用
html = re.sub(r'<link rel="stylesheet" href="css/style\.css"[^>]*>', '', html)
# 去掉外部 JS 引用
html = re.sub(r'<script src="js/data\.js"[^>]*></script>', '', html)
html = re.sub(r'<script src="js/app\.js"[^>]*></script>', '', html)

# 去掉已有的内联 <script>...</script> 块（旧的内联代码）
html = re.sub(r'<script>.*?</script>', '', html, flags=re.DOTALL)

# 内联 manifest
with open("/workspace/凤梨工作台/manifest.json", "rb") as f:
    manifest_b64_str = base64.b64encode(f.read()).decode()
html = html.replace(
    '<link rel="manifest" href="manifest.json">',
    f'<link rel="manifest" href="data:application/json;base64,{manifest_b64_str}">'
)

# 在 </head> 前插入 CSS
html = html.replace('</head>', f'<style>\n{css}\n</style>\n</head>')

# 在 </body> 前插入 JS（data.js 在前，app.js 在后）
html = html.replace('</body>', f'<script>\n{data_js}\n</script>\n<script>\n{app_js}\n</script>\n</body>')

with open("/workspace/凤梨工作台/index_full.html", "w") as f:
    f.write(html)

size = os.path.getsize("/workspace/凤梨工作台/index_full.html")
print(f"Done: {size} bytes")
PYEOF
